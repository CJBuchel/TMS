//! The judge station: this pod's session timer, the team in the room, who is next, and this pod's rubrics.

use dioxus::prelude::*;
use gloo_storage::{LocalStorage, Storage};
use tms_core::Topic;
use tms_core::judging::{PodTimer, PodTimerAction, PodTimerRequest, RubricStatus, SESSION_PHASES};
use tms_core::model::{JudgingSession, JudgingSlot, QueueState};
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Card, Select, TextField};
use uuid::Uuid;

use super::rubric_form::{RubricForm, RubricTarget};
use super::shared::{JudgingBadge, JudgingQueueButtons, PhaseList, PodClock, pod_slot, rubric_tone, sorted_sessions};
use crate::components::{ConfirmButton, ErrorBox, NeedsActiveEvent, PageHeader, SuccessBox, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::{Realtime, use_subscription};
use crate::pages::game::shared::team_label;
use crate::store::outbox::OutboxState;
use crate::store::session::{Session, bound_pod};
use crate::time::format_time;

const POD_KEY: &str = "tms.judge.pod";
pub const NAMES_KEY: &str = "tms.judge.names";

#[component]
pub fn JudgeStation() -> Element {
  use_subscription(Topic::JudgingSessions);
  use_subscription(Topic::Teams);
  use_subscription(Topic::Pods);
  use_subscription(Topic::PodTimers);
  use_subscription(Topic::Rubrics);
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let mut chosen = use_signal(|| LocalStorage::get::<Uuid>(POD_KEY).ok());
  let mut names = use_signal(|| LocalStorage::get::<String>(NAMES_KEY).unwrap_or_default());
  let mut form = use_signal(|| None::<RubricTarget>);
  let mut notice = use_signal(|| None::<String>);
  let error = use_signal(|| None::<ApiFailure>);

  let Some(event) = realtime.stores.event.read().clone() else {
    return rsx! { PageHeader { title: "Judge station" } NeedsActiveEvent {} };
  };
  let bound = bound_pod(&session.read());
  let pods = realtime.stores.pods.read().clone();
  let teams = realtime.stores.teams.read().clone();

  if let Some(target) = form() {
    return rsx! {
      RubricForm {
        target,
        judge_names: names(),
        onclose: move |outcome: Option<OutboxState>| {
            notice.set(outcome.map(|o| match o {
                OutboxState::Sent { counted: true, .. } => "Rubrics sent and accepted.".to_owned(),
                OutboxState::Sent { .. } => "Rubrics sent. The judge advisor will review them.".to_owned(),
                _ => "Rubrics saved on this device. They will be sent when the server can be reached.".to_owned(),
            }));
            form.set(None);
        },
      }
    };
  }

  let pod_select = rsx! {
    if let Some(pod) = bound {
      p { class: "text-sm", "This device's access key is for {pods.iter().find(|p| p.id == pod).map_or(\"a pod\", |p| p.name.as_str())}." }
    } else {
      Select {
        label: "Pod",
        value: chosen().map(|p| p.to_string()).unwrap_or_default(),
        options: std::iter::once((String::new(), "Choose a pod".to_owned()))
            .chain(pods.iter().map(|p| (p.id.to_string(), p.name.clone())))
            .collect(),
        onchange: move |v: String| {
            let id = v.parse::<Uuid>().ok();
            match id {
                Some(id) => {
                    let _ = LocalStorage::set(POD_KEY, id);
                }
                None => LocalStorage::delete(POD_KEY),
            }
            chosen.set(id);
        },
      }
    }
  };
  let Some(pod_id) = bound.or(chosen()) else {
    return rsx! {
      PageHeader { title: "Judge station" }
      Card { title: "Which pod is this?", div { class: "max-w-sm", {pod_select} } }
    };
  };
  let pod_name = pods
    .iter()
    .find(|p| p.id == pod_id)
    .map_or_else(|| "Pod".to_owned(), |p| p.name.clone());
  let timer = realtime
    .stores
    .pod_timers
    .read()
    .iter()
    .find(|t| t.pod_id == pod_id)
    .cloned();
  let sessions = sorted_sessions(&realtime.stores.sessions.read());
  let mine: Vec<(JudgingSession, JudgingSlot)> = sessions
    .iter()
    .filter_map(|s| pod_slot(s, pod_id).map(|slot| (s.clone(), slot)))
    .filter(|(_, slot)| slot.team_id.is_some())
    .collect();
  // The session on the timer, otherwise the next one not yet done.
  let current = timer
    .as_ref()
    .and_then(|t| t.session_id)
    .and_then(|id| mine.iter().find(|(s, _)| s.id == id).cloned())
    .or_else(|| mine.iter().find(|(_, slot)| slot.queue.is_before_match()).cloned());
  let current_id = current.as_ref().map(|(s, _)| s.id);
  let next: Vec<(JudgingSession, JudgingSlot)> = mine
    .iter()
    .filter(|(s, slot)| Some(s.id) != current_id && slot.queue.is_before_match())
    .take(4)
    .cloned()
    .collect();
  let to_judge: Vec<(JudgingSession, JudgingSlot)> = mine
    .iter()
    .filter(|(_, slot)| slot.queue == QueueState::Done && slot.rubric.is_none())
    .cloned()
    .collect();
  let mut rubrics: Vec<_> = realtime
    .stores
    .rubrics
    .read()
    .iter()
    .filter(|r| r.pod_id == Some(pod_id))
    .cloned()
    .collect();
  rubrics.sort_by_key(|r| std::cmp::Reverse(r.received_at));

  let running = timer.as_ref().is_some_and(|t| t.phase.is_some());
  let act = move |action: PodTimerAction, session_id: Option<Uuid>| async move {
    let mut error = error;
    error.set(None);
    let body = PodTimerRequest { session_id };
    let path = format!(
      "/pods/{pod_id}/timer/{}",
      serde_json::to_value(action)
        .ok()
        .and_then(|v| v.as_str().map(str::to_owned))
        .unwrap_or_default()
    );
    if let Err(e) = api::post::<_, PodTimer>(&path, token(session).as_deref(), &body).await {
      error.set(Some(e));
    }
  };
  let rubric_target = move |session: &JudgingSession, slot: &JudgingSlot| RubricTarget {
    slot_id: Some(slot.id),
    pod_id: Some(pod_id),
    team_number: slot
      .team_id
      .and_then(|id| {
        realtime
          .stores
          .teams
          .peek()
          .iter()
          .find(|t| t.id == id)
          .map(|t| t.number.clone())
      })
      .unwrap_or_default(),
    title: format!("Session {}", session.number),
  };

  rsx! {
    PageHeader {
      title: "Judge station: {pod_name}",
      actions: rsx! {
        Button {
          variant: ButtonVariant::Secondary,
          onclick: move |_| form.set(Some(RubricTarget { slot_id: None, pod_id: Some(pod_id), team_number: String::new(), title: "Unscheduled".into() })),
          "Add unscheduled rubrics"
        }
      },
    }
    if let Some(message) = notice() {
      div { class: "mb-3", SuccessBox { message } }
    }
    if let Some(e) = error() {
      div { class: "mb-3", ErrorBox { error: e } }
    }
    div { class: "grid gap-4 lg:grid-cols-2",
      Card { title: "Session timer",
        div { class: "grid gap-4 xl:grid-cols-[minmax(0,1fr)_auto]",
          div {
            PodClock { timer: timer.clone(), size_class: "text-7xl" }
            div { class: "mt-4 flex flex-wrap gap-2",
              if !running {
                Button {
                  size: ButtonSize::Large,
                  disabled: current.is_none(),
                  onclick: move |_| act(PodTimerAction::Start, current_id),
                  "Start session"
                }
              } else {
                Button { size: ButtonSize::Large, onclick: move |_| act(PodTimerAction::Next, None), "Next phase" }
                Button { variant: ButtonVariant::Secondary, onclick: move |_| act(PodTimerAction::Previous, None), "Previous" }
                Button { variant: ButtonVariant::Secondary, onclick: move |_| act(PodTimerAction::Extend, None), "+1 min" }
                ConfirmButton {
                  label: "Finish session",
                  title: "Finish this session?",
                  message: "The timer stops and the team is marked done. Fill in the rubrics next.",
                  confirm_label: "Finish",
                  variant: ButtonVariant::Warning,
                  size: ButtonSize::Medium,
                  onconfirm: move |()| { spawn(act(PodTimerAction::Finish, None)); },
                }
              }
            }
          }
          PhaseList { current: timer.as_ref().and_then(|t| t.phase) }
        }
      }
      Card { title: "In the room",
        match current.clone() {
          Some((s, slot)) => rsx! {
            div { class: "flex flex-wrap items-center gap-3",
              span { class: "text-5xl font-extrabold tracking-tight", "{team_label(&teams, slot.team_id)}" }
              JudgingBadge { state: slot.queue }
            }
            p { class: "mt-1 text-sm text-muted", "Session {s.number}, {format_time(s.scheduled_start, &event.timezone)}" }
            div { class: "mt-3", "data-testid": "judging-now",
              JudgingQueueButtons { slot_id: slot.id, state: slot.queue, previous: slot.queue_previous, large: true }
            }
            div { class: "mt-3",
              Button { variant: ButtonVariant::Secondary, onclick: move |_| form.set(Some(rubric_target(&s, &slot))), "Fill in rubrics" }
            }
          },
          None => rsx! { p { class: "text-sm text-muted", "No more sessions in this pod." } },
        }
      }
      Card { title: "Rubrics to fill in",
        if to_judge.is_empty() {
          p { class: "text-sm text-muted", "Every finished session has its rubrics." }
        }
        ul { class: "divide-y divide-line",
          for (s , slot) in to_judge {
            li { class: "flex items-center justify-between gap-3 py-2",
              span { "Session {s.number}: {team_label(&teams, slot.team_id)}" }
              Button { variant: ButtonVariant::Warning, onclick: move |_| form.set(Some(rubric_target(&s, &slot))), "Fill in" }
            }
          }
        }
      }
      Card { title: "Up next",
        if next.is_empty() {
          p { class: "text-sm text-muted", "Nothing more scheduled." }
        }
        ul { class: "divide-y divide-line",
          for (s , slot) in next {
            li { class: "flex items-center justify-between gap-3 py-2 text-sm",
              span { class: "font-mono", "{format_time(s.scheduled_start, &event.timezone)}" }
              span { class: "flex-1", "Session {s.number}" }
              span { "{team_label(&teams, slot.team_id)}" }
              JudgingBadge { state: slot.queue }
            }
          }
        }
      }
      Card { title: "This pod's rubrics",
        if rubrics.is_empty() {
          p { class: "text-sm text-muted", "None yet." }
        }
        ul { class: "divide-y divide-line",
          for r in rubrics {
            li { class: "py-2 text-sm",
              div { class: "flex flex-wrap items-center gap-2",
                span { class: "font-mono font-semibold", "{r.team_number}" }
                span { "IP {r.innovation_project}, RD {r.robot_design}" }
                Badge { tone: rubric_tone(r.status), "{r.status.label()}" }
              }
              if r.status == RubricStatus::Rejected && !r.review_note.is_empty() {
                p { class: "text-danger-strong", "Judge advisor: {r.review_note}" }
              }
            }
          }
        }
      }
      Card { title: "This device",
        div { class: "flex max-w-sm flex-col gap-3",
          TextField {
            label: "Judges",
            value: names(),
            hint: "Recorded with this pod's rubrics.",
            oninput: move |v: String| {
                let _ = LocalStorage::set(NAMES_KEY, &v);
                names.set(v);
            },
          }
          {pod_select}
          p { class: "text-xs text-muted", "A session is {SESSION_PHASES.len() - 1} phases and 30 minutes, then time for the rubrics." }
        }
      }
    }
  }
}
