//! The queue board: the teams a queuer is looking for, most urgent first, each with one button for the next step.

use dioxus::prelude::*;
use gloo_storage::{LocalStorage, Storage};
use tms_core::Topic;
use tms_core::model::{GameMatch, MatchSlot, MatchState, QueueState};
use tms_ui::{Badge, Card, Tab, Tabs, TextField, Tone};

use super::displays::table_colour;
use super::judging_queue::JudgingQueue;
use super::queue_ui::{QueueBadge, QueueCard, Urgency, judging_clash, relative, still_to_queue, urgency};
use super::shared::{match_tone, sorted_matches, table_name, table_pairs, use_server_now};
use crate::components::{NeedsActiveEvent, PageHeader};
use crate::net::realtime::{Realtime, use_subscription};
use crate::time::format_time;

/// The table pair this device looks after, kept so each queuer's tablet opens on their own tables.
const TABLES_KEY: &str = "tms.queue.tables";
/// How many later matches the board lists below the cards.
const LATER_ROWS: usize = 12;

/// Robot game and judging queues, one tab each.
#[component]
pub fn QueueBoard() -> Element {
  let mut judging = use_signal(|| false);
  rsx! {
    div { class: "mb-4",
      Tabs {
        Tab { active: !judging(), onclick: move |_| judging.set(false), "Robot game" }
        Tab { active: judging(), onclick: move |_| judging.set(true), "Judging" }
      }
    }
    if judging() {
      JudgingQueue {}
    } else {
      RobotQueue {}
    }
  }
}

/// A count with what it counts, for the strip above the cards.
#[component]
pub fn QueueCount(label: String, value: usize, #[props(default)] tone: Tone) -> Element {
  let colour = match (tone, value) {
    (_, 0) => "text-muted",
    (Tone::Danger, _) => "text-danger",
    (Tone::Warning, _) => "text-warning-strong",
    (Tone::Success, _) => "text-success-strong",
    _ => "text-fg",
  };
  rsx! {
    div { class: "rounded-control border border-line bg-surface px-2.5 py-2 shadow-panel sm:px-4 sm:py-2.5",
      p { class: "text-xl font-extrabold tabular-nums sm:text-2xl {colour}", "{value}" }
      p { class: "text-xs font-medium leading-tight text-muted", "{label}" }
    }
  }
}

#[component]
fn RobotQueue() -> Element {
  use_subscription(Topic::Matches);
  use_subscription(Topic::Teams);
  use_subscription(Topic::Tables);
  use_subscription(Topic::JudgingSessions);
  let realtime = use_context::<Realtime>();
  let now = use_server_now();
  let mut chosen = use_signal(|| LocalStorage::get::<String>(TABLES_KEY).unwrap_or_default());
  let mut search = use_signal(String::new);

  let Some(event) = realtime.stores.event.read().clone() else {
    return rsx! { PageHeader { title: "Queue board" } NeedsActiveEvent {} };
  };
  let tables = realtime.stores.tables.read().clone();
  let teams = realtime.stores.teams.read().clone();
  let sessions = realtime.stores.sessions.read().clone();
  let pairs = table_pairs(&tables);
  let selected = pairs
    .iter()
    .find(|(label, _)| *label == chosen())
    .map(|(_, ids)| ids.clone());
  let mine = |slot: &MatchSlot| selected.as_ref().is_none_or(|ids| ids.contains(&slot.table_id));
  let settings = event.settings.clone();
  let matches = sorted_matches(&realtime.stores.matches.read());

  let slots: Vec<(GameMatch, MatchSlot, Urgency)> = matches
    .iter()
    .filter(|m| matches!(m.state, MatchState::Scheduled | MatchState::Staged))
    .flat_map(|m| m.slots.iter().map(move |s| (m.clone(), s.clone())))
    .filter(|(_, s)| s.team_id.is_some() && mine(s))
    .map(|(m, s)| {
      let u = urgency(m.scheduled_start, now(), &settings);
      (m, s, u)
    })
    .collect();
  let mut active: Vec<(GameMatch, MatchSlot, Urgency)> = slots
    .iter()
    .filter(|(_, s, u)| {
      (*u <= Urgency::Now && (still_to_queue(s.queue) || s.queue == QueueState::Waiting))
        || matches!(s.queue, QueueState::Called | QueueState::OnWay | QueueState::Waiting)
    })
    .cloned()
    .collect();
  active.sort_by_key(|(m, s, u)| (!still_to_queue(s.queue), *u, m.scheduled_start));
  let soon: Vec<_> = slots
    .iter()
    .filter(|(_, s, u)| *u == Urgency::Soon && s.queue == QueueState::NotCalled)
    .cloned()
    .collect();
  let later: Vec<_> = slots
    .iter()
    .filter(|(_, s, u)| *u == Urgency::Later && s.queue == QueueState::NotCalled)
    .take(LATER_ROWS)
    .cloned()
    .collect();
  let count = |f: &dyn Fn(&(GameMatch, MatchSlot, Urgency)) -> bool| active.iter().filter(|x| f(x)).count();
  let to_call = count(&|(_, s, _)| s.queue == QueueState::NotCalled);
  let on_way = count(&|(_, s, _)| matches!(s.queue, QueueState::Called | QueueState::OnWay));
  let waiting = count(&|(_, s, _)| s.queue == QueueState::Waiting);
  let late = count(&|(_, s, u)| *u == Urgency::Late && still_to_queue(s.queue));

  let query = search().trim().to_lowercase();
  let found = if query.is_empty() {
    None
  } else {
    teams
      .iter()
      .find(|t| t.number.to_lowercase() == query || t.name.to_lowercase().contains(&query))
      .cloned()
  };
  let gap = event.settings.judging_match_gap_minutes;
  let card = |m: &GameMatch, slot: &MatchSlot, u: Urgency| {
    let place = table_name(&tables, slot.table_id);
    let team = slot.team_id.and_then(|id| teams.iter().find(|t| t.id == id)).cloned();
    let note = judging_clash(&sessions, slot.team_id, m.scheduled_start, m.scheduled_end, gap).map(|s| {
      format!(
        "Judging at {}: check the team isn't still there.",
        format_time(s.scheduled_start, &event.timezone)
      )
    });
    rsx! {
      QueueCard {
        key: "{slot.id}",
        slot_id: slot.id,
        state: slot.queue,
        previous: slot.queue_previous,
        colour: table_colour(&place).to_owned(),
        place,
        team_number: team.as_ref().map(|t| t.number.clone()).unwrap_or_default(),
        team_name: team.map(|t| t.name).unwrap_or_default(),
        when: format!("{} · {}", m.label(), relative(m.scheduled_start, now())),
        urgency: u,
        note,
      }
    }
  };

  rsx! {
    PageHeader {
      title: "Robot game queue",
      subtitle: "Soon from {event.settings.queue_soon_minutes} min before a match, Queue now from {event.settings.queue_call_minutes}.",
    }
    div { class: "mb-4 flex flex-wrap items-end gap-3",
      div { class: "flex flex-col gap-1.5",
        span { class: "text-sm font-medium", "My tables" }
        Tabs {
          Tab {
            active: selected.is_none(),
            onclick: move |_| {
                LocalStorage::delete(TABLES_KEY);
                chosen.set(String::new());
            },
            "All tables"
          }
          for (label , _) in pairs.clone() {
            Tab {
              active: chosen() == label,
              onclick: {
                  let label = label.clone();
                  move |_| {
                      let _ = LocalStorage::set(TABLES_KEY, &label);
                      chosen.set(label.clone());
                  }
              },
              "{label}"
            }
          }
        }
      }
      div { class: "min-w-56 flex-1 sm:max-w-xs",
        TextField { label: "Find a team", value: search(), placeholder: "Number or name", oninput: move |v| search.set(v) }
      }
    }
    if let Some(team) = found {
      Card { title: "{team.number} {team.name}", class: "mb-4",
        ul { class: "flex flex-col text-sm",
          for m in matches.iter().filter(|m| m.slots.iter().any(|s| s.team_id == Some(team.id))) {
            li { class: "flex flex-wrap items-center gap-3 border-b border-line py-2 last:border-b-0",
              span { class: "w-14 font-mono", "{format_time(m.scheduled_start, &event.timezone)}" }
              span { class: "w-28 font-medium", "{m.label()}" }
              for slot in m.slots.iter().filter(|s| s.team_id == Some(team.id)) {
                span { class: "text-muted", "{table_name(&tables, slot.table_id)}" }
                QueueBadge { state: slot.queue }
              }
              Badge { tone: match_tone(m.state), "{m.state.label()}" }
            }
          }
          for s in sessions.iter().filter(|s| s.slots.iter().any(|slot| slot.team_id == Some(team.id))) {
            li { class: "flex gap-3 border-b border-line py-2 last:border-b-0",
              span { class: "w-14 font-mono", "{format_time(s.scheduled_start, &event.timezone)}" }
              span { class: "font-medium", "Judging session {s.number}" }
            }
          }
        }
      }
    }
    div { class: "mb-4 grid grid-cols-4 gap-2",
      QueueCount { label: "Late", value: late, tone: Tone::Danger }
      QueueCount { label: "To call", value: to_call, tone: Tone::Warning }
      QueueCount { label: "On the way", value: on_way }
      QueueCount { label: "In the queue", value: waiting, tone: Tone::Success }
    }
    section { class: "mb-6",
      h2 { class: "mb-2 text-lg font-semibold tracking-tight", "Queue now" }
      if active.is_empty() {
        p { class: "rounded-panel border border-dashed border-line-strong p-6 text-center text-muted", "Nobody to queue right now." }
      }
      ul { class: "grid gap-3 md:grid-cols-2 2xl:grid-cols-3", "data-testid": "now-calling",
        for (m , slot , u) in active.iter() {
          {card(m, slot, *u)}
        }
      }
    }
    if !soon.is_empty() {
      section { class: "mb-6",
        h2 { class: "mb-2 text-lg font-semibold tracking-tight", "Soon" }
        p { class: "mb-2 text-sm text-muted", "Start looking for these teams. Calling one early moves it up." }
        ul { class: "grid gap-3 md:grid-cols-2 2xl:grid-cols-3",
          for (m , slot , u) in soon.iter() {
            {card(m, slot, *u)}
          }
        }
      }
    }
    if !later.is_empty() {
      Card { title: "Later",
        ul { class: "flex flex-col text-sm",
          for (m , slot , _) in later {
            {
                let place = table_name(&tables, slot.table_id);
                let team = slot.team_id.and_then(|id| teams.iter().find(|t| t.id == id)).cloned();
                rsx! {
                  li { key: "{slot.id}", class: "flex items-center gap-3 border-b border-line py-2 last:border-b-0",
                    span { class: "w-14 font-mono text-muted", "{format_time(m.scheduled_start, &event.timezone)}" }
                    span { class: "inline-flex w-24 items-center gap-2",
                      span { class: "h-2.5 w-2.5 rounded-full", style: "background:{table_colour(&place)}" }
                      "{place}"
                    }
                    span { class: "w-14 font-bold tabular-nums", {team.as_ref().map(|t| t.number.clone()).unwrap_or_default()} }
                    span { class: "min-w-0 flex-1 truncate", {team.map(|t| t.name).unwrap_or_default()} }
                    span { class: "text-xs text-muted", "{m.label()}" }
                  }
                }
            }
          }
        }
      }
    }
  }
}
