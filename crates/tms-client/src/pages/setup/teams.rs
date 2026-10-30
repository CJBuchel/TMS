use std::collections::HashMap;

use dioxus::prelude::*;
use tms_core::dto::TeamInput;
use tms_core::model::{MatchKind, Team};
use tms_ui::{Button, ButtonSize, ButtonVariant, DataTable, Modal, TextField};
use uuid::Uuid;

use crate::components::{ConfirmButton, ErrorBox, NeedsActiveEvent, PageHeader, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::Realtime;
use crate::store::session::Session;
use crate::time::format_time;

/// Sorts team numbers numerically when they are numbers ("9" before "10").
pub fn team_order(a: &Team, b: &Team) -> std::cmp::Ordering {
  match (a.number.parse::<u64>(), b.number.parse::<u64>()) {
    (Ok(x), Ok(y)) => x.cmp(&y),
    (Ok(_), Err(_)) => std::cmp::Ordering::Less,
    (Err(_), Ok(_)) => std::cmp::Ordering::Greater,
    _ => a.number.cmp(&b.number),
  }
}

#[component]
pub fn SetupTeams() -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let mut search = use_signal(String::new);
  let mut editing = use_signal(|| None::<Option<Team>>);
  let mut error = use_signal(|| None::<ApiFailure>);

  let Some(event) = realtime.stores.event.read().clone() else {
    return rsx! { PageHeader { title: "Teams" } NeedsActiveEvent {} };
  };

  let mut teams = realtime.stores.teams.read().clone();
  teams.sort_by(team_order);
  let ranking_counts: HashMap<Uuid, usize> = {
    let mut counts = HashMap::new();
    for m in realtime
      .stores
      .matches
      .read()
      .iter()
      .filter(|m| m.kind == MatchKind::Ranking)
    {
      for team in m.slots.iter().filter_map(|s| s.team_id) {
        *counts.entry(team).or_insert(0) += 1;
      }
    }
    counts
  };
  let judging: HashMap<Uuid, String> = realtime
    .stores
    .sessions
    .read()
    .iter()
    .flat_map(|s| {
      s.slots
        .iter()
        .filter_map(|slot| slot.team_id)
        .map(|t| (t, format_time(s.scheduled_start, &event.timezone)))
    })
    .collect();

  let query = search().trim().to_lowercase();
  let shown: Vec<Team> = teams
    .into_iter()
    .filter(|t| {
      query.is_empty()
        || [&t.number, &t.name, &t.affiliation]
          .iter()
          .any(|f| f.to_lowercase().contains(&query))
    })
    .collect();
  let total = realtime.stores.teams.read().len();

  let delete = move |id: Uuid| async move {
    error.set(None);
    if let Err(e) = api::delete(&format!("/teams/{id}"), token(session).as_deref()).await {
      error.set(Some(e));
    }
  };

  rsx! {
    PageHeader {
      title: "Teams",
      subtitle: "{total} teams. Importing a schedule adds and updates teams by number.",
      actions: rsx! {
        Button { onclick: move |_| editing.set(Some(None)), "Add team" }
      },
    }
    div { class: "mb-3 max-w-sm",
      TextField { label: "Search", value: search(), placeholder: "Number, name or affiliation", oninput: move |v| search.set(v) }
    }
    if let Some(e) = error() {
      div { class: "mb-3", ErrorBox { error: e } }
    }
    DataTable {
      columns: vec!["Number".into(), "Name".into(), "Affiliation".into(), "Pit".into(), "Ranking matches".into(), "Judging".into(), String::new()],
      empty: if total == 0 { "No teams yet. Add them here or import a schedule." } else { "No teams match the search." },
      rows: shown
          .into_iter()
          .map(|t| {
              let id = t.id;
              let edit = t.clone();
              rsx! {
                tr {
                  td { class: "font-mono font-semibold", "{t.number}" }
                  td { "{t.name}" }
                  td { class: "text-muted", "{t.affiliation}" }
                  td { {t.pit.clone().unwrap_or_default()} }
                  td { "{ranking_counts.get(&id).copied().unwrap_or(0)}" }
                  td { {judging.get(&id).cloned().unwrap_or_else(|| "–".into())} }
                  td { class: "text-right whitespace-nowrap",
                    Button { variant: ButtonVariant::Secondary, size: ButtonSize::Small, onclick: move |_| editing.set(Some(Some(edit.clone()))), "Edit" }
                    ConfirmButton {
                      label: "Delete",
                      title: "Delete team {t.number}?",
                      message: "This removes {t.name}. A team that is in the schedule cannot be deleted.",
                      confirm_label: "Delete team",
                      onconfirm: move |()| { spawn(delete(id)); },
                    }
                  }
                }
              }
          })
          .collect(),
    }
    if let Some(team) = editing() {
      TeamForm { event_id: event.id, team, onclose: move |()| editing.set(None) }
    }
  }
}

#[component]
fn TeamForm(event_id: Uuid, team: Option<Team>, onclose: EventHandler<()>) -> Element {
  let session = use_context::<Session>();
  let existing = team.as_ref().map(|t| t.id);
  let mut number = use_signal(|| team.as_ref().map(|t| t.number.clone()).unwrap_or_default());
  let mut name = use_signal(|| team.as_ref().map(|t| t.name.clone()).unwrap_or_default());
  let mut affiliation = use_signal(|| team.as_ref().map(|t| t.affiliation.clone()).unwrap_or_default());
  let mut pit = use_signal(|| team.as_ref().and_then(|t| t.pit.clone()).unwrap_or_default());
  let mut notes = use_signal(|| team.as_ref().map(|t| t.notes.clone()).unwrap_or_default());
  let mut error = use_signal(|| None::<ApiFailure>);
  let mut busy = use_signal(|| false);

  let save = move |_| async move {
    busy.set(true);
    error.set(None);
    let body = TeamInput {
      number: number(),
      name: name(),
      affiliation: affiliation(),
      pit: Some(pit()),
      notes: notes(),
    };
    let token = token(session);
    let result = match existing {
      Some(id) => api::patch::<_, Team>(&format!("/teams/{id}"), token.as_deref(), &body).await,
      None => api::post::<_, Team>(&format!("/events/{event_id}/teams"), token.as_deref(), &body).await,
    };
    busy.set(false);
    match result {
      Ok(_) => onclose.call(()),
      Err(e) => error.set(Some(e)),
    }
  };

  rsx! {
    Modal {
      title: if existing.is_some() { "Edit team" } else { "Add team" },
      onclose,
      footer: rsx! {
        Button { variant: ButtonVariant::Secondary, onclick: move |_| onclose.call(()), "Cancel" }
        Button { loading: busy(), onclick: save, "Save team" }
      },
      div { class: "flex flex-col gap-3",
        div { class: "grid grid-cols-3 gap-3",
          TextField { label: "Number", value: number(), mono: true, autofocus: true, oninput: move |v| number.set(v) }
          div { class: "col-span-2",
            TextField { label: "Name", value: name(), oninput: move |v| name.set(v) }
          }
        }
        TextField { label: "Affiliation", value: affiliation(), placeholder: "School or club", oninput: move |v| affiliation.set(v) }
        TextField { label: "Pit", value: pit(), placeholder: "Optional", oninput: move |v| pit.set(v) }
        TextField { label: "Notes", value: notes(), placeholder: "Optional", oninput: move |v| notes.set(v) }
        if let Some(e) = error() {
          ErrorBox { error: e }
        }
      }
    }
  }
}
