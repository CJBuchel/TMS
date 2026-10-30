//! Schedule checks. One pure function per check, shared by the schedule generator, the manual editor and the issue
//! list. Checks run per scope: a team's checks look only at that team's matches and sessions, and the event's
//! checks look at tables, pods and the timetable. An edit re-runs only the scopes it touches.

use std::collections::{BTreeSet, HashMap};
use std::hash::{DefaultHasher, Hash, Hasher};

use chrono::{DateTime, TimeDelta, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::model::{
  BlockKind, EventSettings, GameMatch, GameTable, JudgingSession, MatchKind, MatchState, ScheduleBlock, Team,
};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum IssueSeverity {
  /// The schedule can't run as written.
  Error,
  /// It can run, but a team or volunteer will have a worse day.
  Warning,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum IssueCode {
  /// A team is in two places at once.
  Overlap,
  /// A team's match is too close to its judging session.
  JudgingGap,
  /// A team has more or fewer ranking matches than the event has rounds.
  RankingCount,
  NoJudging,
  ExtraJudging,
  /// Two matches use one table at the same time.
  TableClash,
  /// Two sessions use one pod at the same time.
  PodClash,
  /// A team's matches follow each other with little time between.
  BackToBack,
  /// A team meets the same opponent in more than one ranking match.
  SameOpponent,
  /// A match or session is scheduled during a break, ceremony or meeting.
  BlockOverlap,
}

/// One problem with the schedule. Its id follows from what it is about, so the same problem keeps its id.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct ScheduleIssue {
  pub id: Uuid,
  pub code: IssueCode,
  pub severity: IssueSeverity,
  /// The team this is about; `None` for event-wide issues such as a table used twice at once.
  pub team_id: Option<Uuid>,
  /// Matches and sessions involved.
  pub refs: Vec<Uuid>,
  pub message: String,
}

impl ScheduleIssue {
  fn new(code: IssueCode, severity: IssueSeverity, team_id: Option<Uuid>, refs: Vec<Uuid>, message: String) -> Self {
    let mut h = DefaultHasher::new();
    (code, team_id, &refs).hash(&mut h);
    let a = h.finish();
    (a, "issue").hash(&mut h);
    Self {
      id: Uuid::from_u128((u128::from(a) << 64) | u128::from(h.finish())),
      code,
      severity,
      team_id,
      refs,
      message,
    }
  }
}

/// What the checks are measured against.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Rules {
  /// Least time between a team's judging session and any of its matches.
  pub judging_gap: TimeDelta,
  pub ranking_rounds: u8,
  /// Less time than this between the end of one match and the start of a team's next is back to back.
  pub match_rest: TimeDelta,
}

impl Rules {
  pub fn from_settings(s: &EventSettings) -> Self {
    Self {
      judging_gap: TimeDelta::minutes(i64::from(s.judging_match_gap_minutes)),
      ranking_rounds: s.ranking_rounds,
      match_rest: TimeDelta::minutes(10),
    }
  }
}

/// Something a team does at a set time.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Activity {
  pub id: Uuid,
  pub label: String,
  pub start: DateTime<Utc>,
  pub end: DateTime<Utc>,
  /// `None` for a judging session.
  pub match_kind: Option<MatchKind>,
  /// For ranking matches: the team at the paired table.
  pub opponent: Option<Uuid>,
}

fn overlaps(a_start: DateTime<Utc>, a_end: DateTime<Utc>, b_start: DateTime<Utc>, b_end: DateTime<Utc>) -> bool {
  a_start < b_end && b_start < a_end
}

/// The time between two activities that don't overlap.
fn distance(a: &Activity, b: &Activity) -> TimeDelta {
  if a.end <= b.start {
    b.start - a.end
  } else {
    a.start - b.end
  }
}

/// A schedule as the checks see it.
#[derive(Debug, Clone, Default)]
pub struct ScheduleView {
  pub teams: Vec<(Uuid, String)>,
  /// Tables in their paired order: 0 faces 1, 2 faces 3.
  pub tables: Vec<Uuid>,
  pub matches: Vec<GameMatch>,
  pub sessions: Vec<JudgingSession>,
  pub blocks: Vec<ScheduleBlock>,
}

impl ScheduleView {
  pub fn new(
    teams: &[Team],
    tables: &[GameTable],
    matches: &[GameMatch],
    sessions: &[JudgingSession],
    blocks: &[ScheduleBlock],
  ) -> Self {
    let mut ordered: Vec<&GameTable> = tables.iter().collect();
    ordered.sort_by_key(|t| (t.sort_order, t.name.clone()));
    Self {
      teams: teams.iter().map(|t| (t.id, t.number.clone())).collect(),
      tables: ordered.into_iter().map(|t| t.id).collect(),
      matches: matches
        .iter()
        .filter(|m| m.state != MatchState::Cancelled)
        .cloned()
        .collect(),
      sessions: sessions.to_vec(),
      blocks: blocks.to_vec(),
    }
  }

  pub fn number(&self, team_id: Uuid) -> String {
    self
      .teams
      .iter()
      .find(|(id, _)| *id == team_id)
      .map_or_else(|| "?".into(), |(_, n)| n.clone())
  }

  fn paired(&self, table: Uuid) -> Option<Uuid> {
    let i = self.tables.iter().position(|t| *t == table)?;
    self.tables.get(i ^ 1).copied()
  }

  /// A team's matches and sessions, in time order.
  pub fn activities(&self, team_id: Uuid) -> Vec<Activity> {
    let mut all = Vec::new();
    for m in &self.matches {
      for slot in m.slots.iter().filter(|s| s.team_id == Some(team_id)) {
        let opponent = self
          .paired(slot.table_id)
          .and_then(|t| m.slots.iter().find(|s| s.table_id == t))
          .and_then(|s| s.team_id);
        all.push(Activity {
          id: m.id,
          label: m.label(),
          start: m.scheduled_start,
          end: m.scheduled_end,
          match_kind: Some(m.kind),
          opponent,
        });
      }
    }
    for s in &self.sessions {
      if s.slots.iter().any(|slot| slot.team_id == Some(team_id)) {
        all.push(Activity {
          id: s.id,
          label: format!("Judging {}", s.number),
          start: s.scheduled_start,
          end: s.scheduled_end,
          match_kind: None,
          opponent: None,
        });
      }
    }
    all.sort_by_key(|a| (a.start, a.end));
    all
  }

  /// Teams with a slot in any of these matches or sessions.
  pub fn teams_in(&self, refs: &[Uuid]) -> BTreeSet<Uuid> {
    let from_matches = self
      .matches
      .iter()
      .filter(|m| refs.contains(&m.id))
      .flat_map(|m| m.slots.iter().filter_map(|s| s.team_id));
    let from_sessions = self
      .sessions
      .iter()
      .filter(|s| refs.contains(&s.id))
      .flat_map(|s| s.slots.iter().filter_map(|slot| slot.team_id));
    from_matches.chain(from_sessions).collect()
  }
}

/// Every issue about one team.
pub fn team_issues(view: &ScheduleView, rules: &Rules, team_id: Uuid) -> Vec<ScheduleIssue> {
  let number = view.number(team_id);
  let acts = view.activities(team_id);
  let mut issues = Vec::new();
  let mut push = |code, severity, refs: Vec<Uuid>, message: String| {
    issues.push(ScheduleIssue::new(code, severity, Some(team_id), refs, message));
  };
  for (i, a) in acts.iter().enumerate() {
    for b in &acts[i + 1..] {
      if overlaps(a.start, a.end, b.start, b.end) {
        push(
          IssueCode::Overlap,
          IssueSeverity::Error,
          vec![a.id, b.id],
          format!("Team {number} is in {} and {} at the same time.", a.label, b.label),
        );
      } else if (a.match_kind.is_none() != b.match_kind.is_none()) && distance(a, b) < rules.judging_gap {
        push(
          IssueCode::JudgingGap,
          IssueSeverity::Error,
          vec![a.id, b.id],
          format!(
            "Team {number} has {} minutes between {} and {}; the event needs {}.",
            distance(a, b).num_minutes(),
            a.label,
            b.label,
            rules.judging_gap.num_minutes()
          ),
        );
      }
    }
  }
  let matches: Vec<&Activity> = acts.iter().filter(|a| a.match_kind.is_some()).collect();
  for pair in matches.windows(2) {
    let (a, b) = (pair[0], pair[1]);
    if !overlaps(a.start, a.end, b.start, b.end) && b.start - a.end < rules.match_rest {
      push(
        IssueCode::BackToBack,
        IssueSeverity::Warning,
        vec![a.id, b.id],
        format!(
          "Team {number} has only {} minutes between {} and {}.",
          (b.start - a.end).num_minutes(),
          a.label,
          b.label
        ),
      );
    }
  }
  let ranking: Vec<&Activity> = acts
    .iter()
    .filter(|a| a.match_kind == Some(MatchKind::Ranking))
    .collect();
  if ranking.len() != usize::from(rules.ranking_rounds) {
    push(
      IssueCode::RankingCount,
      IssueSeverity::Error,
      ranking.iter().map(|a| a.id).collect(),
      format!(
        "Team {number} has {} ranking match(es); the event has {} rounds.",
        ranking.len(),
        rules.ranking_rounds
      ),
    );
  }
  let mut seen: HashMap<Uuid, Uuid> = HashMap::new();
  for a in &ranking {
    let Some(opponent) = a.opponent else { continue };
    if let Some(first) = seen.insert(opponent, a.id) {
      push(
        IssueCode::SameOpponent,
        IssueSeverity::Warning,
        vec![first, a.id],
        format!(
          "Team {number} meets team {} in two ranking matches.",
          view.number(opponent)
        ),
      );
    }
  }
  let judging: Vec<&Activity> = acts.iter().filter(|a| a.match_kind.is_none()).collect();
  if judging.is_empty() && !view.sessions.is_empty() {
    push(
      IssueCode::NoJudging,
      IssueSeverity::Error,
      Vec::new(),
      format!("Team {number} has no judging session."),
    );
  } else if judging.len() > 1 {
    push(
      IssueCode::ExtraJudging,
      IssueSeverity::Warning,
      judging.iter().map(|a| a.id).collect(),
      format!("Team {number} has {} judging sessions.", judging.len()),
    );
  }
  issues
}

/// Issues about the event as a whole: tables and pods used twice at once, and matches or sessions in a break.
pub fn event_issues(view: &ScheduleView) -> Vec<ScheduleIssue> {
  let mut issues = Vec::new();
  for (i, a) in view.matches.iter().enumerate() {
    for b in &view.matches[i + 1..] {
      if !overlaps(a.scheduled_start, a.scheduled_end, b.scheduled_start, b.scheduled_end) {
        continue;
      }
      let used = |m: &GameMatch| -> BTreeSet<Uuid> {
        m.slots
          .iter()
          .filter(|s| s.team_id.is_some())
          .map(|s| s.table_id)
          .collect()
      };
      if !used(a).is_disjoint(&used(b)) {
        issues.push(ScheduleIssue::new(
          IssueCode::TableClash,
          IssueSeverity::Error,
          None,
          vec![a.id, b.id],
          format!("{} and {} use the same table at the same time.", a.label(), b.label()),
        ));
      }
    }
  }
  for (i, a) in view.sessions.iter().enumerate() {
    for b in &view.sessions[i + 1..] {
      if !overlaps(a.scheduled_start, a.scheduled_end, b.scheduled_start, b.scheduled_end) {
        continue;
      }
      let used = |s: &JudgingSession| -> BTreeSet<Uuid> {
        s.slots
          .iter()
          .filter(|x| x.team_id.is_some())
          .map(|x| x.pod_id)
          .collect()
      };
      if !used(a).is_disjoint(&used(b)) {
        issues.push(ScheduleIssue::new(
          IssueCode::PodClash,
          IssueSeverity::Error,
          None,
          vec![a.id, b.id],
          format!(
            "Judging {} and {} use the same pod at the same time.",
            a.number, b.number
          ),
        ));
      }
    }
  }
  for block in view.blocks.iter().filter(|b| b.kind != BlockKind::Other) {
    let clashes = view
      .matches
      .iter()
      .filter(|m| m.slots.iter().any(|s| s.team_id.is_some()))
      .filter(|m| overlaps(m.scheduled_start, m.scheduled_end, block.starts_at, block.ends_at))
      .map(|m| (m.id, m.label()))
      .chain(
        view
          .sessions
          .iter()
          .filter(|s| s.slots.iter().any(|x| x.team_id.is_some()))
          .filter(|s| overlaps(s.scheduled_start, s.scheduled_end, block.starts_at, block.ends_at))
          .map(|s| (s.id, format!("Judging {}", s.number))),
      );
    for (id, label) in clashes {
      issues.push(ScheduleIssue::new(
        IssueCode::BlockOverlap,
        IssueSeverity::Warning,
        None,
        vec![id, block.id],
        format!("{label} is during {}.", block.name),
      ));
    }
  }
  issues
}

/// Every issue in the schedule: each team's, then the event's.
pub fn all_issues(view: &ScheduleView, rules: &Rules) -> Vec<ScheduleIssue> {
  let mut issues: Vec<ScheduleIssue> = view
    .teams
    .iter()
    .flat_map(|(id, _)| team_issues(view, rules, *id))
    .collect();
  issues.extend(event_issues(view));
  issues
}

/// Errors in `after` that `before` didn't have, for the scopes an edit touched. An edit is refused when this is not
/// empty, unless forced.
pub fn new_errors(before: &[ScheduleIssue], after: &[ScheduleIssue]) -> Vec<ScheduleIssue> {
  after
    .iter()
    .filter(|i| i.severity == IssueSeverity::Error && !before.iter().any(|b| b.id == i.id))
    .cloned()
    .collect()
}

/// The issues of the given teams plus the event's, which is what an edit touching those teams can change. A team
/// that is no longer in the event has none.
pub fn scoped_issues(view: &ScheduleView, rules: &Rules, teams: &BTreeSet<Uuid>) -> Vec<ScheduleIssue> {
  let mut issues: Vec<ScheduleIssue> = teams
    .iter()
    .filter(|t| view.teams.iter().any(|(id, _)| id == *t))
    .flat_map(|t| team_issues(view, rules, *t))
    .collect();
  issues.extend(event_issues(view));
  issues
}

#[cfg(test)]
mod tests {
  use chrono::TimeZone;

  use super::*;
  use crate::model::{JudgingSlot, MatchSlot, QueueState};

  fn at(minute: i64) -> DateTime<Utc> {
    Utc.with_ymd_and_hms(2026, 11, 14, 9, 0, 0).unwrap() + TimeDelta::minutes(minute)
  }

  fn id(n: u128) -> Uuid {
    Uuid::from_u128(n)
  }

  fn game(n: u128, start: i64, teams: [Option<u128>; 2]) -> GameMatch {
    GameMatch {
      id: id(100 + n),
      event_id: Uuid::nil(),
      kind: MatchKind::Ranking,
      number: i32::try_from(n).unwrap(),
      scheduled_start: at(start),
      scheduled_end: at(start + 3),
      state: MatchState::Scheduled,
      started_at: None,
      finished_at: None,
      slots: teams
        .iter()
        .enumerate()
        .map(|(t, team)| MatchSlot {
          id: Uuid::now_v7(),
          table_id: id(10 + u128::try_from(t).unwrap()),
          team_id: team.map(id),
          round: None,
          sheet: None,
          queue: QueueState::NotCalled,
          queue_previous: None,
          queue_changed_at: None,
        })
        .collect(),
    }
  }

  fn session(n: u128, start: i64, team: u128) -> JudgingSession {
    JudgingSession {
      id: id(200 + n),
      event_id: Uuid::nil(),
      number: i32::try_from(n).unwrap(),
      scheduled_start: at(start),
      scheduled_end: at(start + 30),
      slots: vec![JudgingSlot {
        id: Uuid::now_v7(),
        pod_id: id(20),
        team_id: Some(id(team)),
        queue: QueueState::NotCalled,
        queue_previous: None,
        rubric: None,
      }],
    }
  }

  fn view(matches: Vec<GameMatch>, sessions: Vec<JudgingSession>) -> ScheduleView {
    ScheduleView {
      teams: vec![(id(1), "1".into()), (id(2), "2".into())],
      tables: vec![id(10), id(11)],
      matches,
      sessions,
      blocks: Vec::new(),
    }
  }

  const RULES: Rules = Rules {
    judging_gap: TimeDelta::minutes(15),
    ranking_rounds: 2,
    match_rest: TimeDelta::minutes(10),
  };

  fn codes(issues: &[ScheduleIssue]) -> Vec<IssueCode> {
    let mut c: Vec<IssueCode> = issues.iter().map(|i| i.code).collect();
    c.sort();
    c
  }

  #[test]
  fn a_clean_schedule_has_no_issues() {
    let v = view(
      vec![
        game(1, 0, [Some(1), Some(2)]),
        game(2, 75, [Some(2), None]),
        game(3, 120, [None, Some(1)]),
      ],
      vec![session(1, 25, 2), session(2, 70, 1)],
    );
    assert_eq!(all_issues(&v, &RULES), Vec::new());
  }

  #[test]
  fn team_checks() {
    let v = view(
      vec![game(1, 0, [Some(1), Some(2)]), game(2, 8, [Some(2), Some(1)])],
      vec![session(1, 10, 1)],
    );
    let one = team_issues(&v, &RULES, id(1));
    assert_eq!(
      codes(&one),
      [
        IssueCode::Overlap,
        IssueCode::JudgingGap,
        IssueCode::BackToBack,
        IssueCode::SameOpponent
      ]
    );
    assert!(
      one
        .iter()
        .find(|i| i.code == IssueCode::JudgingGap)
        .unwrap()
        .message
        .contains("7 minutes")
    );
    let two = team_issues(&v, &RULES, id(2));
    assert_eq!(
      codes(&two),
      [IssueCode::NoJudging, IssueCode::BackToBack, IssueCode::SameOpponent]
    );
  }

  #[test]
  fn event_checks_and_stable_ids() {
    let mut v = view(
      vec![game(1, 0, [Some(1), None]), game(2, 2, [Some(2), None])],
      vec![session(1, 60, 1), session(2, 70, 2)],
    );
    let issues = event_issues(&v);
    assert_eq!(codes(&issues), [IssueCode::TableClash, IssueCode::PodClash]);
    assert_eq!(event_issues(&v)[0].id, issues[0].id, "the same problem keeps its id");
    v.matches[1].slots[0].team_id = None;
    v.matches[1].slots[1].team_id = Some(id(2));
    let after = event_issues(&v);
    assert_eq!(codes(&new_errors(&issues, &after)), Vec::<IssueCode>::new());
    assert_eq!(codes(&after), [IssueCode::PodClash]);
  }
}
