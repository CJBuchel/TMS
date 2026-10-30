//! The robot game: match states, the match timer, scoresheets and ranking. Pure logic, shared by the server
//! (which enforces it) and the client (which shows it).

use chrono::{DateTime, TimeDelta, Utc};
use serde::{Deserialize, Serialize};
use tms_seasons::{Answers, Issue, ScoreResult, Season, Severity};
use uuid::Uuid;

use crate::model::{EventSettings, MatchKind};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[cfg_attr(feature = "sqlx", derive(sqlx::Type))]
#[cfg_attr(feature = "sqlx", sqlx(type_name = "match_state", rename_all = "snake_case"))]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum MatchState {
  Scheduled,
  /// On deck: the next start of the match timer runs it.
  Staged,
  Running,
  Finished,
  Cancelled,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MatchAction {
  Stage,
  Unstage,
  Start,
  Abort,
  End,
  Cancel,
  /// Back to scheduled, to replay a finished match or restore a cancelled one.
  Reset,
}

#[derive(Debug, Clone, PartialEq, Eq, thiserror::Error)]
#[error("a {} match can't be {}", from.label().to_lowercase(), action.past_tense())]
pub struct TransitionError {
  pub from: MatchState,
  pub action: MatchAction,
}

impl MatchState {
  pub fn label(self) -> &'static str {
    match self {
      MatchState::Scheduled => "Scheduled",
      MatchState::Staged => "Staged",
      MatchState::Running => "Running",
      MatchState::Finished => "Finished",
      MatchState::Cancelled => "Cancelled",
    }
  }

  pub fn apply(self, action: MatchAction) -> Result<MatchState, TransitionError> {
    use MatchAction as A;
    use MatchState as S;
    match (self, action) {
      (S::Scheduled, A::Stage) | (S::Running, A::Abort) => Ok(S::Staged),
      (S::Staged, A::Unstage) | (S::Finished | S::Cancelled, A::Reset) => Ok(S::Scheduled),
      (S::Staged, A::Start) => Ok(S::Running),
      (S::Running, A::End) => Ok(S::Finished),
      (S::Scheduled | S::Staged | S::Finished, A::Cancel) => Ok(S::Cancelled),
      _ => Err(TransitionError { from: self, action }),
    }
  }
}

impl MatchAction {
  pub fn past_tense(self) -> &'static str {
    match self {
      MatchAction::Stage => "staged",
      MatchAction::Unstage => "unstaged",
      MatchAction::Start => "started",
      MatchAction::Abort => "aborted",
      MatchAction::End => "ended",
      MatchAction::Cancel => "cancelled",
      MatchAction::Reset => "reset",
    }
  }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "sqlx", derive(sqlx::Type))]
#[cfg_attr(feature = "sqlx", sqlx(type_name = "timer_phase", rename_all = "snake_case"))]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum TimerPhase {
  Idle,
  Countdown,
  Running,
  /// The last part of the match, shown in a warning colour.
  Endgame,
  Ended,
  Aborted,
}

impl TimerPhase {
  pub fn label(self) -> &'static str {
    match self {
      TimerPhase::Idle => "Idle",
      TimerPhase::Countdown => "Countdown",
      TimerPhase::Running => "Running",
      TimerPhase::Endgame => "End game",
      TimerPhase::Ended => "Ended",
      TimerPhase::Aborted => "Aborted",
    }
  }

  /// Countdown, running or end game.
  pub fn is_live(self) -> bool {
    matches!(self, TimerPhase::Countdown | TimerPhase::Running | TimerPhase::Endgame)
  }
}

/// The event's match timer. Live phases follow from `starts_at` and the clock, so every device computes the
/// same time remaining from one message.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct MatchTimer {
  pub event_id: Uuid,
  pub phase: TimerPhase,
  /// Match time zero, after any countdown.
  pub starts_at: Option<DateTime<Utc>>,
  pub countdown_ms: u32,
  pub duration_ms: u32,
  pub endgame_ms: u32,
  /// The matches this run is for.
  pub match_ids: Vec<Uuid>,
}

impl MatchTimer {
  pub fn idle(event_id: Uuid, settings: &EventSettings) -> Self {
    Self {
      event_id,
      phase: TimerPhase::Idle,
      starts_at: None,
      countdown_ms: settings.countdown_seconds * 1000,
      duration_ms: settings.match_seconds * 1000,
      endgame_ms: settings.endgame_seconds * 1000,
      match_ids: Vec::new(),
    }
  }

  pub fn ends_at(&self) -> Option<DateTime<Utc>> {
    self
      .starts_at
      .map(|s| s + TimeDelta::milliseconds(self.duration_ms.into()))
  }

  fn endgame_at(&self) -> Option<DateTime<Utc>> {
    self
      .ends_at()
      .map(|e| e - TimeDelta::milliseconds(self.endgame_ms.into()))
  }

  /// The phase at `now`. Only a live run moves on its own; idle, ended and aborted stay put.
  pub fn phase_at(&self, now: DateTime<Utc>) -> TimerPhase {
    let (Some(starts), Some(endgame), Some(ends)) = (self.starts_at, self.endgame_at(), self.ends_at()) else {
      return self.phase;
    };
    if !self.phase.is_live() {
      return self.phase;
    }
    if now < starts {
      TimerPhase::Countdown
    } else if now < endgame {
      TimerPhase::Running
    } else if now < ends {
      TimerPhase::Endgame
    } else {
      TimerPhase::Ended
    }
  }

  /// What the big clock shows: countdown seconds before the start, match time left during it, the full match
  /// length when idle, and zero when over.
  pub fn display_ms(&self, now: DateTime<Utc>) -> i64 {
    let until = |t: Option<DateTime<Utc>>| t.map_or(0, |t| (t - now).num_milliseconds().max(0));
    match self.phase_at(now) {
      TimerPhase::Idle => self.duration_ms.into(),
      TimerPhase::Countdown => until(self.starts_at),
      TimerPhase::Running | TimerPhase::Endgame => until(self.ends_at()),
      TimerPhase::Ended | TimerPhase::Aborted => 0,
    }
  }

  /// When the phase next changes on its own, and to what.
  pub fn next_change(&self, now: DateTime<Utc>) -> Option<(DateTime<Utc>, TimerPhase)> {
    match self.phase_at(now) {
      TimerPhase::Countdown => self.starts_at.map(|t| (t, TimerPhase::Running)),
      TimerPhase::Running => self.endgame_at().map(|t| (t, TimerPhase::Endgame)),
      TimerPhase::Endgame => self.ends_at().map(|t| (t, TimerPhase::Ended)),
      _ => None,
    }
  }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[cfg_attr(feature = "sqlx", derive(sqlx::Type))]
#[cfg_attr(feature = "sqlx", sqlx(type_name = "scoresheet_status", rename_all = "snake_case"))]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum ScoresheetStatus {
  /// Waiting for the head referee.
  Submitted,
  /// Counts for ranking.
  Published,
  Rejected,
  /// Replaced by a later sheet for the same round.
  Superseded,
}

impl ScoresheetStatus {
  pub fn label(self) -> &'static str {
    match self {
      ScoresheetStatus::Submitted => "Waiting for review",
      ScoresheetStatus::Published => "Published",
      ScoresheetStatus::Rejected => "Rejected",
      ScoresheetStatus::Superseded => "Superseded",
    }
  }
}

/// Why a sheet waits for the head referee even when the event publishes automatically.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum ScoresheetFlag {
  /// The team already has a published sheet for this round.
  DuplicateRound,
  /// The season raised a warning, such as more seeds planted than released.
  Warnings,
  /// The device's total differed from the server's; the server's total was kept.
  ScoreRecomputed,
}

impl ScoresheetFlag {
  pub fn key(self) -> &'static str {
    match self {
      ScoresheetFlag::DuplicateRound => "duplicate_round",
      ScoresheetFlag::Warnings => "warnings",
      ScoresheetFlag::ScoreRecomputed => "score_recomputed",
    }
  }

  pub fn from_key(key: &str) -> Option<Self> {
    [
      ScoresheetFlag::DuplicateRound,
      ScoresheetFlag::Warnings,
      ScoresheetFlag::ScoreRecomputed,
    ]
    .into_iter()
    .find(|f| f.key() == key)
  }

  pub fn label(self) -> &'static str {
    match self {
      ScoresheetFlag::DuplicateRound => "Round already scored",
      ScoresheetFlag::Warnings => "Has warnings",
      ScoresheetFlag::ScoreRecomputed => "Score recomputed",
    }
  }
}

/// A scoresheet as the referee's device writes it. The id is made on the device, so sending it twice is harmless.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct ScoresheetDoc {
  pub id: Uuid,
  pub event_id: Uuid,
  /// The event code shown on the device, kept with the sheet so a sheet from another event is easy to spot.
  pub event_code: String,
  pub season_id: String,
  pub schema_version: u16,
  pub team_number: String,
  /// The scheduled slot this sheet is for, if any. The server takes the kind and round from it.
  pub slot_id: Option<Uuid>,
  pub kind: MatchKind,
  /// Needed when there is no slot.
  pub round: Option<i32>,
  pub table_id: Option<Uuid>,
  pub referee_name: String,
  pub no_show: bool,
  #[cfg_attr(
    feature = "schema",
    schemars(with = "std::collections::BTreeMap<String, serde_json::Value>")
  )]
  pub answers: Answers,
  /// The total the device showed. The server recomputes it.
  pub score: u16,
  /// Gracious Professionalism: 2, 3 or 4.
  pub gp: Option<u8>,
  pub gp_comment: String,
  pub team_agreed: bool,
  pub team_initials: String,
  /// Seen by head referees only.
  pub private_comment: String,
  pub created_at: DateTime<Utc>,
}

impl ScoresheetDoc {
  /// Scores the sheet and adds the event's own rules (GP comment, team sign-off). A no-show sheet has no
  /// answers to check and scores zero.
  pub fn check(&self, season: &Season, settings: &EventSettings) -> ScoreResult {
    let mut result = if self.no_show {
      ScoreResult {
        total: 0,
        missions: Vec::new(),
        issues: Vec::new(),
      }
    } else {
      season.score(&self.answers)
    };
    let mut error = |field: &str, message: &str| {
      result.issues.push(Issue {
        field: field.to_owned(),
        message: message.to_owned(),
        severity: Severity::Error,
      });
    };
    if self.team_number.trim().is_empty() {
      error("team", "Choose a team.");
    }
    if self.no_show {
      return result;
    }
    match self.gp {
      None => error("gp", "Choose a Gracious Professionalism score."),
      Some(2 | 4) if settings.gp_comment_required && self.gp_comment.trim().is_empty() => {
        error("gp", "Add a comment explaining the Gracious Professionalism score.");
      }
      Some(2..=4) => {}
      Some(_) => error("gp", "Gracious Professionalism is 2, 3 or 4."),
    }
    if settings.team_agreement_required && !self.team_agreed {
      error("team_agreed", "The team needs to agree with the scoresheet.");
    }
    result
  }
}

/// A stored scoresheet, as head referees and referees see it.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct Scoresheet {
  pub id: Uuid,
  pub event_id: Uuid,
  pub team_id: Uuid,
  pub team_number: String,
  pub kind: MatchKind,
  pub round: i32,
  pub match_id: Option<Uuid>,
  pub slot_id: Option<Uuid>,
  pub table_id: Option<Uuid>,
  /// The login that sent it: `user:<name>` or `key:<label>`.
  pub submitted_by: String,
  pub referee_name: String,
  pub status: ScoresheetStatus,
  pub flags: Vec<ScoresheetFlag>,
  pub no_show: bool,
  pub score: u16,
  pub gp: Option<u8>,
  pub gp_comment: String,
  #[cfg_attr(
    feature = "schema",
    schemars(with = "std::collections::BTreeMap<String, serde_json::Value>")
  )]
  pub answers: Answers,
  /// Warnings the season raised when the sheet arrived.
  #[cfg_attr(feature = "schema", schemars(with = "Vec<serde_json::Value>"))]
  pub issues: Vec<Issue>,
  pub team_agreed: bool,
  pub team_initials: String,
  pub private_comment: String,
  /// The head referee's note, shown to the referee when a sheet is rejected.
  pub review_note: String,
  pub created_at: DateTime<Utc>,
  pub received_at: DateTime<Utc>,
  pub reviewed_by: Option<String>,
  pub reviewed_at: Option<DateTime<Utc>>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct SyncScoresheetsRequest {
  pub documents: Vec<ScoresheetDoc>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(tag = "outcome", rename_all = "snake_case")]
pub enum SyncOutcome<S = ScoresheetStatus> {
  /// Stored. `status` says whether it counts yet.
  Accepted { status: S },
  /// Already stored earlier; treat as accepted.
  Duplicate { status: S },
  /// Stored nowhere: the server can't tell which team or round it is for. Fix the sheet and send it again.
  NeedsBinding { reason: String },
  /// Stored nowhere: the sheet is wrong for this event or has errors.
  Rejected {
    code: String,
    message: String,
    #[cfg_attr(feature = "schema", schemars(with = "Vec<serde_json::Value>"))]
    issues: Vec<Issue>,
  },
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct SyncResult<S = ScoresheetStatus> {
  pub id: Uuid,
  #[serde(flatten)]
  pub outcome: SyncOutcome<S>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct SyncScoresheetsResponse {
  pub results: Vec<SyncResult>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Default)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct StageRequest {
  /// Stage even though an earlier match on the same tables still has a team without a scoresheet.
  #[serde(default)]
  pub force: bool,
  #[serde(default)]
  pub reason: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Default)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct TimerStartRequest {
  /// Run the event's countdown before the match starts.
  #[serde(default)]
  pub countdown: bool,
  /// Start although some teams are not ready (head referee only).
  #[serde(default)]
  pub force: bool,
  #[serde(default)]
  pub reason: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Default)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct ReviewRequest {
  /// Required when rejecting; shown to the referee.
  #[serde(default)]
  pub note: String,
}

/// One team's line on the scoreboard.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct RankingRow {
  pub team_id: Uuid,
  /// Competition ranking: tied teams share a rank and the next rank is skipped (1, 1, 3).
  pub rank: u32,
  /// One entry per ranking round; `None` until the round has a published score.
  pub scores: Vec<Option<u16>>,
  pub best: Option<u16>,
}

/// One published ranking-round result. A no-show has no score.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct RoundResult {
  pub team_id: Uuid,
  pub round: i32,
  pub score: Option<u16>,
}

/// Ranks teams by best score, then second best, then third best, as the FLL robot game does. A round with no
/// score counts as zero for ranking. `teams` sets the order of tied teams (pass them in team number order).
pub fn rank(teams: &[Uuid], rounds: u8, results: &[RoundResult]) -> Vec<RankingRow> {
  let mut rows: Vec<(RankingRow, Vec<u16>)> = teams
    .iter()
    .map(|&team_id| {
      let mut scores = vec![None; rounds.into()];
      for r in results.iter().filter(|r| r.team_id == team_id) {
        if let Some(slot) = usize::try_from(r.round - 1).ok().and_then(|i| scores.get_mut(i)) {
          *slot = r.score;
        }
      }
      let mut key: Vec<u16> = scores.iter().map(|s| s.unwrap_or(0)).collect();
      key.sort_unstable_by(|a, b| b.cmp(a));
      let best = scores.iter().flatten().max().copied();
      (
        RankingRow {
          team_id,
          rank: 0,
          scores,
          best,
        },
        key,
      )
    })
    .collect();
  rows.sort_by(|a, b| b.1.cmp(&a.1));
  for i in 0..rows.len() {
    rows[i].0.rank = if i > 0 && rows[i].1 == rows[i - 1].1 {
      rows[i - 1].0.rank
    } else {
      u32::try_from(i + 1).unwrap_or(u32::MAX)
    };
  }
  rows.into_iter().map(|(row, _)| row).collect()
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn match_transitions() {
    use MatchAction as A;
    use MatchState as S;
    assert_eq!(S::Scheduled.apply(A::Stage), Ok(S::Staged));
    assert_eq!(S::Staged.apply(A::Start), Ok(S::Running));
    assert_eq!(S::Running.apply(A::Abort), Ok(S::Staged));
    assert_eq!(S::Running.apply(A::End), Ok(S::Finished));
    assert_eq!(S::Finished.apply(A::Reset), Ok(S::Scheduled));
    assert!(S::Running.apply(A::Cancel).is_err(), "abort a running match first");
    assert!(S::Scheduled.apply(A::Start).is_err(), "stage before starting");
    assert_eq!(
      S::Finished.apply(A::Stage).unwrap_err().to_string(),
      "a finished match can't be staged"
    );
  }

  fn timer(phase: TimerPhase) -> MatchTimer {
    MatchTimer {
      event_id: Uuid::nil(),
      phase,
      starts_at: Some(DateTime::from_timestamp(1_000, 0).unwrap()),
      countdown_ms: 5_000,
      duration_ms: 150_000,
      endgame_ms: 30_000,
      match_ids: Vec::new(),
    }
  }

  #[test]
  fn timer_phases_follow_the_clock() {
    let t = timer(TimerPhase::Countdown);
    let at = |s: i64| DateTime::from_timestamp(s, 0).unwrap();
    assert_eq!(t.phase_at(at(997)), TimerPhase::Countdown);
    assert_eq!(t.display_ms(at(997)), 3_000);
    assert_eq!(t.phase_at(at(1_000)), TimerPhase::Running);
    assert_eq!(t.display_ms(at(1_000)), 150_000);
    assert_eq!(t.phase_at(at(1_120)), TimerPhase::Endgame);
    assert_eq!(t.phase_at(at(1_150)), TimerPhase::Ended);
    assert_eq!(t.display_ms(at(1_200)), 0);
    assert_eq!(t.next_change(at(1_010)), Some((at(1_120), TimerPhase::Endgame)));
    assert_eq!(timer(TimerPhase::Aborted).phase_at(at(1_010)), TimerPhase::Aborted);
  }

  fn result(team: u128, round: i32, score: Option<u16>) -> RoundResult {
    RoundResult {
      team_id: Uuid::from_u128(team),
      round,
      score,
    }
  }

  #[test]
  fn ranking_breaks_ties_on_second_and_third_best() {
    let teams: Vec<Uuid> = (1..=5).map(Uuid::from_u128).collect();
    let results = [
      result(1, 1, Some(200)),
      result(1, 2, Some(150)),
      result(2, 1, Some(150)),
      result(2, 2, Some(200)),
      result(2, 3, Some(10)),
      result(3, 1, Some(200)),
      result(3, 2, Some(150)),
      result(4, 1, None),
      result(4, 2, Some(300)),
    ];
    let rows = rank(&teams, 3, &results);
    let order: Vec<(u128, u32)> = rows.iter().map(|r| (r.team_id.as_u128(), r.rank)).collect();
    assert_eq!(order, [(4, 1), (2, 2), (1, 3), (3, 3), (5, 5)]);
    assert_eq!(rows[0].scores, [None, Some(300), None]);
    assert_eq!(rows[0].best, Some(300));
    assert_eq!(rows[4].best, None);
  }

  #[test]
  fn sheet_rules_from_event_settings() {
    let season = tms_seasons::by_id("bioglow_founders").unwrap();
    let mut answers = season.defaults();
    answers.insert("m15d".into(), tms_seasons::Answer::Choice("city".into()));
    let mut doc = ScoresheetDoc {
      id: Uuid::nil(),
      event_id: Uuid::nil(),
      event_code: "E".into(),
      season_id: season.id.into(),
      schema_version: season.schema_version,
      team_number: "101".into(),
      slot_id: None,
      kind: MatchKind::Ranking,
      round: Some(1),
      table_id: None,
      referee_name: String::new(),
      no_show: false,
      answers,
      score: 70,
      gp: Some(4),
      gp_comment: String::new(),
      team_agreed: false,
      team_initials: String::new(),
      private_comment: String::new(),
      created_at: Utc::now(),
    };
    let settings = EventSettings::default();
    let fields: Vec<String> = doc
      .check(season, &settings)
      .issues
      .into_iter()
      .map(|i| i.field)
      .collect();
    assert_eq!(fields, ["gp", "team_agreed"]);
    doc.gp_comment = "Helped the other team reset".into();
    doc.team_agreed = true;
    assert_eq!(doc.check(season, &settings).issues, vec![]);
    doc.no_show = true;
    doc.gp = None;
    let no_show = doc.check(season, &settings);
    assert_eq!((no_show.total, no_show.issues.len()), (0, 0));
  }
}
