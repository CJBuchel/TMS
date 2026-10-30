//! Judging: the pod timer's session phases, rubrics as judges' devices write them, judging queue roles.
//! Scores, ranks and awards are in `deliberation`.

use std::collections::BTreeMap;

use chrono::{DateTime, TimeDelta, Utc};
use serde::{Deserialize, Serialize};
use tms_seasons::{Issue, Season};
use uuid::Uuid;

use crate::Role;
use crate::queue::{QueueAction, QueueError, QueueState};
use crate::role::has_role;

/// One step of a judging session, from the official session flowchart.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct SessionPhase {
  pub name: &'static str,
  pub minutes: u32,
}

/// The official 30-minute session, then time for the judges to finish their rubrics.
pub const SESSION_PHASES: [SessionPhase; 7] = [
  SessionPhase {
    name: "Welcome",
    minutes: 2,
  },
  SessionPhase {
    name: "Innovation Project presentation",
    minutes: 5,
  },
  SessionPhase {
    name: "Innovation Project questions",
    minutes: 5,
  },
  SessionPhase {
    name: "Robot Design explanation",
    minutes: 5,
  },
  SessionPhase {
    name: "Robot Design questions",
    minutes: 5,
  },
  SessionPhase {
    name: "Final share and feedback",
    minutes: 8,
  },
  SessionPhase {
    name: "Judges deliberate and write rubrics",
    minutes: 10,
  },
];

/// A pod's timer: which phase of which session it is in, and when that phase ends.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct PodTimer {
  pub pod_id: Uuid,
  pub session_id: Option<Uuid>,
  /// Index into the session phases; `None` when the pod is idle.
  pub phase: Option<usize>,
  pub phase_started_at: Option<DateTime<Utc>>,
  /// The phase's length, including any minutes added.
  pub phase_ms: u32,
}

impl PodTimer {
  pub fn idle(pod_id: Uuid) -> Self {
    Self {
      pod_id,
      session_id: None,
      phase: None,
      phase_started_at: None,
      phase_ms: 0,
    }
  }

  pub fn phase_name(&self) -> &'static str {
    self
      .phase
      .and_then(|i| SESSION_PHASES.get(i))
      .map_or("Idle", |p| p.name)
  }

  /// Time left in the phase; negative once it runs over.
  pub fn remaining_ms(&self, now: DateTime<Utc>) -> i64 {
    match self.phase_started_at {
      Some(start) => {
        let ends = start + TimeDelta::milliseconds(self.phase_ms.into());
        (ends - now).num_milliseconds()
      }
      None => 0,
    }
  }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum PodTimerAction {
  /// Start a session at its first phase.
  Start,
  Next,
  Previous,
  /// Add a minute to the current phase.
  Extend,
  /// End the session.
  Finish,
}

/// What a pod timer becomes after an action, or `None` when the action makes no sense now.
pub fn apply_pod_action(
  timer: &PodTimer,
  action: PodTimerAction,
  session_id: Option<Uuid>,
  now: DateTime<Utc>,
) -> Option<PodTimer> {
  let at = |phase: usize| PodTimer {
    pod_id: timer.pod_id,
    session_id: timer.session_id.or(session_id),
    phase: Some(phase),
    phase_started_at: Some(now),
    phase_ms: SESSION_PHASES[phase].minutes * 60_000,
  };
  match (action, timer.phase) {
    (PodTimerAction::Start, None) => {
      session_id?;
      Some(PodTimer { session_id, ..at(0) })
    }
    (PodTimerAction::Next, Some(i)) if i + 1 < SESSION_PHASES.len() => Some(at(i + 1)),
    (PodTimerAction::Previous, Some(i)) if i > 0 => Some(at(i - 1)),
    (PodTimerAction::Extend, Some(_)) => Some(PodTimer {
      phase_ms: timer.phase_ms + 60_000,
      ..timer.clone()
    }),
    (PodTimerAction::Finish | PodTimerAction::Next, Some(_)) => Some(PodTimer::idle(timer.pod_id)),
    _ => None,
  }
}

/// Who may move a team through the judging queue: queuers bring teams to the room, judges take them in, and
/// undoing a no-show is the judge advisor's call.
pub fn judging_queue_allowed(action: QueueAction, roles: &[Role], from: QueueState) -> Result<(), QueueError> {
  let any = |options: &[Role]| options.iter().any(|r| has_role(roles, *r));
  let needs = match action {
    QueueAction::Call | QueueAction::OnWay | QueueAction::Wait => Role::Queuer,
    QueueAction::Undo if from.is_out() => Role::JudgeAdvisor,
    QueueAction::NoShow | QueueAction::Undo if any(&[Role::Queuer, Role::Judge]) => return Ok(()),
    QueueAction::AtTable | QueueAction::NoShow | QueueAction::Undo => Role::Judge,
    QueueAction::Ready | QueueAction::Scratch => Role::JudgeAdvisor,
  };
  if has_role(roles, needs) {
    Ok(())
  } else {
    Err(QueueError::Forbidden { action, role: needs })
  }
}

/// Judging queue actions offered to this login. "At table" means "in the room" here; ready and scratch aren't used.
pub fn judging_actions(roles: &[Role], state: QueueState, previous: Option<QueueState>) -> Vec<QueueAction> {
  [
    QueueAction::Call,
    QueueAction::OnWay,
    QueueAction::Wait,
    QueueAction::AtTable,
    QueueAction::NoShow,
    QueueAction::Undo,
  ]
  .into_iter()
  .filter(|a| judging_queue_allowed(*a, roles, state).is_ok() && state.apply(*a, previous).is_ok())
  .collect()
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum Nomination {
  Breakthrough,
  RisingAllStar,
  Motivate,
}

impl Nomination {
  pub const ALL: [Nomination; 3] = [
    Nomination::Breakthrough,
    Nomination::RisingAllStar,
    Nomination::Motivate,
  ];

  pub fn label(self) -> &'static str {
    match self {
      Nomination::Breakthrough => "Breakthrough",
      Nomination::RisingAllStar => "Rising All-Star",
      Nomination::Motivate => "Motivate",
    }
  }
}

/// The feedback page: "Great job" and "Think about" for each area.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Default)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(default)]
pub struct Feedback {
  pub core_values_great: String,
  pub core_values_think: String,
  pub innovation_project_great: String,
  pub innovation_project_think: String,
  pub robot_design_great: String,
  pub robot_design_think: String,
}

/// A team's rubrics as the judges' device writes them. The id is made on the device.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct RubricDoc {
  pub id: Uuid,
  pub event_id: Uuid,
  pub event_code: String,
  pub season_id: String,
  pub schema_version: u16,
  pub team_number: String,
  /// The judging slot this is for, if scheduled.
  pub slot_id: Option<Uuid>,
  pub pod_id: Option<Uuid>,
  pub judge_names: String,
  /// Row id to level, 1 to 4.
  pub scores: BTreeMap<String, u8>,
  /// Required for every row at 4.
  pub exceeds_comments: BTreeMap<String, String>,
  pub feedback: Feedback,
  pub nominations: Vec<Nomination>,
  pub created_at: DateTime<Utc>,
}

impl RubricDoc {
  pub fn check(&self, season: &Season) -> Vec<Issue> {
    let mut issues = tms_seasons::rubric::check(season.rubrics, &self.scores, &self.exceeds_comments);
    if self.team_number.trim().is_empty() {
      issues.push(Issue {
        field: "team".into(),
        message: "Choose a team.".into(),
        severity: tms_seasons::Severity::Error,
      });
    }
    issues
  }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[cfg_attr(feature = "sqlx", derive(sqlx::Type))]
#[cfg_attr(feature = "sqlx", sqlx(type_name = "rubric_status", rename_all = "snake_case"))]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum RubricStatus {
  Submitted,
  Accepted,
  Rejected,
  Superseded,
}

impl RubricStatus {
  pub fn label(self) -> &'static str {
    match self {
      RubricStatus::Submitted => "Waiting for review",
      RubricStatus::Accepted => "Accepted",
      RubricStatus::Rejected => "Rejected",
      RubricStatus::Superseded => "Superseded",
    }
  }
}

/// A stored rubric, as judges and the judge advisor see it.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct Rubric {
  pub id: Uuid,
  pub event_id: Uuid,
  pub team_id: Uuid,
  pub team_number: String,
  pub slot_id: Option<Uuid>,
  pub pod_id: Option<Uuid>,
  pub judge_names: String,
  pub submitted_by: String,
  pub status: RubricStatus,
  /// The team already has an accepted rubric.
  pub duplicate: bool,
  pub scores: BTreeMap<String, u8>,
  pub exceeds_comments: BTreeMap<String, String>,
  pub feedback: Feedback,
  pub nominations: Vec<Nomination>,
  pub innovation_project: u16,
  pub robot_design: u16,
  pub core_values_rows: u16,
  pub review_note: String,
  pub created_at: DateTime<Utc>,
  pub received_at: DateTime<Utc>,
  pub reviewed_by: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct SyncRubricsRequest {
  pub documents: Vec<RubricDoc>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct SyncRubricsResponse {
  pub results: Vec<crate::game::SyncResult<RubricStatus>>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Default)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct PodTimerRequest {
  /// The session to start; `start` only.
  #[serde(default)]
  pub session_id: Option<Uuid>,
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn session_phases_fill_the_official_session() {
    let minutes: u32 = SESSION_PHASES[..6].iter().map(|p| p.minutes).sum();
    assert_eq!(minutes, 30);
  }

  #[test]
  fn pod_timer_moves_through_phases() {
    let now = Utc::now();
    let idle = PodTimer::idle(Uuid::nil());
    assert!(
      apply_pod_action(&idle, PodTimerAction::Start, None, now).is_none(),
      "start needs a session"
    );
    let started = apply_pod_action(&idle, PodTimerAction::Start, Some(Uuid::max()), now).unwrap();
    assert_eq!((started.phase, started.phase_name()), (Some(0), "Welcome"));
    assert_eq!(started.remaining_ms(now), 120_000);
    let extended = apply_pod_action(&started, PodTimerAction::Extend, None, now).unwrap();
    assert_eq!(extended.remaining_ms(now), 180_000);
    let next = apply_pod_action(&extended, PodTimerAction::Next, None, now).unwrap();
    assert_eq!((next.phase, next.session_id), (Some(1), Some(Uuid::max())));
    assert_eq!(next.remaining_ms(now + TimeDelta::minutes(6)), -60_000, "runs over");
    let done = apply_pod_action(&next, PodTimerAction::Finish, None, now).unwrap();
    assert_eq!(done, PodTimer::idle(Uuid::nil()));
  }

  #[test]
  fn judging_queue_roles() {
    assert!(judging_queue_allowed(QueueAction::AtTable, &[Role::Judge], QueueState::Waiting).is_ok());
    assert!(judging_queue_allowed(QueueAction::AtTable, &[Role::Referee], QueueState::Waiting).is_err());
    assert!(judging_queue_allowed(QueueAction::Undo, &[Role::Judge], QueueState::NoShow).is_err());
    assert!(judging_queue_allowed(QueueAction::Undo, &[Role::JudgeAdvisor], QueueState::NoShow).is_ok());
    assert_eq!(
      judging_actions(&[Role::Judge], QueueState::Waiting, None),
      [QueueAction::AtTable, QueueAction::NoShow]
    );
  }
}
