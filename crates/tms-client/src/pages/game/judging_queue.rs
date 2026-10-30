//! The queue board's judging tab: the teams to bring to the judging rooms, most urgent first, each with one button
//! for the next step.

use dioxus::prelude::*;
use tms_core::Topic;
use tms_core::model::{JudgingSession, JudgingSlot, QueueState};
use tms_ui::Card;

use super::queue_ui::{QueueCard, Urgency, relative, still_to_queue, urgency};
use super::shared::use_server_now;
use crate::components::{NeedsActiveEvent, PageHeader};
use crate::net::realtime::{Realtime, use_subscription};
use crate::pages::judging::shared::sorted_sessions;
use crate::time::format_time;

#[component]
pub fn JudgingQueue() -> Element {
  use_subscription(Topic::JudgingSessions);
  use_subscription(Topic::Teams);
  use_subscription(Topic::Pods);
  let realtime = use_context::<Realtime>();
  let now = use_server_now();
  let Some(event) = realtime.stores.event.read().clone() else {
    return rsx! { PageHeader { title: "Judging queue" } NeedsActiveEvent {} };
  };
  let teams = realtime.stores.teams.read().clone();
  let pods = realtime.stores.pods.read().clone();
  let place = |id| {
    pods.iter().find(|p| p.id == id).map_or_else(
      || "Pod".to_owned(),
      |p| match &p.room {
        Some(room) if !room.is_empty() => format!("{} · {room}", p.name),
        _ => p.name.clone(),
      },
    )
  };
  let slots: Vec<(JudgingSession, JudgingSlot, Urgency)> = sorted_sessions(&realtime.stores.sessions.read())
    .into_iter()
    .flat_map(|s| s.slots.clone().into_iter().map(move |slot| (s.clone(), slot)))
    .filter(|(_, slot)| slot.team_id.is_some() && slot.queue.is_before_match())
    .map(|(s, slot)| {
      let u = urgency(s.scheduled_start, now(), &event.settings);
      (s, slot, u)
    })
    .collect();
  let mut active: Vec<_> = slots
    .iter()
    .filter(|(_, slot, u)| *u <= Urgency::Now || slot.queue != QueueState::NotCalled)
    .cloned()
    .collect();
  active.sort_by_key(|(s, slot, u)| (!still_to_queue(slot.queue), *u, s.scheduled_start));
  let soon: Vec<_> = slots
    .iter()
    .filter(|(_, slot, u)| *u == Urgency::Soon && slot.queue == QueueState::NotCalled)
    .cloned()
    .collect();
  let later: Vec<_> = slots
    .iter()
    .filter(|(_, slot, u)| *u == Urgency::Later && slot.queue == QueueState::NotCalled)
    .take(12)
    .cloned()
    .collect();
  let card = |s: &JudgingSession, slot: &JudgingSlot, u: Urgency| {
    let team = slot.team_id.and_then(|id| teams.iter().find(|t| t.id == id)).cloned();
    rsx! {
      QueueCard {
        key: "{slot.id}",
        slot_id: slot.id,
        state: slot.queue,
        previous: slot.queue_previous,
        place: place(slot.pod_id),
        colour: "var(--tms-primary)",
        team_number: team.as_ref().map(|t| t.number.clone()).unwrap_or_default(),
        team_name: team.map(|t| t.name).unwrap_or_default(),
        when: format!("Session {} · {}", s.number, relative(s.scheduled_start, now())),
        urgency: u,
        judging: true,
      }
    }
  };

  rsx! {
    PageHeader { title: "Judging queue", subtitle: "Bring each team to its judging room. The judges take them in." }
    section { class: "mb-6",
      h2 { class: "mb-2 text-lg font-semibold tracking-tight", "Queue now" }
      if active.is_empty() {
        p { class: "rounded-panel border border-dashed border-line-strong p-6 text-center text-muted", "Nobody to bring to judging right now." }
      }
      ul { class: "grid gap-3 md:grid-cols-2 2xl:grid-cols-3", "data-testid": "judging-calling",
        for (s , slot , u) in active.iter() {
          {card(s, slot, *u)}
        }
      }
    }
    if !soon.is_empty() {
      section { class: "mb-6",
        h2 { class: "mb-2 text-lg font-semibold tracking-tight", "Soon" }
        ul { class: "grid gap-3 md:grid-cols-2 2xl:grid-cols-3",
          for (s , slot , u) in soon.iter() {
            {card(s, slot, *u)}
          }
        }
      }
    }
    if !later.is_empty() {
      Card { title: "Later",
        ul { class: "flex flex-col text-sm",
          for (s , slot , _) in later {
            {
                let team = slot.team_id.and_then(|id| teams.iter().find(|t| t.id == id)).cloned();
                rsx! {
                  li { key: "{slot.id}", class: "flex items-center gap-3 border-b border-line py-2 last:border-b-0",
                    span { class: "w-14 font-mono text-muted", "{format_time(s.scheduled_start, &event.timezone)}" }
                    span { class: "w-24 text-muted", "Session {s.number}" }
                    span { class: "w-36 truncate", {place(slot.pod_id)} }
                    span { class: "w-14 font-bold tabular-nums", {team.as_ref().map(|t| t.number.clone()).unwrap_or_default()} }
                    span { class: "min-w-0 flex-1 truncate", {team.map(|t| t.name).unwrap_or_default()} }
                  }
                }
            }
          }
        }
      }
    }
  }
}
