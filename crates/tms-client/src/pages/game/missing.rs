//! Scoresheets the event is still waiting for, and what the head referee or admin can do about each: see what
//! the table's tablet is holding, enter the sheet from paper, or record that the team did not play.

use dioxus::prelude::*;
use tms_core::Topic;
use tms_core::model::{GameMatch, MatchSlot, MatchState};
use tms_core::queue::QueueAction;
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Card, Modal, TextField, Tone};
use uuid::Uuid;

use super::displays::table_colour;
use super::form::{FormTarget, ScoresheetForm};
use super::queue_ui::send_queue_note;
use super::shared::{sorted_matches, table_name, team_number};
use crate::net::realtime::{Realtime, use_subscription};
use crate::store::session::Session;
use crate::time::format_time;

#[component]
pub fn MissingSheets() -> Element {
  use_subscription(Topic::Matches);
  use_subscription(Topic::Teams);
  use_subscription(Topic::Tables);
  use_subscription(Topic::Presence);
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let mut form = use_signal(|| None::<(FormTarget, Uuid)>);
  let mut no_show = use_signal(|| None::<(Uuid, String)>);

  let missing: Vec<(GameMatch, MatchSlot)> = sorted_matches(&realtime.stores.matches.read())
    .into_iter()
    .filter(|m| m.state == MatchState::Finished)
    .flat_map(|m| {
      m.slots
        .iter()
        .filter(|s| s.needs_sheet())
        .map(|s| (m.clone(), s.clone()))
        .collect::<Vec<_>>()
    })
    .collect();
  if let Some((target, table_id)) = form() {
    return rsx! {
      div { class: "fixed inset-0 z-40 overflow-y-auto bg-bg px-3 pb-6 md:px-6",
        ScoresheetForm {
          target,
          table_id: Some(table_id),
          referee_name: session.read().display_name(),
          overlay: true,
          onclose: move |_| form.set(None),
        }
      }
    };
  }
  if missing.is_empty() {
    return rsx! {};
  }
  let tables = realtime.stores.tables.read().clone();
  let teams = realtime.stores.teams.read().clone();
  let presence = realtime.stores.presence.read().clone();
  let timezone = realtime
    .stores
    .event
    .read()
    .as_ref()
    .map_or_else(|| "UTC".to_owned(), |e| e.timezone.clone());

  rsx! {
    Card { title: "Missing scoresheets ({missing.len()})", class: "border-warning",
      p { class: "mb-3 text-sm text-muted",
        "Finished matches still waiting for a sheet. Check the table's tablet first; otherwise enter a paper sheet here, or record that the team did not play."
      }
      ul { class: "flex flex-col", "data-testid": "missing-sheets",
        for (m , slot) in missing {
          {
              let table = table_name(&tables, slot.table_id);
              let team = slot.team_id.and_then(|id| teams.iter().find(|t| t.id == id)).cloned();
              let device = presence.iter().find(|p| p.table_id == Some(slot.table_id)).cloned();
              let target = FormTarget {
                  slot_id: Some(slot.id),
                  team_number: team_number(&teams, slot.team_id),
                  kind: m.kind,
                  round: slot.round,
                  title: m.label(),
              };
              let label = format!("{} {} in {}", team.as_ref().map(|t| t.number.clone()).unwrap_or_default(), team.as_ref().map(|t| t.name.clone()).unwrap_or_default(), m.label());
              let (slot_id, table_id) = (slot.id, slot.table_id);
              rsx! {
                li { key: "{slot.id}", class: "flex flex-wrap items-center gap-x-4 gap-y-2 border-b border-line py-3 last:border-b-0",
                  div { class: "w-28 shrink-0",
                    p { class: "font-semibold", "{m.label()}" }
                    p { class: "font-mono text-xs text-muted", "{format_time(m.scheduled_start, &timezone)}" }
                  }
                  span { class: "inline-flex min-w-0 flex-1 items-center gap-2",
                    span { class: "h-2.5 w-2.5 shrink-0 rounded-full", style: "background:{table_colour(&table)}" }
                    span { class: "w-14 shrink-0 text-sm text-muted", "{table}" }
                    span { class: "font-bold tabular-nums", {team.as_ref().map(|t| t.number.clone()).unwrap_or_default()} }
                    span { class: "truncate", {team.map(|t| t.name).unwrap_or_default()} }
                  }
                  match device {
                      None => rsx! { Badge { tone: Tone::Danger, "Tablet offline" } },
                      Some(p) if p.waiting > 0 => rsx! { Badge { tone: Tone::Warning, "{p.waiting} waiting on the tablet" } },
                      Some(_) => rsx! { Badge { tone: Tone::Neutral, "Tablet online, nothing waiting" } },
                  }
                  div { class: "flex gap-1",
                    Button { size: ButtonSize::Small, variant: ButtonVariant::Secondary, onclick: move |_| form.set(Some((target.clone(), table_id))), "Enter sheet" }
                    Button { size: ButtonSize::Small, variant: ButtonVariant::DangerGhost, onclick: move |_| no_show.set(Some((slot_id, label.clone()))), "Mark no show" }
                  }
                }
              }
          }
        }
      }
    }
    if let Some((slot_id, label)) = no_show() {
      NoShowAfter { slot_id, label, onclose: move |()| no_show.set(None) }
    }
  }
}

/// Records after the match that a team did not play, with the reason for the audit log.
#[component]
fn NoShowAfter(slot_id: Uuid, label: String, onclose: EventHandler<()>) -> Element {
  let session = use_context::<Session>();
  let mut reason = use_signal(String::new);
  let mut error = use_signal(|| None::<String>);
  let waiting = use_signal(|| false);
  rsx! {
    Modal {
      title: "Mark {label} as a no show?",
      onclose,
      footer: rsx! {
        Button { variant: ButtonVariant::Secondary, onclick: move |_| onclose.call(()), "Cancel" }
        Button {
          variant: ButtonVariant::Danger,
          disabled: reason().trim().is_empty(),
          onclick: move |_| async move {
              let path = format!("/slots/{slot_id}/queue");
              match send_queue_note(path, QueueAction::NoShow, reason(), session, waiting).await {
                  Ok(()) => onclose.call(()),
                  Err(message) => error.set(Some(message)),
              }
          },
          "Mark no show"
        }
      },
      p { class: "mb-3 text-sm", "The match stops waiting for this team's sheet. Undo it from the match's row if a sheet turns up." }
      TextField { label: "Reason", value: reason(), placeholder: "Robot not working; team left early", autofocus: true, oninput: move |v| reason.set(v) }
      if let Some(message) = error() {
        p { role: "alert", class: "mt-2 text-sm text-danger-strong", "{message}" }
      }
    }
  }
}
