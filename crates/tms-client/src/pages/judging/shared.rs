//! Pieces the judging screens share: the pod clock, judging queue labels and buttons.

use dioxus::prelude::*;
use tms_core::judging::{PodTimer, RubricStatus, SESSION_PHASES, judging_actions};
use tms_core::model::{JudgingSession, JudgingSlot, QueueState};
use tms_core::queue::QueueAction;
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Tone};
use uuid::Uuid;

use crate::pages::game::queue_ui::send_queue;
use crate::pages::game::shared::use_server_now;
use crate::store::session::Session;

/// What a queue state means in the judging rooms.
pub fn judging_label(state: QueueState) -> &'static str {
  match state {
    QueueState::NotCalled => "Not called",
    QueueState::Called => "Called",
    QueueState::OnWay => "On the way",
    QueueState::Waiting => "Outside the room",
    QueueState::AtTable | QueueState::Ready => "In the room",
    QueueState::Running => "In session",
    QueueState::Done => "Done",
    QueueState::NoShow => "No show",
    QueueState::Scratched => "Scratched",
  }
}

pub fn judging_tone(state: QueueState) -> Tone {
  match state {
    QueueState::NotCalled => Tone::Neutral,
    QueueState::Called | QueueState::OnWay | QueueState::Waiting => Tone::Info,
    QueueState::AtTable | QueueState::Ready => Tone::Primary,
    QueueState::Running | QueueState::Done => Tone::Success,
    QueueState::NoShow | QueueState::Scratched => Tone::Danger,
  }
}

pub fn rubric_tone(status: RubricStatus) -> Tone {
  match status {
    RubricStatus::Submitted => Tone::Warning,
    RubricStatus::Accepted => Tone::Success,
    RubricStatus::Rejected => Tone::Danger,
    RubricStatus::Superseded => Tone::Neutral,
  }
}

#[component]
pub fn JudgingBadge(state: QueueState) -> Element {
  rsx! { Badge { tone: judging_tone(state), "{judging_label(state)}" } }
}

fn button_label(action: QueueAction) -> &'static str {
  match action {
    QueueAction::Call => "Call",
    QueueAction::OnWay => "On the way",
    QueueAction::Wait => "Outside the room",
    QueueAction::AtTable => "Team in room",
    QueueAction::NoShow => "No show",
    QueueAction::Undo => "Undo",
    QueueAction::Ready | QueueAction::Scratch => "",
  }
}

/// The judging queue actions this login may take on a slot.
#[component]
pub fn JudgingQueueButtons(
  slot_id: Uuid,
  state: QueueState,
  previous: Option<QueueState>,
  #[props(default)] large: bool,
) -> Element {
  let session = use_context::<Session>();
  let mut error = use_signal(|| None::<String>);
  let mut busy = use_signal(|| false);
  let waiting = use_signal(|| false);
  let roles = session.read().roles();
  let actions = judging_actions(&roles, state, previous);
  let size = if large { ButtonSize::Large } else { ButtonSize::Small };
  rsx! {
    div { class: "flex flex-col gap-1",
      div { class: "flex flex-wrap gap-1",
        for action in actions {
          Button {
            size,
            variant: match action {
                QueueAction::AtTable => ButtonVariant::Success,
                QueueAction::Undo => ButtonVariant::Ghost,
                _ => ButtonVariant::Secondary,
            },
            disabled: busy(),
            onclick: move |_| async move {
                busy.set(true);
                error.set(None);
                if let Err(message) = send_queue(format!("/judging-slots/{slot_id}/queue"), action, session, waiting).await {
                    error.set(Some(message));
                }
                busy.set(false);
            },
            "{button_label(action)}"
          }
        }
      }
      if waiting() {
        p { role: "status", class: "text-sm font-medium text-warning-strong", "No connection. Trying again…" }
      }
      if let Some(message) = error() {
        p { role: "alert", class: "text-xs text-danger-strong", "{message}" }
      }
    }
  }
}

/// `4:32`, or `+0:45` once a phase runs over.
pub fn format_phase_time(ms: i64) -> String {
  let over = ms < 0;
  let seconds = if over { (-ms) / 1000 } else { (ms + 999) / 1000 };
  format!("{}{}:{:02}", if over { "+" } else { "" }, seconds / 60, seconds % 60)
}

/// A pod's clock: the phase and the time left in it (red once over).
#[component]
pub fn PodClock(timer: Option<PodTimer>, size_class: String) -> Element {
  let now = use_server_now();
  let Some(timer) = timer.filter(|t| t.phase.is_some()) else {
    return rsx! { p { class: "text-muted", "No session running." } };
  };
  let remaining = timer.remaining_ms(now());
  let colour = if remaining < 0 {
    "text-danger"
  } else if remaining < 60_000 {
    "text-warning"
  } else {
    "text-fg"
  };
  rsx! {
    div { class: "flex flex-col gap-1",
      span { class: "text-sm font-semibold text-primary-strong", "{timer.phase_name()}" }
      span { class: "font-extrabold tracking-tight tabular-nums leading-none {colour} {size_class}", "data-testid": "pod-clock",
        "{format_phase_time(remaining)}"
      }
    }
  }
}

/// The session phases, with the current one marked.
#[component]
pub fn PhaseList(current: Option<usize>) -> Element {
  rsx! {
    ol { class: "flex flex-col gap-1 text-sm",
      for (i , phase) in SESSION_PHASES.iter().enumerate() {
        li { class: if Some(i) == current { "rounded-control bg-primary-soft px-2.5 py-1.5 font-semibold text-primary-strong" } else if current.is_some_and(|c| i < c) { "px-2.5 py-1.5 text-muted line-through decoration-line-strong" } else { "px-2.5 py-1.5 text-muted" },
          "{phase.name} ({phase.minutes} min)"
        }
      }
    }
  }
}

/// The pod's slot in a session.
pub fn pod_slot(session: &JudgingSession, pod_id: Uuid) -> Option<JudgingSlot> {
  session.slots.iter().find(|s| s.pod_id == pod_id).cloned()
}

/// Sessions in time order.
pub fn sorted_sessions(sessions: &[JudgingSession]) -> Vec<JudgingSession> {
  let mut sorted = sessions.to_vec();
  sorted.sort_by_key(|s| (s.scheduled_start, s.number));
  sorted
}
