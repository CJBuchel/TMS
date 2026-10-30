use std::collections::HashMap;

use chrono::NaiveDateTime;
use dioxus::prelude::*;
use tms_core::Topic;
use tms_core::dto::{BlockInput, ImportPreview};
use tms_core::model::{BlockKind, MatchKind, MatchState, ScheduleBlock};
use tms_ui::{Badge, Button, ButtonVariant, Card, DataTable, Select, TextField, Tone};
use uuid::Uuid;

use super::schedule_edit::{Generate, IssueList, ScheduleIssues, SlotEditor};
use crate::components::{ConfirmButton, ErrorBox, NeedsActiveEvent, PageHeader, SuccessBox, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::{Realtime, use_subscription};
use crate::store::session::Session;
use crate::time::{format_datetime, format_time, local_input};

#[component]
pub fn SetupSchedule() -> Element {
  use_subscription(Topic::Issues);
  let realtime = use_context::<Realtime>();
  let editing = use_signal(|| None::<Editing>);
  let Some(event) = realtime.stores.event.read().clone() else {
    return rsx! { PageHeader { title: "Schedule" } NeedsActiveEvent {} };
  };
  rsx! {
    PageHeader { title: "Schedule", subtitle: "Generate the schedule or import it from Tournament-in-a-Box, then check it and adjust it by hand. Times are {event.timezone}." }
    div { class: "flex flex-col gap-4",
      ScheduleIssues {}
      Generate { event_id: event.id, day: event.starts_on }
      Import { event_id: event.id }
      Matches { timezone: event.timezone.clone(), editing }
      Judging { timezone: event.timezone.clone(), editing }
      Blocks { event_id: event.id, timezone: event.timezone.clone() }
    }
    if let Some(e) = editing() {
      SlotEditor {
        slot_id: e.slot_id,
        match_id: e.parent_id,
        title: e.title,
        team_id: e.team_id,
        start: e.start,
        judging: e.judging,
        onclose: move |()| {
            let mut editing = editing;
            editing.set(None);
        },
      }
    }
  }
}

/// The slot being edited: a match slot, or a judging slot (`judging`) whose parent is its session.
#[derive(Clone, PartialEq)]
struct Editing {
  slot_id: Uuid,
  parent_id: Uuid,
  title: String,
  team_id: Option<Uuid>,
  start: String,
  judging: bool,
}

#[component]
fn Import(event_id: Uuid) -> Element {
  let session = use_context::<Session>();
  let mut file_name = use_signal(|| None::<String>);
  let mut text = use_signal(String::new);
  let mut preview = use_signal(|| None::<ImportPreview>);
  let mut error = use_signal(|| None::<ApiFailure>);
  let mut done = use_signal(|| None::<String>);
  let mut busy = use_signal(|| false);

  let choose = move |e: FormEvent| async move {
    preview.set(None);
    error.set(None);
    done.set(None);
    let Some(file) = e.files().into_iter().next() else {
      return;
    };
    file_name.set(Some(file.name()));
    match file.read_string().await {
      Ok(contents) => text.set(contents),
      Err(err) => error.set(Some(ApiFailure::Api {
        status: 0,
        code: "file".into(),
        message: format!("Could not read the file: {err}"),
        details: vec![],
      })),
    }
  };

  let send = move |commit: bool| async move {
    busy.set(true);
    error.set(None);
    let path = format!(
      "/events/{event_id}/import/tiab{}",
      if commit { "?commit=true" } else { "" }
    );
    match api::post_text::<ImportPreview>(&path, token(session).as_deref(), text()).await {
      Ok(p) if commit => {
        done.set(Some(format!(
          "Imported {} ranking and {} practice matches and {} judging sessions.",
          p.ranking_matches, p.practice_matches, p.judging_sessions
        )));
        preview.set(None);
      }
      Ok(p) => preview.set(Some(p)),
      Err(e) => {
        preview.set(None);
        error.set(Some(e));
      }
    }
    busy.set(false);
  };

  let replaces = preview().map_or(0, |p| p.replaces_matches + p.replaces_sessions);
  rsx! {
    Card { title: "Import schedule",
      div { class: "flex flex-col gap-3",
        p { class: "text-sm text-muted",
          "Export the schedule CSV from the FIRST Australia FLL Scheduler (Tournament-in-a-Box). Checking it changes nothing; importing replaces every match and judging session, and adds or updates teams, tables and pods."
        }
        label { class: "flex flex-wrap items-center gap-3",
          span { class: "inline-flex h-9 cursor-pointer items-center border border-line-strong bg-surface px-3 text-sm font-semibold rounded-tms hover:bg-surface-2",
            "Choose CSV file"
          }
          input { r#type: "file", accept: ".csv,text/csv", class: "sr-only", onchange: choose }
          span { class: "text-sm text-muted", {file_name().unwrap_or_else(|| "No file chosen".into())} }
        }
        div { class: "flex flex-wrap gap-2",
          Button {
            variant: ButtonVariant::Secondary,
            disabled: text().is_empty(),
            loading: busy() && preview().is_none(),
            onclick: move |_| { spawn(send(false)); },
            "Check file"
          }
          Button {
            variant: ButtonVariant::Ghost,
            onclick: move |_| async move {
                let path = format!("/events/{event_id}/schedule/export.csv");
                if let Err(e) = api::download(&path, token(session).as_deref(), "schedule.csv").await {
                    error.set(Some(e));
                }
            },
            "Download the current schedule"
          }
          if preview().is_some() {
            if replaces > 0 {
              ConfirmButton {
                label: "Import",
                variant: ButtonVariant::Warning,
                size: tms_ui::ButtonSize::Medium,
                title: "Replace the current schedule?",
                message: "The {replaces} matches and judging sessions in TMS now are replaced by the ones in this file.",
                confirm_label: "Replace schedule",
                onconfirm: move |()| { spawn(send(true)); },
              }
            } else {
              Button { loading: busy(), onclick: move |_| { spawn(send(true)); }, "Import" }
            }
          }
        }
        if let Some(e) = error() {
          ErrorBox { error: e }
        }
        if let Some(message) = done() {
          SuccessBox { message }
        }
        if let Some(p) = preview() {
          PreviewSummary { preview: p, heading: "The file is valid. Importing it will:" }
        }
      }
    }
  }
}

#[component]
pub fn PreviewSummary(
  preview: ImportPreview,
  #[props(default = "Saving this schedule will:".to_string())] heading: String,
) -> Element {
  let days: Vec<String> = preview.days.iter().map(ToString::to_string).collect();
  let line = |label: &str, value: String| {
    rsx! {
      div { class: "flex justify-between gap-4 border-b border-line py-1 last:border-b-0",
        dt { class: "text-muted", "{label}" }
        dd { class: "text-right font-medium tabular-nums", "{value}" }
      }
    }
  };
  let list = |items: &[String]| {
    if items.is_empty() {
      "none".to_owned()
    } else {
      items.join(", ")
    }
  };
  rsx! {
    div { class: "rounded-control border border-info bg-info-soft p-3 text-sm",
      p { class: "mb-2 font-semibold text-info-strong", "{heading}" }
      dl {
        {line("Add teams", preview.teams_added.len().to_string())}
        {line("Update teams", list(&preview.teams_updated))}
        {line("Keep teams not in the file", list(&preview.teams_not_in_file))}
        {line("Add tables", list(&preview.tables_added))}
        {line("Add pods", list(&preview.pods_added))}
        {line("Practice matches", preview.practice_matches.to_string())}
        {line("Ranking matches", preview.ranking_matches.to_string())}
        {line("Judging sessions", preview.judging_sessions.to_string())}
        {line("Event days", days.join(", "))}
        {line("Replace existing", format!("{} matches, {} sessions", preview.replaces_matches, preview.replaces_sessions))}
      }
      if !preview.warnings.is_empty() {
        div { class: "rounded-control mt-2 border border-warning bg-warning-soft p-2 text-warning-strong",
          p { class: "font-semibold", "Warnings" }
          ul { class: "list-disc pl-5",
            for w in preview.warnings.iter() {
              li { "{w}" }
            }
          }
        }
      }
      div { class: "rounded-control mt-2 border border-line bg-surface p-2",
        p { class: "mb-1 font-semibold", "Schedule checks" }
        if preview.issues.is_empty() {
          p { class: "text-success-strong", "No problems found." }
        } else {
          IssueList { issues: preview.issues.clone() }
        }
      }
    }
  }
}

#[component]
fn Matches(timezone: String, editing: Signal<Option<Editing>>) -> Element {
  let realtime = use_context::<Realtime>();
  let mut tables = realtime.stores.tables.read().clone();
  tables.sort_by_key(|t| t.sort_order);
  let numbers: HashMap<Uuid, String> = realtime
    .stores
    .teams
    .read()
    .iter()
    .map(|t| (t.id, t.number.clone()))
    .collect();
  let mut matches = realtime.stores.matches.read().clone();
  matches.sort_by_key(|m| (m.scheduled_start, m.number));

  let mut columns = vec!["#".to_owned(), "Kind".to_owned(), "Start".to_owned()];
  columns.extend(tables.iter().map(|t| t.name.clone()));
  let rows = matches
    .iter()
    .map(|m| {
      let tone = if m.kind == MatchKind::Practice {
        Tone::Info
      } else {
        Tone::Neutral
      };
      let editable = m.state == MatchState::Scheduled;
      let cells: Vec<Option<Editing>> = tables
        .iter()
        .map(|t| {
          m.slots.iter().find(|s| s.table_id == t.id).map(|s| Editing {
            slot_id: s.id,
            parent_id: m.id,
            title: format!("{} · {}", m.label(), t.name),
            team_id: s.team_id,
            start: local_input(m.scheduled_start, &timezone),
            judging: false,
          })
        })
        .collect();
      rsx! {
        tr {
          td { class: "font-mono", "{m.number}" }
          td {
            Badge { tone, "{m.kind.label()}" }
          }
          td { class: "whitespace-nowrap", {format_datetime(m.scheduled_start, &timezone)} }
          for cell in cells {
            td { class: "font-mono",
              {slot_cell(cell, editable && !matches!(m.state, MatchState::Cancelled), &numbers, editing)}
            }
          }
        }
      }
    })
    .collect();
  rsx! {
    Card { title: "Matches ({matches.len()})",
      DataTable { columns, empty: "No matches. Import a schedule.", rows }
    }
  }
}

/// A team number that opens the slot editor, or plain text when the slot can't change.
fn slot_cell(
  cell: Option<Editing>,
  editable: bool,
  numbers: &HashMap<Uuid, String>,
  mut editing: Signal<Option<Editing>>,
) -> Element {
  let Some(cell) = cell else {
    return rsx! {};
  };
  let label = cell
    .team_id
    .and_then(|id| numbers.get(&id).cloned())
    .unwrap_or_else(|| "–".into());
  if !editable {
    return rsx! { "{label}" };
  }
  rsx! {
    button {
      class: "rounded-control min-w-8 border border-transparent px-1 text-left hover:border-line-strong hover:bg-surface-2",
      title: "Change",
      onclick: move |_| editing.set(Some(cell.clone())),
      "{label}"
    }
  }
}

#[component]
fn Judging(timezone: String, editing: Signal<Option<Editing>>) -> Element {
  let realtime = use_context::<Realtime>();
  let mut pods = realtime.stores.pods.read().clone();
  pods.sort_by_key(|p| p.sort_order);
  let numbers: HashMap<Uuid, String> = realtime
    .stores
    .teams
    .read()
    .iter()
    .map(|t| (t.id, t.number.clone()))
    .collect();
  let mut sessions = realtime.stores.sessions.read().clone();
  sessions.sort_by_key(|s| (s.scheduled_start, s.number));

  let mut columns = vec!["#".to_owned(), "Start".to_owned()];
  columns.extend(pods.iter().map(|p| p.name.clone()));
  let rows = sessions
    .iter()
    .map(|s| {
      let cells: Vec<Option<Editing>> = pods
        .iter()
        .map(|p| {
          s.slots.iter().find(|slot| slot.pod_id == p.id).map(|slot| Editing {
            slot_id: slot.id,
            parent_id: s.id,
            title: format!("Judging {} · {}", s.number, p.name),
            team_id: slot.team_id,
            start: local_input(s.scheduled_start, &timezone),
            judging: true,
          })
        })
        .collect();
      rsx! {
        tr {
          td { class: "font-mono", "{s.number}" }
          td { class: "whitespace-nowrap", {format_datetime(s.scheduled_start, &timezone)} }
          for cell in cells {
            td { class: "font-mono", {slot_cell(cell, true, &numbers, editing)} }
          }
        }
      }
    })
    .collect();
  rsx! {
    Card { title: "Judging sessions ({sessions.len()})",
      DataTable { columns, empty: "No judging sessions. Import a schedule.", rows }
    }
  }
}

#[component]
fn Blocks(event_id: Uuid, timezone: String) -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let mut kind = use_signal(|| BlockKind::Break);
  let mut name = use_signal(String::new);
  let mut starts = use_signal(String::new);
  let mut ends = use_signal(String::new);
  let mut error = use_signal(|| None::<ApiFailure>);

  let mut blocks: Vec<ScheduleBlock> = realtime.stores.blocks.read().clone();
  blocks.sort_by_key(|b| b.starts_at);

  let add = move |e: FormEvent| async move {
    e.prevent_default();
    error.set(None);
    let parse = |v: String| NaiveDateTime::parse_from_str(&v, "%Y-%m-%dT%H:%M");
    let (Ok(starts_local), Ok(ends_local)) = (parse(starts()), parse(ends())) else {
      return error.set(Some(ApiFailure::Api {
        status: 0,
        code: "input".into(),
        message: "Choose a start and an end time.".into(),
        details: vec![],
      }));
    };
    let body = BlockInput {
      kind: kind(),
      name: name(),
      starts_local,
      ends_local,
    };
    match api::post::<_, ScheduleBlock>(&format!("/events/{event_id}/blocks"), token(session).as_deref(), &body).await {
      Ok(_) => name.set(String::new()),
      Err(e) => error.set(Some(e)),
    }
  };
  let delete = move |id: Uuid| async move {
    if let Err(e) = api::delete(&format!("/blocks/{id}"), token(session).as_deref()).await {
      error.set(Some(e));
    }
  };

  let kinds: Vec<(String, String)> = BlockKind::ALL
    .iter()
    .map(|k| (k.key().to_owned(), k.label().to_owned()))
    .collect();
  rsx! {
    Card { title: "Timetable",
      p { class: "mb-3 text-sm text-muted", "Breaks, ceremonies and briefings shown on schedules and displays." }
      DataTable {
        columns: vec!["Kind".into(), "Name".into(), "From".into(), "To".into(), String::new()],
        empty: "Nothing on the timetable yet.",
        rows: blocks
            .iter()
            .map(|b| {
                let id = b.id;
                rsx! {
                  tr {
                    td {
                      Badge { "{b.kind.label()}" }
                    }
                    td { "{b.name}" }
                    td { class: "whitespace-nowrap", {format_datetime(b.starts_at, &timezone)} }
                    td { class: "whitespace-nowrap", {format_time(b.ends_at, &timezone)} }
                    td { class: "text-right",
                      ConfirmButton {
                        label: "Delete",
                        title: "Delete {b.name}?",
                        message: "It is removed from the timetable.",
                        confirm_label: "Delete",
                        onconfirm: move |()| { spawn(delete(id)); },
                      }
                    }
                  }
                }
            })
            .collect(),
      }
      form { class: "mt-3 grid items-end gap-3 sm:grid-cols-5", onsubmit: add,
        Select { label: "Kind", value: kind().key(), options: kinds, onchange: move |v: String| kind.set(BlockKind::from_key(&v).unwrap_or(BlockKind::Other)) }
        TextField { label: "Name", value: name(), placeholder: "Lunch", oninput: move |v| name.set(v) }
        TextField { label: "From", r#type: "datetime-local", value: starts(), oninput: move |v| starts.set(v) }
        TextField { label: "To", r#type: "datetime-local", value: ends(), oninput: move |v| ends.set(v) }
        Button { r#type: "submit", disabled: name().trim().is_empty(), "Add" }
      }
      if let Some(e) = error() {
        div { class: "mt-3", ErrorBox { error: e } }
      }
    }
  }
}
