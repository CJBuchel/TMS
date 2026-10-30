//! Generating a schedule, the list of schedule issues, and editing matches and judging sessions by hand.

use chrono::{NaiveDate, NaiveDateTime};
use dioxus::prelude::*;
use tms_core::dto::{
  GeneratePreview, GenerateRequest, MoveRequest, ProposedEntry, SlotAssignRequest, SlotSwapRequest, SwapOption,
};
use tms_core::model::Team;
use tms_core::validation::{IssueSeverity, ScheduleIssue};
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Card, DataTable, Modal, Select, TextField, Tone};
use uuid::Uuid;

use super::schedule::PreviewSummary;
use super::team_order;
use crate::components::{ConfirmButton, ErrorBox, SuccessBox, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::Realtime;
use crate::store::session::Session;
use crate::time::format_time;

fn input_error(message: &str) -> ApiFailure {
  ApiFailure::Api {
    status: 0,
    code: "input".into(),
    message: message.into(),
    details: vec![],
  }
}

fn parse_local(value: &str) -> Option<NaiveDateTime> {
  NaiveDateTime::parse_from_str(value, "%Y-%m-%dT%H:%M").ok()
}

/// Errors first, then warnings.
#[component]
pub fn IssueList(issues: Vec<ScheduleIssue>) -> Element {
  let mut sorted = issues;
  sorted.sort_by(|a, b| (a.severity, &a.message).cmp(&(b.severity, &b.message)));
  rsx! {
    ul { class: "flex flex-col gap-1 text-sm", "data-testid": "issue-list",
      for issue in sorted {
        li { key: "{issue.id}", class: "flex items-start gap-2",
          match issue.severity {
              IssueSeverity::Error => rsx! { Badge { tone: Tone::Danger, "Error" } },
              IssueSeverity::Warning => rsx! { Badge { tone: Tone::Warning, "Warning" } },
          }
          span { "{issue.message}" }
        }
      }
    }
  }
}

#[component]
pub fn ScheduleIssues() -> Element {
  let realtime = use_context::<Realtime>();
  let issues = realtime.stores.issues.read().clone();
  let errors = issues.iter().filter(|i| i.severity == IssueSeverity::Error).count();
  let warnings = issues.len() - errors;
  rsx! {
    Card { title: "Schedule checks",
      if issues.is_empty() {
        p { class: "text-sm text-success-strong", "No problems found." }
      } else {
        p { class: "mb-2 text-sm text-muted", "{errors} error(s) and {warnings} warning(s). Errors mean the schedule can't run as written; warnings make a team's day harder." }
        IssueList { issues }
      }
    }
  }
}

#[component]
pub fn Generate(event_id: Uuid, day: NaiveDate) -> Element {
  let session = use_context::<Session>();
  let mut match_start = use_signal(|| format!("{day}T09:00"));
  let mut judging_start = use_signal(|| format!("{day}T09:00"));
  let mut cycle = use_signal(|| "10".to_owned());
  let mut seed = use_signal(|| 1u64);
  let mut proposal = use_signal(|| None::<GeneratePreview>);
  let mut error = use_signal(|| None::<ApiFailure>);
  let mut done = use_signal(|| None::<String>);
  let mut busy = use_signal(|| false);

  let send = move |commit: bool| async move {
    error.set(None);
    done.set(None);
    let (Some(match_start_local), Some(judging_start_local)) =
      (parse_local(&match_start()), parse_local(&judging_start()))
    else {
      return error.set(Some(input_error(
        "Choose when the first match and the first judging session start.",
      )));
    };
    let Ok(match_cycle_minutes) = cycle().trim().parse::<u32>() else {
      return error.set(Some(input_error("The match cycle is a number of minutes.")));
    };
    busy.set(true);
    let body = GenerateRequest {
      match_start_local,
      judging_start_local,
      match_cycle_minutes,
      seed: seed(),
    };
    let path = format!(
      "/events/{event_id}/schedule/generate{}",
      if commit { "?commit=true" } else { "" }
    );
    match api::post::<_, GeneratePreview>(&path, token(session).as_deref(), &body).await {
      Ok(p) if commit => {
        done.set(Some(format!(
          "Saved: {} ranking and {} practice matches and {} judging sessions.",
          p.preview.ranking_matches, p.preview.practice_matches, p.preview.judging_sessions
        )));
        proposal.set(None);
      }
      Ok(p) => proposal.set(Some(p)),
      Err(e) => error.set(Some(e)),
    }
    busy.set(false);
  };
  let replaces = proposal().map_or(0, |p| p.preview.replaces_matches + p.preview.replaces_sessions);

  rsx! {
    Card { title: "Generate schedule",
      p { class: "mb-3 text-sm text-muted",
        "Builds matches and judging sessions for every team on the event's tables and pods, using the robot game and judging settings and keeping clear of breaks on the timetable. Nothing changes until you save it."
      }
      div { class: "grid items-end gap-3 sm:grid-cols-4",
        TextField { label: "First match", r#type: "datetime-local", value: match_start(), oninput: move |v| match_start.set(v) }
        TextField { label: "First judging session", r#type: "datetime-local", value: judging_start(), oninput: move |v| judging_start.set(v) }
        TextField { label: "Match cycle (min)", r#type: "number", value: cycle(), hint: "Start to start", oninput: move |v| cycle.set(v) }
        div { class: "flex gap-2",
          Button { variant: ButtonVariant::Secondary, loading: busy() && proposal().is_none(), onclick: move |_| { spawn(send(false)); }, "Preview" }
          if proposal().is_some() {
            Button {
              variant: ButtonVariant::Ghost,
              onclick: move |_| {
                  seed += 1;
                  spawn(send(false));
              },
              "Try another"
            }
          }
        }
      }
      if let Some(e) = error() {
        div { class: "mt-3", ErrorBox { error: e } }
      }
      if let Some(message) = done() {
        div { class: "mt-3", SuccessBox { message } }
      }
      if let Some(p) = proposal() {
        div { class: "mt-3 flex flex-col gap-3", "data-testid": "proposal",
          PreviewSummary { preview: p.preview.clone() }
          div { class: "grid gap-3 lg:grid-cols-2",
            ProposalTable { title: "Matches", entries: p.matches.clone() }
            ProposalTable { title: "Judging", entries: p.sessions.clone() }
          }
          div {
            if replaces > 0 {
              ConfirmButton {
                label: "Save this schedule",
                variant: ButtonVariant::Warning,
                size: ButtonSize::Medium,
                title: "Replace the current schedule?",
                message: "The {replaces} matches and judging sessions in TMS now are replaced by this schedule.",
                confirm_label: "Replace schedule",
                onconfirm: move |()| { spawn(send(true)); },
              }
            } else {
              Button { loading: busy(), onclick: move |_| { spawn(send(true)); }, "Save this schedule" }
            }
          }
        }
      }
    }
  }
}

#[component]
fn ProposalTable(title: String, entries: Vec<ProposedEntry>) -> Element {
  let realtime = use_context::<Realtime>();
  let timezone = realtime
    .stores
    .event
    .read()
    .as_ref()
    .map_or_else(|| "UTC".to_owned(), |e| e.timezone.clone());
  rsx! {
    div { class: "rounded-control max-h-96 overflow-y-auto border border-line",
      DataTable {
        columns: vec![title, "Start".into(), "Teams".into()],
        empty: "None.",
        rows: entries
            .iter()
            .map(|e| {
                let what = match e.kind {
                    Some(kind) => format!("{} {}", kind.label(), e.number),
                    None => format!("Session {}", e.number),
                };
                let teams: Vec<String> = e.teams.iter().map(|(place, team)| format!("{place}: {team}")).collect();
                rsx! {
                  tr {
                    td { class: "whitespace-nowrap", "{what}" }
                    td { class: "whitespace-nowrap", {format_time(e.start, &timezone)} }
                    td { class: "font-mono text-xs", {teams.join(" · ")} }
                  }
                }
            })
            .collect(),
      }
    }
  }
}

/// A change waiting to be sent, kept so it can be sent again with `force` after a conflict.
#[derive(Clone, PartialEq)]
enum Change {
  Assign(Option<Uuid>),
  Swap(Uuid),
  Move(NaiveDateTime),
}

fn team_options(teams: &[Team]) -> Vec<(String, String)> {
  let mut sorted = teams.to_vec();
  sorted.sort_by(team_order);
  let mut options = vec![(String::new(), "Nobody".to_owned())];
  options.extend(
    sorted
      .iter()
      .map(|t| (t.id.to_string(), format!("{} {}", t.number, t.name))),
  );
  options
}

/// Who plays in one match slot, swapping it with another slot, or moving the whole match.
#[component]
pub fn SlotEditor(
  slot_id: Uuid,
  match_id: Uuid,
  title: String,
  team_id: Option<Uuid>,
  start: String,
  judging: bool,
  onclose: EventHandler<()>,
) -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let teams = realtime.stores.teams.read().clone();
  let mut chosen = use_signal(|| team_id.map(|t| t.to_string()).unwrap_or_default());
  let mut when = use_signal(|| start.clone());
  let mut error = use_signal(|| None::<ApiFailure>);
  let mut conflict = use_signal(|| None::<Change>);
  let swaps = use_resource(move || async move {
    if judging {
      return Vec::new();
    }
    api::get::<Vec<SwapOption>>(&format!("/match-slots/{slot_id}/swaps"), token(session).as_deref())
      .await
      .unwrap_or_default()
  });

  let run = move |change: Change, force: bool| async move {
    error.set(None);
    let t = token(session);
    let t = t.as_deref();
    let result = match (&change, judging) {
      (Change::Assign(team), false) => {
        let body = SlotAssignRequest { team_id: *team, force };
        api::post::<_, Vec<ScheduleIssue>>(&format!("/match-slots/{slot_id}/assign"), t, &body).await
      }
      (Change::Assign(team), true) => {
        let body = SlotAssignRequest { team_id: *team, force };
        api::post::<_, Vec<ScheduleIssue>>(&format!("/judging-slots/{slot_id}/assign"), t, &body).await
      }
      (Change::Swap(other), _) => {
        let body = SlotSwapRequest {
          a: slot_id,
          b: *other,
          force,
        };
        api::post::<_, Vec<ScheduleIssue>>("/match-slots/swap", t, &body).await
      }
      (Change::Move(at), false) => {
        let body = MoveRequest {
          start_local: *at,
          force,
        };
        api::post::<_, Vec<ScheduleIssue>>(&format!("/matches/{match_id}/move"), t, &body).await
      }
      (Change::Move(at), true) => {
        let body = MoveRequest {
          start_local: *at,
          force,
        };
        api::post::<_, Vec<ScheduleIssue>>(&format!("/judging-sessions/{match_id}/move"), t, &body).await
      }
    };
    match result {
      Ok(_) => onclose.call(()),
      Err(e) => {
        let is_conflict = matches!(&e, ApiFailure::Api { code, .. } if code == "schedule.conflict");
        conflict.set(is_conflict.then_some(change));
        error.set(Some(e));
      }
    }
  };
  let options: Vec<SwapOption> = swaps.read().clone().unwrap_or_default().into_iter().take(8).collect();
  let label = |id: Option<Uuid>| {
    id.and_then(|id| teams.iter().find(|t| t.id == id))
      .map_or_else(|| "nobody".to_owned(), |t| format!("{} {}", t.number, t.name))
  };
  let timezone = realtime
    .stores
    .event
    .read()
    .as_ref()
    .map_or_else(|| "UTC".to_owned(), |e| e.timezone.clone());
  let now = start.replace('T', " ");

  rsx! {
    Modal {
      title,
      onclose: move |()| onclose.call(()),
      footer: rsx! {
        if let Some(change) = conflict() {
          Button { variant: ButtonVariant::Danger, onclick: move |_| { spawn(run(change.clone(), true)); }, "Save anyway" }
        }
        Button { variant: ButtonVariant::Ghost, onclick: move |_| onclose.call(()), "Close" }
      },
      div { class: "flex flex-col gap-4",
        if let Some(e) = error() {
          ErrorBox { error: e }
        }
        div { class: "flex items-end gap-2",
          div { class: "flex-1",
            Select { label: "Team", value: chosen(), options: team_options(&teams), onchange: move |v| chosen.set(v) }
          }
          Button {
            onclick: move |_| { spawn(run(Change::Assign(chosen().parse().ok()), false)); },
            "Save"
          }
        }
        if !options.is_empty() {
          div {
            p { class: "mb-1 text-sm font-semibold", "Swap with" }
            ul { class: "flex max-h-56 flex-col gap-1 overflow-y-auto text-sm", "data-testid": "swap-options",
              for o in options {
                li { key: "{o.slot_id}", class: "flex items-center gap-2",
                  span { class: "w-28 whitespace-nowrap", "{o.label}" }
                  span { class: "w-14 text-muted", {format_time(o.start, &timezone)} }
                  span { class: "flex-1 truncate", {label(o.team_id)} }
                  if o.new_errors.is_empty() {
                    Badge { tone: Tone::Success, "No new errors" }
                  } else {
                    Badge { tone: Tone::Danger, "{o.new_errors.len()} error(s)" }
                  }
                  if o.warnings != 0 {
                    span { class: "text-xs text-muted", "{o.warnings:+} warning(s)" }
                  }
                  Button {
                    size: ButtonSize::Small,
                    variant: ButtonVariant::Secondary,
                    onclick: move |_| { spawn(run(Change::Swap(o.slot_id), false)); },
                    "Swap"
                  }
                }
              }
            }
          }
        }
        div { class: "flex items-end gap-2",
          div { class: "flex-1",
            TextField {
              label: if judging { "Move the session to" } else { "Move the match to" },
              r#type: "datetime-local",
              value: when(),
              oninput: move |v| when.set(v),
            }
          }
          Button {
            variant: ButtonVariant::Secondary,
            onclick: move |_| {
                match parse_local(&when()) {
                    Some(at) => {
                        spawn(run(Change::Move(at), false));
                    }
                    None => error.set(Some(input_error("Choose a date and time."))),
                }
            },
            "Move"
          }
        }
        p { class: "text-xs text-muted", "Now {now}" }
      }
    }
  }
}
