//! Integrated queueing: where each team is on its way to a match. Queuers call teams, referees mark them at the
//! table and ready, and the match timer moves them to running and done.

use serde::{Deserialize, Serialize};

use crate::Role;
use crate::role::has_role;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[cfg_attr(feature = "sqlx", derive(sqlx::Type))]
#[cfg_attr(feature = "sqlx", sqlx(type_name = "slot_queue_state", rename_all = "snake_case"))]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum QueueState {
  NotCalled,
  Called,
  OnWay,
  /// In the queue area beside the field, waiting to be sent to the table.
  Waiting,
  AtTable,
  Ready,
  Running,
  Done,
  NoShow,
  /// Not playing this match, by the head referee's decision.
  Scratched,
}

/// What a person can do to a slot. Running and done are set by the match timer.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum QueueAction {
  Call,
  OnWay,
  Wait,
  AtTable,
  Ready,
  NoShow,
  Scratch,
  /// Back to the state before the last change.
  Undo,
}

#[derive(Debug, Clone, PartialEq, Eq, thiserror::Error)]
pub enum QueueError {
  #[error("a team that is {} can't be marked {}", from.label().to_lowercase(), action.label().to_lowercase())]
  NotAllowed { from: QueueState, action: QueueAction },
  #[error("{} needs the {} role", action.label(), role.label().to_lowercase())]
  Forbidden { action: QueueAction, role: Role },
}

impl QueueState {
  pub const BEFORE_MATCH: [QueueState; 6] = [
    QueueState::NotCalled,
    QueueState::Called,
    QueueState::OnWay,
    QueueState::Waiting,
    QueueState::AtTable,
    QueueState::Ready,
  ];

  pub fn label(self) -> &'static str {
    match self {
      QueueState::NotCalled => "Not called",
      QueueState::Called => "Called",
      QueueState::OnWay => "On the way",
      QueueState::Waiting => "In queue",
      QueueState::AtTable => "At table",
      QueueState::Ready => "Ready",
      QueueState::Running => "Playing",
      QueueState::Done => "Done",
      QueueState::NoShow => "No show",
      QueueState::Scratched => "Scratched",
    }
  }

  pub fn is_before_match(self) -> bool {
    Self::BEFORE_MATCH.contains(&self)
  }

  /// The team won't play this match, so it neither holds up the start nor needs a scoresheet.
  pub fn is_out(self) -> bool {
    matches!(self, QueueState::NoShow | QueueState::Scratched)
  }

  /// Whether a match may start with this slot as it is.
  pub fn lets_match_start(self) -> bool {
    matches!(self, QueueState::Ready) || self.is_out()
  }

  /// Applies an action. `previous` is the state before the last change, used by undo.
  pub fn apply(self, action: QueueAction, previous: Option<QueueState>) -> Result<QueueState, QueueError> {
    use QueueAction as A;
    use QueueState as S;
    let not_allowed = Err(QueueError::NotAllowed { from: self, action });
    let next = match action {
      A::Call if self == S::NotCalled => S::Called,
      A::OnWay if matches!(self, S::NotCalled | S::Called) => S::OnWay,
      A::Wait if matches!(self, S::NotCalled | S::Called | S::OnWay) => S::Waiting,
      A::AtTable if matches!(self, S::NotCalled | S::Called | S::OnWay | S::Waiting) => S::AtTable,
      A::Ready if self.is_before_match() && self != S::Ready => S::Ready,
      // After the match too: the head referee can record that a team did not really play, so the match stops
      // waiting for its scoresheet.
      A::NoShow if self.is_before_match() || matches!(self, S::Running | S::Done) => S::NoShow,
      A::Scratch if self.is_before_match() || self == S::NoShow => S::Scratched,
      A::Undo if self.is_before_match() || self.is_out() => match previous {
        Some(p) if p.is_before_match() || p.is_out() || matches!(p, S::Running | S::Done) => p,
        _ => return not_allowed,
      },
      _ => return not_allowed,
    };
    Ok(next)
  }
}

impl QueueAction {
  pub const ALL: [QueueAction; 8] = [
    QueueAction::Call,
    QueueAction::OnWay,
    QueueAction::Wait,
    QueueAction::AtTable,
    QueueAction::Ready,
    QueueAction::NoShow,
    QueueAction::Scratch,
    QueueAction::Undo,
  ];

  pub fn label(self) -> &'static str {
    match self {
      QueueAction::Call => "Called",
      QueueAction::OnWay => "On the way",
      QueueAction::Wait => "In queue",
      QueueAction::AtTable => "At table",
      QueueAction::Ready => "Ready",
      QueueAction::NoShow => "No show",
      QueueAction::Scratch => "Scratched",
      QueueAction::Undo => "Undo",
    }
  }

  pub fn key(self) -> &'static str {
    match self {
      QueueAction::Call => "call",
      QueueAction::OnWay => "on_way",
      QueueAction::Wait => "wait",
      QueueAction::AtTable => "at_table",
      QueueAction::Ready => "ready",
      QueueAction::NoShow => "no_show",
      QueueAction::Scratch => "scratch",
      QueueAction::Undo => "undo",
    }
  }

  /// Queuers move teams to the field, referees take them from there, and the head referee can do anything.
  /// Undoing a no-show or scratch is the head referee's call.
  pub fn allowed(self, roles: &[Role], from: QueueState) -> Result<(), QueueError> {
    let needs = match self {
      QueueAction::Call | QueueAction::OnWay | QueueAction::Wait => Role::Queuer,
      QueueAction::AtTable | QueueAction::Ready => Role::Referee,
      QueueAction::NoShow if !from.is_before_match() => Role::HeadReferee,
      QueueAction::NoShow => {
        if has_role(roles, Role::Queuer) || has_role(roles, Role::Referee) {
          return Ok(());
        }
        Role::Referee
      }
      QueueAction::Scratch => Role::HeadReferee,
      QueueAction::Undo if from.is_out() => Role::HeadReferee,
      QueueAction::Undo => {
        if has_role(roles, Role::Queuer) || has_role(roles, Role::Referee) {
          return Ok(());
        }
        Role::Queuer
      }
    };
    if has_role(roles, needs) {
      Ok(())
    } else {
      Err(QueueError::Forbidden {
        action: self,
        role: needs,
      })
    }
  }

  /// The actions someone with `roles` can take on a slot in `state`, for the buttons on a page.
  pub fn available(roles: &[Role], state: QueueState, previous: Option<QueueState>) -> Vec<QueueAction> {
    QueueAction::ALL
      .into_iter()
      .filter(|a| a.allowed(roles, state).is_ok() && state.apply(*a, previous).is_ok())
      .collect()
  }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct QueueRequest {
  pub action: QueueAction,
  #[serde(default)]
  pub note: String,
}

/// A station device logged in with an access key and connected to the live feed right now.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct Presence {
  pub key_id: uuid::Uuid,
  pub label: String,
  pub role: Role,
  pub table_id: Option<uuid::Uuid>,
  pub pod_id: Option<uuid::Uuid>,
  /// Open connections with this key (a reloaded tab can briefly have two).
  pub connections: u32,
  pub since: chrono::DateTime<chrono::Utc>,
  /// Scoresheets and rubrics kept on the device that the server has not accepted yet, as the device reports.
  #[serde(default)]
  pub waiting: u32,
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn only_the_head_referee_marks_a_no_show_after_the_match() {
    let referee = [Role::Referee];
    let head = [Role::HeadReferee];
    assert!(QueueAction::NoShow.allowed(&referee, QueueState::Done).is_err());
    assert!(QueueAction::NoShow.allowed(&head, QueueState::Done).is_ok());
    let out = QueueState::Done.apply(QueueAction::NoShow, None).unwrap();
    assert_eq!(out, QueueState::NoShow);
    assert_eq!(
      out.apply(QueueAction::Undo, Some(QueueState::Done)).unwrap(),
      QueueState::Done
    );
  }

  #[test]
  fn the_usual_path_to_the_table() {
    let s = QueueState::NotCalled;
    let s = s.apply(QueueAction::Call, None).unwrap();
    let s = s.apply(QueueAction::OnWay, None).unwrap();
    let s = s.apply(QueueAction::Wait, None).unwrap();
    let s = s.apply(QueueAction::AtTable, None).unwrap();
    let s = s.apply(QueueAction::Ready, None).unwrap();
    assert_eq!(s, QueueState::Ready);
    assert!(s.lets_match_start());
  }

  #[test]
  fn referees_can_take_a_team_that_just_turned_up() {
    assert_eq!(
      QueueState::NotCalled.apply(QueueAction::AtTable, None),
      Ok(QueueState::AtTable)
    );
    assert!(
      QueueAction::AtTable
        .allowed(&[Role::Referee], QueueState::NotCalled)
        .is_ok()
    );
    assert!(
      QueueAction::Call
        .allowed(&[Role::Referee], QueueState::NotCalled)
        .is_err()
    );
  }

  #[test]
  fn no_show_and_undo() {
    let s = QueueState::Called.apply(QueueAction::NoShow, None).unwrap();
    assert!(s.lets_match_start() && s.is_out());
    assert!(
      QueueAction::Undo.allowed(&[Role::Queuer], s).is_err(),
      "the head referee undoes a no-show"
    );
    assert_eq!(
      s.apply(QueueAction::Undo, Some(QueueState::Called)),
      Ok(QueueState::Called)
    );
    assert_eq!(
      QueueState::Running.apply(QueueAction::NoShow, None),
      Ok(QueueState::NoShow),
      "a team that did not really play can be marked after the match"
    );
    assert!(
      QueueState::Done
        .apply(QueueAction::Undo, Some(QueueState::Running))
        .is_err()
    );
  }

  #[test]
  fn available_actions_follow_role_and_state() {
    let queuer = QueueAction::available(&[Role::Queuer], QueueState::NotCalled, None);
    assert_eq!(
      queuer,
      [
        QueueAction::Call,
        QueueAction::OnWay,
        QueueAction::Wait,
        QueueAction::NoShow
      ]
    );
    let referee = QueueAction::available(&[Role::Referee], QueueState::Waiting, Some(QueueState::OnWay));
    assert_eq!(
      referee,
      [
        QueueAction::AtTable,
        QueueAction::Ready,
        QueueAction::NoShow,
        QueueAction::Undo
      ]
    );
    assert_eq!(
      QueueAction::available(&[Role::HeadReferee], QueueState::Running, None),
      [QueueAction::NoShow]
    );
    assert_eq!(QueueAction::available(&[Role::Referee], QueueState::Done, None), []);
  }
}
