//! Queue state badges and action buttons, shared by the queue board, the referee station and match control.

use chrono::{DateTime, Utc};
use dioxus::prelude::*;
use tms_core::model::{EventSettings, JudgingSession, QueueState};
use tms_core::queue::{QueueAction, QueueRequest};
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Tone};
use uuid::Uuid;

use crate::components::token;
use crate::net::api::{self, ApiFailure};
use crate::store::session::Session;

pub fn queue_tone(state: QueueState) -> Tone {
  match state {
    QueueState::NotCalled => Tone::Neutral,
    QueueState::Called | QueueState::OnWay | QueueState::Waiting => Tone::Info,
    QueueState::AtTable => Tone::Primary,
    QueueState::Ready | QueueState::Running | QueueState::Done => Tone::Success,
    QueueState::NoShow | QueueState::Scratched => Tone::Danger,
  }
}

#[component]
pub fn QueueBadge(state: QueueState) -> Element {
  rsx! { Badge { tone: queue_tone(state), "{state.label()}" } }
}

const STEPS: [&str; 5] = ["Called", "On the way", "In queue", "At table", "Ready"];

/// How far a team has got from being called to ready, as five segments. A no-show or scratch shows as a badge.
#[component]
pub fn QueueProgress(state: QueueState, #[props(default)] labels: bool) -> Element {
  let reached = match state {
    QueueState::NotCalled | QueueState::NoShow | QueueState::Scratched => 0,
    QueueState::Called => 1,
    QueueState::OnWay => 2,
    QueueState::Waiting => 3,
    QueueState::AtTable => 4,
    QueueState::Ready | QueueState::Running | QueueState::Done => 5,
  };
  if state.is_out() {
    return rsx! { QueueBadge { state } };
  }
  let fill = queue_tone(state).dot_class();
  rsx! {
    div { class: "flex min-w-0 flex-col gap-1.5", "data-testid": "queue-progress",
      div { class: "flex gap-1",
        for i in 0..STEPS.len() {
          div { class: if i < reached { "h-1.5 flex-1 rounded-full {fill}" } else { "h-1.5 flex-1 rounded-full bg-surface-2 ring-1 ring-line ring-inset" } }
        }
      }
      if labels {
        div { class: "grid grid-cols-5 gap-1 text-xs",
          for (i , step) in STEPS.iter().enumerate() {
            span { class: if i + 1 == reached { "font-semibold text-fg" } else if i < reached { "text-muted" } else { "text-muted/60" }, "{step}" }
          }
        }
      } else {
        span { class: "text-xs font-medium text-muted", "{state.label()}" }
      }
    }
  }
}

/// What a button says for each action.
fn button_label(action: QueueAction) -> &'static str {
  match action {
    QueueAction::Call => "Call",
    QueueAction::OnWay => "On the way",
    QueueAction::Wait => "In queue",
    QueueAction::AtTable => "Team at table",
    QueueAction::Ready => "Ready",
    QueueAction::NoShow => "No show",
    QueueAction::Scratch => "Scratch",
    QueueAction::Undo => "Undo",
  }
}

fn variant(action: QueueAction) -> ButtonVariant {
  match action {
    QueueAction::Ready => ButtonVariant::Success,
    QueueAction::Scratch => ButtonVariant::DangerGhost,
    QueueAction::Undo => ButtonVariant::Ghost,
    _ => ButtonVariant::Secondary,
  }
}

/// How long a queue change keeps trying while the tablet has no connection: 40 tries, 3 seconds apart.
const RETRIES: u32 = 40;
const RETRY_MS: u32 = 3000;

/// Sends a queue change. While the tablet is off the network it keeps trying, with `waiting` set, so a tap made
/// in a Wi-Fi gap still lands; the server's own refusal is returned as a message.
pub async fn send_queue(
  path: String,
  action: QueueAction,
  session: Session,
  waiting: Signal<bool>,
) -> Result<(), String> {
  send_queue_note(path, action, String::new(), session, waiting).await
}

/// [`send_queue`] with a note for the audit log, such as why a team is marked a no-show after its match.
pub async fn send_queue_note(
  path: String,
  action: QueueAction,
  note: String,
  session: Session,
  mut waiting: Signal<bool>,
) -> Result<(), String> {
  let body = QueueRequest { action, note };
  for _ in 0..RETRIES {
    match api::post::<_, serde_json::Value>(&path, token(session).as_deref(), &body).await {
      Ok(_) => {
        waiting.set(false);
        return Ok(());
      }
      Err(ApiFailure::Network(_)) => {
        waiting.set(true);
        gloo_timers::future::TimeoutFuture::new(RETRY_MS).await;
      }
      Err(e @ ApiFailure::Api { .. }) => {
        waiting.set(false);
        return Err(e.message());
      }
    }
  }
  waiting.set(false);
  Err("Still no connection. Try again when the tablet is back online.".to_owned())
}

/// The step that matters next at a table, given what this login may do.
fn main_action(actions: &[QueueAction]) -> Option<QueueAction> {
  [
    QueueAction::AtTable,
    QueueAction::Ready,
    QueueAction::Call,
    QueueAction::OnWay,
    QueueAction::Wait,
  ]
  .into_iter()
  .find(|a| actions.contains(a))
}

/// The actions this login may take on a slot right now. Large (station screens) puts the next step in one big
/// button with the rest small beside it; small lists them all in a row. The server checks again; its answer or
/// error is shown under the buttons.
#[component]
pub fn QueueButtons(
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
  let actions = QueueAction::available(&roles, state, previous);
  let main = if large { main_action(&actions) } else { None };
  let act = move |action: QueueAction| async move {
    busy.set(true);
    error.set(None);
    if let Err(message) = send_queue(format!("/slots/{slot_id}/queue"), action, session, waiting).await {
      error.set(Some(message));
    }
    busy.set(false);
  };
  rsx! {
    div { class: "flex flex-col gap-2",
      if let Some(action) = main {
        Button {
          size: ButtonSize::Huge,
          full_width: true,
          variant: if action == QueueAction::Ready { ButtonVariant::Success } else { ButtonVariant::Primary },
          loading: busy(),
          onclick: move |_| act(action),
          "{button_label(action)}"
        }
      }
      div { class: "flex flex-wrap gap-1",
        for action in actions.into_iter().filter(|a| Some(*a) != main) {
          Button {
            size: if large { ButtonSize::Medium } else { ButtonSize::Small },
            variant: if large && action != QueueAction::Undo && action != QueueAction::Scratch { ButtonVariant::Secondary } else { variant(action) },
            disabled: busy(),
            onclick: move |_| act(action),
            "{button_label(action)}"
          }
        }
      }
      if waiting() {
        p { role: "status", class: "text-sm font-medium text-warning-strong", "No connection. Trying again…" }
      }
      if let Some(message) = error() {
        p { role: "alert", class: "text-sm text-danger-strong", "{message}" }
      }
    }
  }
}

/// The team's judging session when it is too close to a match: within the event's gap before the match starts
/// or after it ends.
pub fn judging_clash(
  sessions: &[JudgingSession],
  team_id: Option<Uuid>,
  start: DateTime<Utc>,
  end: DateTime<Utc>,
  gap_minutes: u32,
) -> Option<&JudgingSession> {
  let team_id = team_id?;
  let gap = chrono::TimeDelta::minutes(gap_minutes.into());
  sessions.iter().find(|s| {
    s.slots.iter().any(|slot| slot.team_id == Some(team_id))
      && s.scheduled_start < end + gap
      && s.scheduled_end + gap > start
  })
}

/// `in 12 min`, `now`, or `3 min late`.
pub fn relative(start: DateTime<Utc>, now: DateTime<Utc>) -> String {
  let minutes = (start - now).num_seconds().div_euclid(60);
  match minutes {
    0 => "now".into(),
    m if m > 0 => format!("in {m} min"),
    m => format!("{} min late", -m),
  }
}

/// Where a team still to reach the queue stands against the clock, from the event's queue windows. Late is from
/// half the "Queue now" window, when the team should already be waiting.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum Urgency {
  Late,
  Now,
  Soon,
  Later,
}

impl Urgency {
  pub fn label(self) -> &'static str {
    match self {
      Urgency::Late => "Late",
      Urgency::Now => "Queue now",
      Urgency::Soon => "Soon",
      Urgency::Later => "Later",
    }
  }

  pub fn tone(self) -> Tone {
    match self {
      Urgency::Late => Tone::Danger,
      Urgency::Now => Tone::Warning,
      Urgency::Soon => Tone::Info,
      Urgency::Later => Tone::Neutral,
    }
  }
}

pub fn urgency(start: DateTime<Utc>, now: DateTime<Utc>, settings: &EventSettings) -> Urgency {
  let seconds = (start - now).num_seconds();
  let call = i64::from(settings.queue_call_minutes) * 60;
  if seconds <= call / 2 {
    Urgency::Late
  } else if seconds <= call {
    Urgency::Now
  } else if seconds <= i64::from(settings.queue_soon_minutes) * 60 {
    Urgency::Soon
  } else {
    Urgency::Later
  }
}

/// Whether the team still has to reach the queue, so a queuer is looking for it.
pub fn still_to_queue(state: QueueState) -> bool {
  matches!(state, QueueState::NotCalled | QueueState::Called | QueueState::OnWay)
}

/// The one step a queuer takes next, worded as what has just happened.
fn next_step(state: QueueState, judging: bool) -> Option<(QueueAction, &'static str)> {
  match state {
    QueueState::NotCalled => Some((QueueAction::Call, "Call team")),
    QueueState::Called => Some((QueueAction::OnWay, "On the way")),
    QueueState::OnWay if judging => Some((QueueAction::Wait, "Outside the room")),
    QueueState::OnWay => Some((QueueAction::Wait, "In the queue")),
    _ => None,
  }
}

/// A team a queuer is looking after: where and when it plays, how far it has got, and one large button for the
/// next step. No show and Undo stay small, as they are rarer.
#[component]
pub fn QueueCard(
  slot_id: Uuid,
  state: QueueState,
  previous: Option<QueueState>,
  /// Table or pod.
  place: String,
  colour: String,
  team_number: String,
  team_name: String,
  /// "Ranking 3 · in 8 min".
  when: String,
  urgency: Urgency,
  #[props(default)] note: Option<String>,
  /// A judging slot rather than a match slot.
  #[props(default)]
  judging: bool,
) -> Element {
  let session = use_context::<Session>();
  let mut error = use_signal(|| None::<String>);
  let mut busy = use_signal(|| false);
  let waiting = use_signal(|| false);
  let roles = session.read().roles();
  let allowed = if judging {
    tms_core::judging::judging_actions(&roles, state, previous)
  } else {
    QueueAction::available(&roles, state, previous)
  };
  let endpoint = if judging { "judging-slots" } else { "slots" };
  let act = move |action: QueueAction| async move {
    busy.set(true);
    error.set(None);
    if let Err(message) = send_queue(format!("/{endpoint}/{slot_id}/queue"), action, session, waiting).await {
      error.set(Some(message));
    }
    busy.set(false);
  };
  let step = next_step(state, judging).filter(|(a, _)| allowed.contains(a));
  let ring = match (urgency, still_to_queue(state)) {
    (Urgency::Late, true) => "ring-2 ring-danger",
    (Urgency::Now, true) => "ring-1 ring-warning",
    _ => "",
  };
  rsx! {
    li { class: "flex flex-col overflow-hidden rounded-panel border border-line bg-surface shadow-panel {ring}", "data-testid": "queue-card",
      div { class: "h-1.5", style: "background:{colour}" }
      div { class: "flex flex-1 flex-col gap-3 p-4",
        div { class: "flex flex-wrap items-center justify-between gap-2 text-sm",
          span { class: "inline-flex items-center gap-2 font-semibold",
            span { class: "h-2.5 w-2.5 rounded-full", style: "background:{colour}" }
            "{place}"
            span { class: "font-normal text-muted", "· {when}" }
          }
          if still_to_queue(state) {
            Badge { tone: urgency.tone(), "{urgency.label()}" }
          } else {
            QueueBadge { state }
          }
        }
        div { class: "flex min-w-0 items-baseline gap-3",
          span { class: "text-3xl font-extrabold tabular-nums", "{team_number}" }
          span { class: "truncate text-lg font-semibold", "{team_name}" }
        }
        if let Some(note) = note {
          p { class: "text-sm font-medium text-warning-strong", "{note}" }
        }
        QueueProgress { state }
        div { class: "mt-auto flex flex-wrap items-center gap-2",
          if let Some((action, label)) = step {
            div { class: "min-w-40 flex-1",
              Button {
                size: ButtonSize::Large,
                variant: if urgency == Urgency::Soon && state == QueueState::NotCalled { ButtonVariant::Secondary } else { ButtonVariant::Primary },
                full_width: true,
                loading: busy(),
                onclick: move |_| act(action),
                "{label}"
              }
            }
          } else if state == QueueState::Waiting {
            p { class: "flex-1 text-sm font-semibold text-success-strong",
              if judging { "Outside the room. The judges take the team in from here." } else { "In the queue. The referee takes the team from here." }
            }
          }
          if allowed.contains(&QueueAction::Wait) && step.is_some_and(|(a, _)| a != QueueAction::Wait) {
            Button {
              variant: ButtonVariant::Ghost,
              size: ButtonSize::Small,
              disabled: busy(),
              onclick: move |_| act(QueueAction::Wait),
              if judging { "Already at the room" } else { "Already in the queue" }
            }
          }
          if allowed.contains(&QueueAction::NoShow) && urgency <= Urgency::Now {
            Button { variant: ButtonVariant::DangerGhost, size: ButtonSize::Small, disabled: busy(), onclick: move |_| act(QueueAction::NoShow), "No show" }
          }
          if allowed.contains(&QueueAction::Undo) {
            Button { variant: ButtonVariant::Ghost, size: ButtonSize::Small, disabled: busy(), onclick: move |_| act(QueueAction::Undo), "Undo" }
          }
        }
        if waiting() {
          p { role: "status", class: "text-sm font-medium text-warning-strong", "No connection. Trying again…" }
        }
        if let Some(message) = error() {
          p { role: "alert", class: "text-sm text-danger-strong", "{message}" }
        }
      }
    }
  }
}
