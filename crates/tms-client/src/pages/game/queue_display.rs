//! The queue screen for the pits: which teams should come to the queue now, and who is soon. With
//! `?tables=Red,Blue` it lists only those tables.

use dioxus::prelude::*;
use tms_core::Topic;
use tms_core::model::{GameMatch, MatchState, QueueState};
use tms_ui::Tone;

use super::displays::{DisplayFrame, table_colour};
use super::queue_ui::{Urgency, relative, still_to_queue, urgency};
use super::shared::{chosen_label, chosen_tables, sorted_matches, table_name, use_server_now};
use crate::net::realtime::{Realtime, use_subscription};
use crate::time::format_time;

#[component]
pub fn QueueDisplay(tables: String) -> Element {
  use_subscription(Topic::Matches);
  use_subscription(Topic::Teams);
  use_subscription(Topic::Tables);
  let realtime = use_context::<Realtime>();
  let now = use_server_now();
  let event = realtime.stores.event.read().clone();
  let settings = event.as_ref().map(|e| e.settings.clone()).unwrap_or_default();
  let timezone = event.map_or_else(|| "UTC".into(), |e| e.timezone);
  let all_tables = realtime.stores.tables.read().clone();
  let chosen = chosen_tables(&all_tables, &tables);
  let pair = chosen_label(&all_tables, chosen.as_deref());

  let waiting: Vec<GameMatch> = sorted_matches(&realtime.stores.matches.read())
    .into_iter()
    .filter(|m| matches!(m.state, MatchState::Scheduled | MatchState::Staged))
    .map(|m| GameMatch {
      slots: m
        .slots
        .iter()
        .filter(|s| s.team_id.is_some() && still_to_queue(s.queue))
        .filter(|s| chosen.as_ref().is_none_or(|ids| ids.contains(&s.table_id)))
        .cloned()
        .collect(),
      ..m
    })
    .filter(|m| !m.slots.is_empty())
    .collect();
  let (now_list, soon_list): (Vec<GameMatch>, Vec<GameMatch>) = waiting
    .into_iter()
    .filter(|m| urgency(m.scheduled_start, now(), &settings) <= Urgency::Soon)
    .partition(|m| urgency(m.scheduled_start, now(), &settings) <= Urgency::Now);

  rsx! {
    DisplayFrame { title: pair.map_or_else(|| "Queue".to_owned(), |p| format!("Queue · {p}")),
      div { class: "grid min-h-0 flex-1 gap-8 overflow-hidden lg:grid-cols-[3fr_2fr]",
        section { class: "min-h-0",
          h2 { class: "mb-4 text-4xl font-extrabold", "Come to the queue now" }
          if now_list.is_empty() {
            p { class: "text-2xl text-muted", "Nobody right now." }
          }
          QueueList { matches: now_list, timezone: timezone.clone(), large: true }
        }
        section { class: "min-h-0",
          h2 { class: "mb-4 text-3xl font-bold text-muted", "Get ready" }
          if soon_list.is_empty() {
            p { class: "text-xl text-muted", "No matches in the next {settings.queue_soon_minutes} minutes." }
          }
          QueueList { matches: soon_list, timezone, large: false }
        }
      }
    }
  }
}

/// Status pills large enough to read across the pits.
fn tone_class(tone: Tone) -> &'static str {
  match tone {
    Tone::Danger => "bg-danger text-on-primary",
    Tone::Warning => "bg-warning text-on-warning",
    Tone::Info => "bg-info-soft text-info-strong",
    _ => "bg-surface-2 text-muted",
  }
}

#[component]
fn QueueList(matches: Vec<GameMatch>, timezone: String, large: bool) -> Element {
  let realtime = use_context::<Realtime>();
  let now = use_server_now();
  let teams = realtime.stores.teams.read().clone();
  let tables = realtime.stores.tables.read().clone();
  let settings = realtime
    .stores
    .event
    .read()
    .as_ref()
    .map(|e| e.settings.clone())
    .unwrap_or_default();
  let (number, name) = if large {
    ("text-4xl", "text-2xl")
  } else {
    ("text-2xl", "text-lg")
  };
  rsx! {
    div { class: "flex flex-col gap-4",
      for m in matches {
        div { key: "{m.id}",
          p { class: "mb-1.5 text-lg text-muted", "{m.label()} at {format_time(m.scheduled_start, &timezone)} · {relative(m.scheduled_start, now())}" }
          div { class: "flex flex-col gap-1.5",
            for slot in m.slots.iter().cloned() {
              {
                  let place = table_name(&tables, slot.table_id);
                  let team = slot.team_id.and_then(|id| teams.iter().find(|t| t.id == id)).cloned();
                  let (tone, status) = match slot.queue {
                      QueueState::Called => (Tone::Info, "Called".to_owned()),
                      QueueState::OnWay => (Tone::Info, "On the way".to_owned()),
                      _ => {
                          let u = urgency(m.scheduled_start, now(), &settings);
                          (u.tone(), if u == Urgency::Late { "Late: come now".to_owned() } else { u.label().to_owned() })
                      }
                  };
                  rsx! {
                    div { key: "{slot.id}", class: "flex items-center gap-4 overflow-hidden rounded-control border border-line bg-surface pr-4",
                      div { class: "w-2 self-stretch", style: "background:{table_colour(&place)}" }
                      span { class: "{number} w-[5ch] py-2 font-extrabold tabular-nums", {team.as_ref().map(|t| t.number.clone()).unwrap_or_default()} }
                      span { class: "{name} min-w-0 flex-1 truncate font-semibold", {team.map(|t| t.name).unwrap_or_default()} }
                      span { class: "text-xl text-muted", "{place}" }
                      span { class: "rounded-full px-4 py-1 text-lg font-bold {tone_class(tone)}", "{status}" }
                    }
                  }
              }
            }
          }
        }
      }
    }
  }
}
