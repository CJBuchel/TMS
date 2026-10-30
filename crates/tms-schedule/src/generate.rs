//! Builds a schedule from the event's teams, tables, pods and times: lays out match and judging slots, then
//! places teams with simulated annealing over a penalty. A team's judging session must stay clear of its matches by
//! the event's gap (hard); back-to-back matches, repeat opponents and the same table every round cost a little
//! (soft). The random number generator is seeded, so the same request gives the same schedule.

use chrono::{DateTime, TimeDelta, Utc};
use tms_core::model::MatchKind;

use crate::resolve::{ResolvedMatch, ResolvedSchedule, ResolvedSession, ResolvedSlot};
use crate::tiab::TiabTeam;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct GenerateInput {
  pub teams: Vec<TiabTeam>,
  /// In facing pairs: 0 and 1, then 2 and 3.
  pub tables: Vec<String>,
  pub pods: Vec<String>,
  pub match_start: DateTime<Utc>,
  /// From one match's start to the next.
  pub match_cycle: TimeDelta,
  pub match_length: TimeDelta,
  pub practice_rounds: u8,
  pub ranking_rounds: u8,
  pub judging_start: DateTime<Utc>,
  pub session_length: TimeDelta,
  /// From one session's start to the next: the session plus time for rubrics.
  pub session_cycle: TimeDelta,
  /// Least time between a team's judging session and its matches.
  pub judging_gap: TimeDelta,
  /// Breaks, ceremonies and meetings; nothing is scheduled across them.
  pub breaks: Vec<(DateTime<Utc>, DateTime<Utc>)>,
  pub seed: u64,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum GenerateError {
  Empty(&'static str),
  /// Match cycle shorter than a match, or session cycle shorter than a session.
  Timing(&'static str),
}

impl std::fmt::Display for GenerateError {
  fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
    match self {
      GenerateError::Empty(what) => write!(f, "The event needs at least one {what}."),
      GenerateError::Timing(message) => f.write_str(message),
    }
  }
}

/// Small permuted congruential generator; the schedule must not depend on a platform RNG.
struct Pcg(u64);

impl Pcg {
  fn next(&mut self) -> u32 {
    self.0 = self
      .0
      .wrapping_mul(6_364_136_223_846_793_005)
      .wrapping_add(1_442_695_040_888_963_407);
    let x = ((self.0 >> 18) ^ self.0) >> 27;
    let rot = self.0 >> 59;
    u32::try_from(x & 0xffff_ffff)
      .unwrap_or(0)
      .rotate_right(u32::try_from(rot).unwrap_or(0))
  }

  fn below(&mut self, n: usize) -> usize {
    usize::try_from(self.next()).unwrap_or(0) % n.max(1)
  }

  fn unit(&mut self) -> f64 {
    f64::from(self.next()) / f64::from(u32::MAX)
  }
}

/// Consecutive start times from `start`, each `cycle` apart, moved past any break they would run into.
fn times(
  start: DateTime<Utc>,
  cycle: TimeDelta,
  length: TimeDelta,
  count: usize,
  breaks: &[(DateTime<Utc>, DateTime<Utc>)],
) -> Vec<DateTime<Utc>> {
  let mut out = Vec::with_capacity(count);
  let mut t = start;
  while out.len() < count {
    if let Some((_, end)) = breaks.iter().find(|(b0, b1)| t < *b1 && *b0 < t + length) {
      t = *end;
      continue;
    }
    out.push(t);
    t += cycle;
  }
  out
}

#[derive(Clone, Copy)]
struct Interval {
  start: DateTime<Utc>,
  end: DateTime<Utc>,
}

/// Seconds between two intervals; negative when they overlap.
fn gap_seconds(a: Interval, b: Interval) -> i64 {
  if a.end <= b.start {
    (b.start - a.end).num_seconds()
  } else if b.end <= a.start {
    (a.start - b.end).num_seconds()
  } else {
    -1
  }
}

const HARD: i64 = 1_000_000;
const BACK_TO_BACK: i64 = 1_000;
const REPEAT_OPPONENT: i64 = 100;
const CLOSE_TO_JUDGING: i64 = 10;
const SAME_TABLE: i64 = 1;
/// Playing with the facing table empty, which spreads a round over more matches than it needs.
const NO_OPPONENT: i64 = 20;

struct Layout {
  teams: usize,
  tables: usize,
  pods: usize,
  /// Every round's match times: practice rounds, then ranking rounds.
  rounds: Vec<Vec<DateTime<Utc>>>,
  sessions: Vec<DateTime<Utc>>,
  ranking_from: usize,
  match_length: TimeDelta,
  session_length: TimeDelta,
  gap: i64,
  rest: i64,
}

/// Who sits where: `judging[p]` is the team in session `p / pods`, pod `p % pods`; `rounds[r][p]` is the team in
/// match `p / tables` of round `r` at table `p % tables`.
#[derive(Clone)]
struct Placement {
  judging: Vec<Option<usize>>,
  rounds: Vec<Vec<Option<usize>>>,
  /// Each team's position in `judging` and in every round.
  judging_at: Vec<usize>,
  round_at: Vec<Vec<usize>>,
}

impl Layout {
  fn session(&self, position: usize) -> Interval {
    let start = self.sessions[position / self.pods];
    Interval {
      start,
      end: start + self.session_length,
    }
  }

  fn game(&self, round: usize, position: usize) -> Interval {
    let start = self.rounds[round][position / self.tables];
    Interval {
      start,
      end: start + self.match_length,
    }
  }

  /// The position of the facing table in the same match, if there is one.
  fn facing(&self, position: usize) -> Option<usize> {
    let table = position % self.tables;
    let other = table ^ 1;
    (other < self.tables).then(|| position - table + other)
  }

  fn team_penalty(&self, p: &Placement, team: usize) -> i64 {
    let judging = self.session(p.judging_at[team]);
    let mut cost = 0;
    let mut games: Vec<(Interval, usize, usize)> = Vec::with_capacity(self.rounds.len());
    for (round, positions) in p.round_at.iter().enumerate() {
      let position = positions[team];
      let game = self.game(round, position);
      let gap = gap_seconds(game, judging);
      if gap < self.gap {
        cost += HARD;
      } else if gap < 2 * self.gap {
        cost += CLOSE_TO_JUDGING;
      }
      if self.facing(position).is_some_and(|f| p.rounds[round][f].is_none()) {
        cost += NO_OPPONENT;
      }
      games.push((game, round, position));
    }
    games.sort_by_key(|(g, _, _)| g.start);
    for pair in games.windows(2) {
      if (pair[1].0.start - pair[0].0.end).num_seconds() < self.rest {
        cost += BACK_TO_BACK;
      }
    }
    let ranking: Vec<&(Interval, usize, usize)> = games.iter().filter(|(_, r, _)| *r >= self.ranking_from).collect();
    for (i, (_, ra, pa)) in ranking.iter().enumerate() {
      let opponent_a = self.facing(*pa).and_then(|f| p.rounds[*ra][f]);
      for (_, rb, pb) in &ranking[i + 1..] {
        if opponent_a.is_some() && opponent_a == self.facing(*pb).and_then(|f| p.rounds[*rb][f]) {
          cost += REPEAT_OPPONENT;
        }
        if pa % self.tables == pb % self.tables {
          cost += SAME_TABLE;
        }
      }
    }
    cost
  }
}

impl Placement {
  fn new(layout: &Layout, rng: &mut Pcg) -> Self {
    let fill = |size: usize, rng: &mut Pcg| -> Vec<Option<usize>> {
      let mut v: Vec<Option<usize>> = (0..size).map(|i| (i < layout.teams).then_some(i)).collect();
      for i in (1..v.len()).rev() {
        v.swap(i, rng.below(i + 1));
      }
      v
    };
    let judging = fill(layout.sessions.len() * layout.pods, rng);
    let rounds: Vec<Vec<Option<usize>>> = layout
      .rounds
      .iter()
      .map(|r| fill(r.len() * layout.tables, rng))
      .collect();
    let mut p = Self {
      judging,
      rounds,
      judging_at: vec![0; layout.teams],
      round_at: vec![vec![0; layout.teams]; layout.rounds.len()],
    };
    for (i, t) in p.judging.iter().enumerate() {
      if let Some(t) = t {
        p.judging_at[*t] = i;
      }
    }
    for (r, round) in p.rounds.iter().enumerate() {
      for (i, t) in round.iter().enumerate() {
        if let Some(t) = t {
          p.round_at[r][*t] = i;
        }
      }
    }
    p
  }

  /// Teams whose penalty depends on these positions: the teams there and the ones facing them.
  fn touched(&self, layout: &Layout, round: Option<usize>, positions: [usize; 2]) -> Vec<usize> {
    let mut teams = Vec::with_capacity(4);
    for position in positions {
      match round {
        None => teams.extend(self.judging[position]),
        Some(r) => {
          teams.extend(self.rounds[r][position]);
          teams.extend(layout.facing(position).and_then(|f| self.rounds[r][f]));
        }
      }
    }
    teams.sort_unstable();
    teams.dedup();
    teams
  }

  fn swap(&mut self, round: Option<usize>, a: usize, b: usize) {
    match round {
      None => {
        self.judging.swap(a, b);
        for i in [a, b] {
          if let Some(t) = self.judging[i] {
            self.judging_at[t] = i;
          }
        }
      }
      Some(r) => {
        self.rounds[r].swap(a, b);
        for i in [a, b] {
          if let Some(t) = self.rounds[r][i] {
            self.round_at[r][t] = i;
          }
        }
      }
    }
  }
}

/// The proposed schedule, and how many hard constraints it still breaks (0 when it can run as is).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Generated {
  pub schedule: ResolvedSchedule,
  pub hard_violations: i64,
  pub penalty: i64,
}

pub fn generate(input: &GenerateInput) -> Result<Generated, GenerateError> {
  if input.teams.is_empty() {
    return Err(GenerateError::Empty("team"));
  }
  if input.tables.is_empty() {
    return Err(GenerateError::Empty("table"));
  }
  if input.pods.is_empty() {
    return Err(GenerateError::Empty("judging pod"));
  }
  if input.match_cycle < input.match_length {
    return Err(GenerateError::Timing(
      "The match cycle must be at least as long as a match.",
    ));
  }
  if input.session_cycle < input.session_length {
    return Err(GenerateError::Timing(
      "The judging cycle must be at least as long as a session.",
    ));
  }
  let n = input.teams.len();
  // Rounds start as short as the tables allow. A round shorter than the time a judging session blocks out (the
  // session plus the gap either side) can leave a team no match it is free for, so a round gains empty matches
  // until every team fits.
  let blocked = input.session_length + input.judging_gap * 2 + input.match_length;
  let tight = n.div_ceil(input.tables.len());
  let roomy = tight.max(
    usize::try_from(
      u64::try_from(blocked.num_seconds())
        .unwrap_or(0)
        .div_ceil(u64::try_from(input.match_cycle.num_seconds()).unwrap_or(1).max(1)),
    )
    .unwrap_or(0)
      + input.pods.len().div_ceil(input.tables.len()),
  );
  let mut result = None;
  for per_round in tight..=roomy {
    let (layout, placement, penalty) = anneal(input, per_round);
    let done = penalty < HARD;
    result = Some((layout, placement, penalty));
    if done {
      break;
    }
  }
  let (layout, placement, penalty) = result.unwrap_or_else(|| anneal(input, tight));
  Ok(Generated {
    hard_violations: penalty / HARD,
    penalty,
    schedule: build(input, &layout, &placement),
  })
}

fn anneal(input: &GenerateInput, per_round: usize) -> (Layout, Placement, i64) {
  let n = input.teams.len();
  let round_count = usize::from(input.practice_rounds) + usize::from(input.ranking_rounds);
  let all_matches = times(
    input.match_start,
    input.match_cycle,
    input.match_length,
    per_round * round_count,
    &input.breaks,
  );
  let layout = Layout {
    teams: n,
    tables: input.tables.len(),
    pods: input.pods.len(),
    rounds: all_matches.chunks(per_round).map(<[_]>::to_vec).collect(),
    sessions: times(
      input.judging_start,
      input.session_cycle,
      input.session_length,
      n.div_ceil(input.pods.len()),
      &input.breaks,
    ),
    ranking_from: usize::from(input.practice_rounds),
    match_length: input.match_length,
    session_length: input.session_length,
    gap: input.judging_gap.num_seconds(),
    rest: TimeDelta::minutes(10).num_seconds(),
  };

  let mut rng = Pcg(input.seed ^ 0x9e37_79b9_7f4a_7c15);
  let mut current = Placement::new(&layout, &mut rng);
  let mut costs: Vec<i64> = (0..n).map(|t| layout.team_penalty(&current, t)).collect();
  let mut total: i64 = costs.iter().sum();
  let mut best = (current.clone(), total);
  let iterations = 3_000 * n.max(10);
  let (hot, cold) = (2_000.0_f64, 0.5_f64);
  for step in 0..iterations {
    if best.1 == 0 {
      break;
    }
    #[allow(clippy::cast_precision_loss)]
    let temperature = hot * (cold / hot).powf(step as f64 / iterations as f64);
    let round = if layout.rounds.is_empty() || rng.below(10) < 3 {
      None
    } else {
      Some(rng.below(layout.rounds.len()))
    };
    let size = round.map_or(current.judging.len(), |r| current.rounds[r].len());
    let (a, b) = (rng.below(size), rng.below(size));
    if a == b {
      continue;
    }
    // The teams at both positions and the teams facing them; the same set before and after the swap.
    let touched = current.touched(&layout, round, [a, b]);
    current.swap(round, a, b);
    let after: Vec<(usize, i64)> = touched
      .iter()
      .map(|t| (*t, layout.team_penalty(&current, *t)))
      .collect();
    let delta: i64 = after.iter().map(|(_, c)| c).sum::<i64>() - touched.iter().map(|t| costs[*t]).sum::<i64>();
    #[allow(clippy::cast_precision_loss)]
    let accept = delta <= 0 || rng.unit() < (-(delta as f64) / temperature).exp();
    if accept {
      for (t, c) in after {
        costs[t] = c;
      }
      total += delta;
      if total < best.1 {
        best = (current.clone(), total);
      }
    } else {
      current.swap(round, a, b);
    }
  }
  let (placement, penalty) = best;
  (layout, placement, penalty)
}

fn build(input: &GenerateInput, layout: &Layout, p: &Placement) -> ResolvedSchedule {
  let number = |t: usize| input.teams[t].number.clone();
  let mut matches: Vec<ResolvedMatch> = Vec::new();
  for (r, round) in layout.rounds.iter().enumerate() {
    let (kind, round_number) = if r < layout.ranking_from {
      (MatchKind::Practice, r + 1)
    } else {
      (MatchKind::Ranking, r + 1 - layout.ranking_from)
    };
    for (m, start) in round.iter().enumerate() {
      let slots: Vec<ResolvedSlot> = (0..layout.tables)
        .filter_map(|table| {
          p.rounds[r][m * layout.tables + table].map(|t| ResolvedSlot {
            column: input.tables[table].clone(),
            team_number: number(t),
            round: i32::try_from(round_number).ok(),
          })
        })
        .collect();
      // A round widened for judging has matches nobody plays; they are left out.
      if slots.is_empty() {
        continue;
      }
      let number = matches.iter().filter(|x| x.kind == kind).count() + 1;
      matches.push(ResolvedMatch {
        kind,
        number: i32::try_from(number).unwrap_or(i32::MAX),
        start: *start,
        end: *start + layout.match_length,
        slots,
      });
    }
  }
  let sessions = layout
    .sessions
    .iter()
    .enumerate()
    .map(|(s, start)| ResolvedSession {
      number: i32::try_from(s + 1).unwrap_or(i32::MAX),
      start: *start,
      end: *start + layout.session_length,
      slots: (0..layout.pods)
        .filter_map(|pod| {
          p.judging[s * layout.pods + pod].map(|t| ResolvedSlot {
            column: input.pods[pod].clone(),
            team_number: number(t),
            round: None,
          })
        })
        .collect(),
    })
    .collect();
  let mut days: Vec<chrono::NaiveDate> = Vec::new();
  for day in [input.match_start.date_naive(), input.judging_start.date_naive()] {
    if !days.contains(&day) {
      days.push(day);
    }
  }
  days.sort();
  ResolvedSchedule {
    teams: input.teams.clone(),
    tables: input.tables.clone(),
    rooms: input.pods.clone(),
    matches,
    sessions,
    days,
    warnings: Vec::new(),
  }
}
