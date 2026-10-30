//! Event data that the server stores and pushes over the live feed: teams, venue, schedule.

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

pub use crate::game::{MatchState, ScoresheetStatus};
pub use crate::queue::QueueState;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct Team {
  pub id: Uuid,
  pub event_id: Uuid,
  /// The team's FIRST number, as text ("1234").
  pub number: String,
  pub name: String,
  pub affiliation: String,
  pub pit: Option<String>,
  pub notes: String,
}

/// A competition table. Tables play in pairs by `sort_order`: positions 0 and 1 face each other, then 2 and 3.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct GameTable {
  pub id: Uuid,
  pub event_id: Uuid,
  pub name: String,
  pub sort_order: i32,
}

/// A judging room or group of judges.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct Pod {
  pub id: Uuid,
  pub event_id: Uuid,
  pub name: String,
  pub room: Option<String>,
  pub sort_order: i32,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[cfg_attr(feature = "sqlx", derive(sqlx::Type))]
#[cfg_attr(feature = "sqlx", sqlx(type_name = "match_kind", rename_all = "snake_case"))]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum MatchKind {
  Practice,
  Ranking,
}

impl MatchKind {
  pub fn label(self) -> &'static str {
    match self {
      MatchKind::Practice => "Practice",
      MatchKind::Ranking => "Ranking",
    }
  }
}

/// One team at one table in one match.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct MatchSlot {
  pub id: Uuid,
  pub table_id: Uuid,
  pub team_id: Option<Uuid>,
  /// Which of the team's matches of this kind this is: 1 for its first ranking match, and so on.
  pub round: Option<i32>,
  /// The slot's scoresheet: published if there is one, otherwise one waiting for review. Scores are not shown here,
  /// because this topic is public.
  pub sheet: Option<ScoresheetStatus>,
  /// Where the team is on its way to this match.
  pub queue: QueueState,
  /// The state before the last change, which undo returns to.
  pub queue_previous: Option<QueueState>,
  pub queue_changed_at: Option<DateTime<Utc>>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct GameMatch {
  pub id: Uuid,
  pub event_id: Uuid,
  pub kind: MatchKind,
  pub number: i32,
  pub scheduled_start: DateTime<Utc>,
  pub scheduled_end: DateTime<Utc>,
  pub state: MatchState,
  pub started_at: Option<DateTime<Utc>>,
  pub finished_at: Option<DateTime<Utc>>,
  pub slots: Vec<MatchSlot>,
}

impl GameMatch {
  pub fn label(&self) -> String {
    format!("{} {}", self.kind.label(), self.number)
  }

  /// Finished, with a team that played and has no scoresheet yet.
  pub fn is_unscored(&self) -> bool {
    self.state == MatchState::Finished && self.slots.iter().any(MatchSlot::needs_sheet)
  }

  /// Teams still holding up the start: every slot with a team must be ready, a no-show or scratched.
  pub fn not_ready(&self) -> impl Iterator<Item = &MatchSlot> {
    self
      .slots
      .iter()
      .filter(|s| s.team_id.is_some() && !s.queue.lets_match_start())
  }
}

impl MatchSlot {
  /// A team played here (it was not a no-show or scratched) and there is no scoresheet yet.
  pub fn needs_sheet(&self) -> bool {
    self.team_id.is_some() && self.sheet.is_none() && !self.queue.is_out()
  }
}

/// One team in one pod in one judging session.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct JudgingSlot {
  pub id: Uuid,
  pub pod_id: Uuid,
  pub team_id: Option<Uuid>,
  /// Where the team is: called, outside the room (`waiting`), in the room (`at_table`), in session
  /// (`running`), done, or a no-show.
  pub queue: QueueState,
  pub queue_previous: Option<QueueState>,
  /// The team's rubric status: accepted if there is one, otherwise one waiting for review.
  pub rubric: Option<crate::judging::RubricStatus>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct JudgingSession {
  pub id: Uuid,
  pub event_id: Uuid,
  pub number: i32,
  pub scheduled_start: DateTime<Utc>,
  pub scheduled_end: DateTime<Utc>,
  pub slots: Vec<JudgingSlot>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "sqlx", derive(sqlx::Type))]
#[cfg_attr(feature = "sqlx", sqlx(type_name = "block_kind", rename_all = "snake_case"))]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum BlockKind {
  Break,
  Ceremony,
  Meeting,
  Other,
}

impl BlockKind {
  pub const ALL: [BlockKind; 4] = [
    BlockKind::Break,
    BlockKind::Ceremony,
    BlockKind::Meeting,
    BlockKind::Other,
  ];

  pub fn label(self) -> &'static str {
    match self {
      BlockKind::Break => "Break",
      BlockKind::Ceremony => "Ceremony",
      BlockKind::Meeting => "Meeting",
      BlockKind::Other => "Other",
    }
  }

  pub fn key(self) -> &'static str {
    match self {
      BlockKind::Break => "break",
      BlockKind::Ceremony => "ceremony",
      BlockKind::Meeting => "meeting",
      BlockKind::Other => "other",
    }
  }

  pub fn from_key(key: &str) -> Option<Self> {
    Self::ALL.into_iter().find(|k| k.key() == key)
  }
}

/// Something on the event timetable that is not a match or judging session: lunch, opening ceremony, briefings.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct ScheduleBlock {
  pub id: Uuid,
  pub event_id: Uuid,
  pub kind: BlockKind,
  pub name: String,
  pub starts_at: DateTime<Utc>,
  pub ends_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum ScoresheetReview {
  /// Valid sheets count straight away; the head referee sees flagged ones.
  #[default]
  AutoPublish,
  /// Every sheet waits for the head referee.
  HeadRefereeReview,
}

/// Per-event rules and timings. Stored as JSON on the event; missing fields take their defaults, so new
/// settings never break older events.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(default)]
pub struct EventSettings {
  pub match_seconds: u32,
  pub endgame_seconds: u32,
  pub countdown_seconds: u32,
  pub ranking_rounds: u8,
  pub practice_rounds: u8,
  pub scoresheet_review: ScoresheetReview,
  /// A Gracious Professionalism score other than 3 needs a comment.
  pub gp_comment_required: bool,
  /// The team confirms the scoresheet before it is submitted.
  pub team_agreement_required: bool,
  pub judging_session_minutes: u32,
  pub judging_buffer_minutes: u32,
  /// Minimum time between a team's judging session and any of its matches, used by schedule checks.
  pub judging_match_gap_minutes: u32,
  /// The match timer only starts once every team is ready, a no-show or scratched (the head referee can override).
  pub start_needs_ready: bool,
  /// How far ahead of a match a team should be queueing: its status becomes "Queue now".
  pub queue_call_minutes: u32,
  /// How far ahead of a match a team is shown as "Soon", so queuers can find it before it is due.
  pub queue_soon_minutes: u32,
  /// Whether rubrics count straight away (a second one for a team waits) or wait for the judge advisor.
  pub rubric_review: RubricReview,
  /// How many teams advance to the next level of competition; 0 when none do.
  pub advancement_slots: u32,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum RubricReview {
  #[default]
  Auto,
  JudgeAdvisorReview,
}

impl Default for EventSettings {
  fn default() -> Self {
    Self {
      match_seconds: 150,
      endgame_seconds: 30,
      countdown_seconds: 5,
      ranking_rounds: 3,
      practice_rounds: 1,
      scoresheet_review: ScoresheetReview::AutoPublish,
      gp_comment_required: true,
      team_agreement_required: true,
      judging_session_minutes: 30,
      judging_buffer_minutes: 15,
      judging_match_gap_minutes: 15,
      start_needs_ready: true,
      queue_call_minutes: 10,
      queue_soon_minutes: 20,
      rubric_review: RubricReview::Auto,
      advancement_slots: 0,
    }
  }
}

impl EventSettings {
  /// Problems that make the settings unusable, as user-facing messages.
  pub fn problems(&self) -> Vec<String> {
    let mut problems = Vec::new();
    if !(30..=600).contains(&self.match_seconds) {
      problems.push("Match length must be between 30 and 600 seconds.".to_owned());
    }
    if self.endgame_seconds >= self.match_seconds {
      problems.push("End game must start before the match ends.".to_owned());
    }
    if self.countdown_seconds > 30 {
      problems.push("Countdown can be at most 30 seconds.".to_owned());
    }
    if !(1..=10).contains(&self.ranking_rounds) {
      problems.push("Ranking rounds must be between 1 and 10.".to_owned());
    }
    if self.practice_rounds > 5 {
      problems.push("Practice rounds can be at most 5.".to_owned());
    }
    if !(1..=120).contains(&self.queue_call_minutes) {
      problems.push("Queue calling must start between 1 and 120 minutes before a match.".to_owned());
    }
    if self.queue_soon_minutes < self.queue_call_minutes || self.queue_soon_minutes > 240 {
      problems
        .push("\"Soon\" must start no later than \"Queue now\", and at most 240 minutes before a match.".to_owned());
    }
    if !(5..=120).contains(&self.judging_session_minutes) {
      problems.push("A judging session must be between 5 and 120 minutes.".to_owned());
    }
    if self.advancement_slots > 200 {
      problems.push("At most 200 teams can advance.".to_owned());
    }
    problems
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn settings_fill_missing_fields_with_defaults() {
    let parsed: EventSettings = serde_json::from_str(r#"{"match_seconds": 120}"#).unwrap();
    assert_eq!(parsed.match_seconds, 120);
    assert_eq!(parsed.endgame_seconds, 30);
    assert_eq!(
      serde_json::from_str::<EventSettings>("{}").unwrap(),
      EventSettings::default()
    );
  }

  #[test]
  fn settings_problems() {
    assert_eq!(EventSettings::default().problems(), Vec::<String>::new());
    let bad = EventSettings {
      endgame_seconds: 200,
      ..EventSettings::default()
    };
    assert_eq!(bad.problems().len(), 1);
  }
}
