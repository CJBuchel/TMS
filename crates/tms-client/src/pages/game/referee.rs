//! The referee station: this table's current and next matches, matches still to score, and this table's sheets.

use dioxus::prelude::*;
use gloo_storage::{LocalStorage, Storage};
use tms_core::Topic;
use tms_core::dto::Principal;
use tms_core::game::ScoresheetStatus;
use tms_core::model::{GameMatch, MatchKind, MatchSlot, MatchState, QueueState};
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Card, Select, TextField, Tone};
use uuid::Uuid;

use super::displays::{on_table_colour, table_colour};
use super::form::{FormTarget, ScoresheetForm};
use super::queue_ui::{QueueBadge, QueueButtons, QueueProgress, relative};
use super::shared::{match_tone, sheet_tone, sorted_matches, table_name, team_label, team_number, use_server_now};
use crate::components::{NeedsActiveEvent, PageHeader, SuccessBox};
use crate::net::realtime::{Realtime, use_subscription};
use crate::routes::Route;
use crate::store::outbox::{Outbox, OutboxState};
use crate::store::session::{Session, SessionState, remembered_table};
use crate::time::format_time;

const TABLE_KEY: &str = "tms.referee.table";
const NAME_KEY: &str = "tms.referee.name";

/// The table this station serves: the access key's table if it has one (remembered from its last verified login
/// when the key is not verified yet), otherwise the one chosen on this device.
fn bound_table(session: &SessionState) -> Option<Uuid> {
  match session {
    SessionState::Online { identity, .. } => match &identity.principal {
      Principal::Key { table_id, .. } => *table_id,
      Principal::User { .. } => None,
    },
    SessionState::OfflineKey { key, .. } => remembered_table(key),
    SessionState::LoggedOut => None,
  }
}

#[component]
pub fn RefereeStation() -> Element {
  use_subscription(Topic::Matches);
  use_subscription(Topic::Teams);
  use_subscription(Topic::Tables);
  use_subscription(Topic::Scoresheets);
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let outbox = use_context::<Outbox>();
  let mut chosen = use_signal(|| LocalStorage::get::<Uuid>(TABLE_KEY).ok());
  let mut referee = use_signal(|| LocalStorage::get::<String>(NAME_KEY).unwrap_or_default());
  let mut form = use_signal(|| None::<FormTarget>);
  let mut notice = use_signal(|| None::<String>);
  let now = use_server_now();

  let Some(event) = realtime.stores.event.read().clone() else {
    return rsx! { PageHeader { title: "Referee station" } NeedsActiveEvent {} };
  };
  let bound = bound_table(&session.read());
  let table_id = bound.or(chosen());
  let tables = realtime.stores.tables.read().clone();
  let teams = realtime.stores.teams.read().clone();

  if let Some(target) = form() {
    return rsx! {
      ScoresheetForm {
        target,
        table_id,
        referee_name: referee(),
        onclose: move |outcome: Option<OutboxState>| {
            notice.set(outcome.map(|o| match o {
                OutboxState::Sent { counted: true, .. } => "Scoresheet sent and published.".to_owned(),
                OutboxState::Sent { .. } => "Scoresheet sent. The head referee will review it.".to_owned(),
                _ => "Scoresheet saved on this device. It will be sent when the server can be reached.".to_owned(),
            }));
            form.set(None);
        },
      }
    };
  }

  let table_select = rsx! {
    if bound.is_some() {
      p { class: "text-sm", "This device's access key is for {table_name(&tables, bound.unwrap_or_default())}." }
    } else {
      Select {
        label: "Table",
        value: chosen().map(|t| t.to_string()).unwrap_or_default(),
        options: std::iter::once((String::new(), "Choose a table".to_owned()))
            .chain(tables.iter().map(|t| (t.id.to_string(), t.name.clone())))
            .collect(),
        onchange: move |v: String| {
            let id = v.parse::<Uuid>().ok();
            match id {
                Some(id) => {
                    let _ = LocalStorage::set(TABLE_KEY, id);
                }
                None => LocalStorage::delete(TABLE_KEY),
            }
            chosen.set(id);
        },
      }
    }
  };

  let Some(table_id) = table_id else {
    return rsx! {
      PageHeader { title: "Referee station" }
      Card { title: "Which table is this?", div { class: "max-w-sm", {table_select} } }
    };
  };

  let matches = sorted_matches(&realtime.stores.matches.read());
  let on_table = |m: &GameMatch| m.slots.iter().find(|s| s.table_id == table_id).cloned();
  // The match on the timer if there is one; otherwise this table's next match, so its team can be taken in early.
  let current: Option<(GameMatch, MatchSlot)> = matches
    .iter()
    .filter(|m| matches!(m.state, MatchState::Staged | MatchState::Running))
    .find_map(|m| on_table(m).map(|s| (m.clone(), s)))
    .or_else(|| {
      matches
        .iter()
        .filter(|m| m.state == MatchState::Scheduled)
        .find_map(|m| on_table(m).filter(|s| s.team_id.is_some()).map(|s| (m.clone(), s)))
    });
  let current_id = current.as_ref().map(|(m, _)| m.id);
  let to_score: Vec<(GameMatch, MatchSlot)> = matches
    .iter()
    .filter(|m| m.state == MatchState::Finished)
    .filter_map(|m| on_table(m).map(|s| (m.clone(), s)))
    .filter(|(_, s)| s.needs_sheet())
    .collect();
  let next: Vec<(GameMatch, MatchSlot)> = matches
    .iter()
    .filter(|m| m.state == MatchState::Scheduled && Some(m.id) != current_id)
    .filter_map(|m| on_table(m).map(|s| (m.clone(), s)))
    .filter(|(_, s)| s.team_id.is_some())
    .take(5)
    .collect();
  let mut recent: Vec<_> = realtime
    .stores
    .scoresheets
    .read()
    .iter()
    .filter(|s| s.table_id == Some(table_id))
    .cloned()
    .collect();
  recent.sort_by_key(|s| std::cmp::Reverse(s.received_at));
  recent.truncate(10);

  let target = move |m: &GameMatch, slot: &MatchSlot| FormTarget {
    slot_id: Some(slot.id),
    team_number: team_number(&realtime.stores.teams.peek(), slot.team_id),
    kind: m.kind,
    round: slot.round,
    title: m.label(),
  };

  let table = table_name(&tables, table_id);
  let colour = table_colour(&table);
  let on_colour = on_table_colour(&table);
  let team_of = |id: Option<Uuid>| id.and_then(|id| teams.iter().find(|t| t.id == id)).cloned();

  rsx! {
    PageHeader {
      title: "Referee station: {table}",
      actions: rsx! {
        Button {
          variant: ButtonVariant::Secondary,
          onclick: move |_| form.set(Some(FormTarget { slot_id: None, team_number: String::new(), kind: MatchKind::Ranking, round: None, title: "Unscheduled".into() })),
          "Add unscheduled scoresheet"
        }
      },
    }
    if let Some(message) = notice() {
      div { class: "mb-3", SuccessBox { message } }
    }
    if outbox.pending() > 0 || outbox.items().iter().any(|i| matches!(i.state, OutboxState::NeedsBinding { .. } | OutboxState::Rejected { .. })) {
      div { class: "mb-3 flex flex-wrap items-center gap-3 rounded-control border border-warning bg-warning-soft px-3 py-2 text-sm text-warning-strong", "data-testid": "outbox-warning",
        span { "{outbox.pending()} scoresheet(s) on this device are waiting to be sent, or need attention." }
        Link { to: Route::Settings {}, class: "font-semibold underline", "See this device's scoresheets" }
      }
    }

    if !to_score.is_empty() {
      div { class: "mb-4 flex flex-col gap-2",
        for (m , slot) in to_score {
          div { class: "flex flex-wrap items-center gap-4 rounded-panel border border-warning bg-warning-soft p-4",
            div { class: "min-w-0 flex-1",
              p { class: "text-sm font-semibold text-warning-strong", "To score · {m.label()}" }
              p { class: "text-2xl font-bold tracking-tight", "{team_label(&teams, slot.team_id)}" }
            }
            Button { size: ButtonSize::Large, variant: ButtonVariant::Warning, onclick: move |_| form.set(Some(target(&m, &slot))), "Score" }
          }
        }
      }
    }

    section { class: "mb-4 overflow-hidden rounded-panel border border-line bg-surface shadow-panel",
      div { class: "flex items-center justify-between gap-3 px-5 py-2.5 text-sm font-semibold", style: "background:{colour};color:{on_colour}",
        span { class: "uppercase tracking-wider", "{table} table" }
        if let Some((m, _)) = current.as_ref() {
          span { class: "tabular-nums", "{m.label()} · {format_time(m.scheduled_start, &event.timezone)}" }
        }
      }
      div { class: "p-5",
        match current.clone() {
          Some((m, slot)) => rsx! {
            div { class: "flex flex-wrap items-start justify-between gap-4",
              div { class: "min-w-0",
                p { class: "text-sm font-medium text-muted",
                  if m.state == MatchState::Scheduled { "Next on this table · " } else { "Now on this table · " }
                  "{m.label()}, round {slot.round.unwrap_or(0)} · {relative(m.scheduled_start, now())}"
                }
                match team_of(slot.team_id) {
                    Some(team) => rsx! {
                      div { class: "mt-1 flex min-w-0 flex-wrap items-baseline gap-x-4",
                        span { class: "text-7xl leading-none font-extrabold tracking-tight tabular-nums", "{team.number}" }
                        span { class: "text-3xl font-bold tracking-tight", "{team.name}" }
                      }
                    },
                    None => rsx! { p { class: "mt-1 text-3xl font-bold text-muted", "No team" } },
                }
              }
              div { class: "flex flex-wrap gap-2",
                Badge { tone: match_tone(m.state), "{m.state.label()}" }
                if slot.team_id.is_some() {
                  QueueBadge { state: slot.queue }
                }
              }
            }
            if slot.team_id.is_some() {
              div { class: "mt-5", QueueProgress { state: slot.queue, labels: true } }
              div { class: "mt-5", "data-testid": "now-queue",
                QueueButtons { slot_id: slot.id, state: slot.queue, previous: slot.queue_previous, large: true }
              }
            }
            if matches!(m.state, MatchState::Running | MatchState::Finished) {
              div { class: "mt-4",
                Button { size: ButtonSize::Huge, full_width: true, disabled: slot.team_id.is_none(), onclick: move |_| form.set(Some(target(&m, &slot))), "Score this match" }
              }
            }
          },
          None => rsx! {
            div { class: "py-6 text-center",
              p { class: "text-xl font-semibold", "No more matches on this table." }
              p { class: "text-sm text-muted", "Finished matches still to score are below." }
            }
          },
        }
      }
    }

    div { class: "grid items-start gap-4 lg:grid-cols-2",
      Card { title: "Up next",
        if next.is_empty() {
          p { class: "text-sm text-muted", "No more scheduled matches on this table." }
        }
        ol { class: "relative flex flex-col",
          for (m , slot) in next {
            li { class: "flex items-center gap-3 border-b border-line py-2.5 last:border-b-0",
              span { class: "w-14 font-mono text-sm text-muted", "{format_time(m.scheduled_start, &event.timezone)}" }
              match team_of(slot.team_id) {
                  Some(team) => rsx! {
                    span { class: "w-12 text-lg font-bold tabular-nums", "{team.number}" }
                    span { class: "min-w-0 flex-1 truncate", "{team.name}" }
                  },
                  None => rsx! { span { class: "flex-1 text-muted", "No team" } },
              }
              span { class: "text-xs text-muted", "{m.label()}" }
              if slot.queue != QueueState::NotCalled {
                QueueBadge { state: slot.queue }
              }
            }
          }
        }
      }
      Card { title: "This table's scoresheets",
        if recent.is_empty() {
          p { class: "text-sm text-muted", "None yet." }
        }
        ul { class: "flex flex-col",
          for sheet in recent {
            li { class: "border-b border-line py-2.5 text-sm last:border-b-0",
              div { class: "flex items-center gap-3",
                span { class: "w-12 text-base font-bold tabular-nums", "{sheet.team_number}" }
                span { class: "flex-1 text-muted", "{sheet.kind.label()} round {sheet.round}" }
                span { class: "font-semibold tabular-nums", "{sheet.score} pts" }
                Badge { tone: sheet_tone(sheet.status), "{sheet.status.label()}" }
              }
              if sheet.status == ScoresheetStatus::Rejected && !sheet.review_note.is_empty() {
                p { class: "mt-1 text-danger-strong", "Head referee: {sheet.review_note}" }
              }
            }
          }
        }
      }
      Card { title: "This device",
        div { class: "flex max-w-sm flex-col gap-3",
          TextField {
            label: "Referee name",
            value: referee(),
            hint: "Printed on this device's scoresheets.",
            oninput: move |v: String| {
                let _ = LocalStorage::set(NAME_KEY, &v);
                referee.set(v);
            },
          }
          {table_select}
        }
      }
    }
    if realtime.stores.matches.read().iter().all(|m| m.slots.iter().all(|s| s.table_id != table_id)) {
      p { class: "mt-3", Badge { tone: Tone::Warning, "No matches are scheduled on this table." } }
    }
  }
}
