//! The judge advisor's screens: a dashboard of every pod, rubric review, and the scores and ranks behind
//! deliberation.

use dioxus::prelude::*;
use tms_core::Topic;
use tms_core::deliberation::TeamScores;
use tms_core::game::ReviewRequest;
use tms_core::judging::{Nomination, Rubric, RubricStatus};
use tms_core::model::QueueState;
use tms_seasons::rubric::LEVELS;
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Card, DataTable, Modal, Tab, Tabs, TextField, Tone};
use uuid::Uuid;

use super::shared::{JudgingBadge, PodClock, pod_slot, rubric_tone, sorted_sessions};
use crate::components::{ErrorBox, NeedsActiveEvent, PageHeader, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::{Realtime, use_subscription};
use crate::pages::game::queue_ui::relative;
use crate::pages::game::shared::{team_label, use_server_now};
use crate::routes::Route;
use crate::store::session::Session;
use crate::time::format_time;

#[component]
pub fn JudgingDashboard() -> Element {
  use_subscription(Topic::JudgingSessions);
  use_subscription(Topic::Teams);
  use_subscription(Topic::Pods);
  use_subscription(Topic::PodTimers);
  use_subscription(Topic::Rubrics);
  use_subscription(Topic::Presence);
  use_subscription(Topic::Rankings);
  let realtime = use_context::<Realtime>();
  let now = use_server_now();
  let Some(event) = realtime.stores.event.read().clone() else {
    return rsx! { PageHeader { title: "Judging" } NeedsActiveEvent {} };
  };
  let teams = realtime.stores.teams.read().clone();
  let mut pods = realtime.stores.pods.read().clone();
  pods.sort_by_key(|p| p.sort_order);
  let sessions = sorted_sessions(&realtime.stores.sessions.read());
  let timers = realtime.stores.pod_timers.read().clone();
  let presence = realtime.stores.presence.read().clone();
  let slots_total = sessions
    .iter()
    .flat_map(|s| s.slots.iter())
    .filter(|s| s.team_id.is_some())
    .count();
  let slots_done = sessions
    .iter()
    .flat_map(|s| s.slots.iter())
    .filter(|s| s.team_id.is_some() && matches!(s.queue, QueueState::Done | QueueState::NoShow))
    .count();
  let waiting = realtime
    .stores
    .rubrics
    .read()
    .iter()
    .filter(|r| r.status == RubricStatus::Submitted)
    .count();
  let top: Vec<_> = realtime.stores.rankings.read().iter().take(8).cloned().collect();

  let in_session = timers.iter().filter(|t| t.phase.is_some()).count();
  let no_device = pods
    .iter()
    .filter(|p| !presence.iter().any(|d| d.pod_id == Some(p.id)))
    .count();
  let next_wave = sessions
    .iter()
    .find(|s| {
      s.slots
        .iter()
        .any(|slot| slot.team_id.is_some() && slot.queue.is_before_match())
    })
    .cloned();
  let stat = |label: &str, value: String, tone: Tone| {
    let colour = match tone {
      Tone::Danger => "text-danger",
      Tone::Warning => "text-warning-strong",
      Tone::Success => "text-success-strong",
      _ => "text-fg",
    };
    rsx! {
      div { class: "rounded-control border border-line bg-surface px-4 py-2.5 shadow-panel",
        p { class: "text-2xl font-extrabold tabular-nums {colour}", "{value}" }
        p { class: "text-xs font-medium text-muted", "{label}" }
      }
    }
  };

  rsx! {
    PageHeader {
      title: "Judging",
      subtitle: "{slots_done} of {slots_total} sessions done.",
      actions: rsx! {
        Link { to: Route::RubricReview {}, class: "inline-flex h-10 items-center rounded-control font-semibold shadow-sm gap-2 border border-line-strong bg-surface px-3 text-sm hover:bg-surface-2",
          "Rubrics"
          if waiting > 0 {
            Badge { tone: Tone::Warning, "{waiting} to review" }
          }
        }
        Link { to: Route::JudgingScores {}, class: "inline-flex h-10 items-center rounded-control font-semibold shadow-sm border border-line-strong bg-surface px-3 text-sm hover:bg-surface-2", "Scores" }
        Link { to: Route::JudgingDeliberation {}, class: "inline-flex h-10 items-center rounded-control font-semibold shadow-sm border border-line-strong bg-surface px-3 text-sm hover:bg-surface-2", "Deliberation" }
      },
    }
    div { class: "mb-4 grid grid-cols-2 gap-2 md:grid-cols-4",
      {stat("sessions done", format!("{slots_done} / {slots_total}"), Tone::Neutral)}
      {stat("pods in a session now", format!("{in_session} / {}", pods.len()), Tone::Success)}
      {stat("rubric sets to review", waiting.to_string(), if waiting > 0 { Tone::Warning } else { Tone::Neutral })}
      {stat("pods without a device", no_device.to_string(), if no_device > 0 { Tone::Danger } else { Tone::Success })}
    }
    if let Some(s) = next_wave {
      p { class: "mb-4 text-sm text-muted",
        "Next to start: "
        span { class: "font-semibold text-fg", "Session {s.number} at {format_time(s.scheduled_start, &event.timezone)}" }
        " · {relative(s.scheduled_start, now())}"
      }
    }
    div { class: "grid gap-3 md:grid-cols-2 xl:grid-cols-3", "data-testid": "pod-tiles",
      for pod in pods {
        {
            let timer = timers.iter().find(|t| t.pod_id == pod.id).cloned();
            let running = timer.as_ref().is_some_and(|t| t.phase.is_some());
            let mine: Vec<_> = sessions.iter().filter_map(|s| pod_slot(s, pod.id).map(|slot| (s.clone(), slot))).collect();
            let current = timer
                .as_ref()
                .and_then(|t| t.session_id)
                .and_then(|id| mine.iter().find(|(s, _)| s.id == id).cloned())
                .or_else(|| mine.iter().find(|(_, slot)| slot.team_id.is_some() && slot.queue.is_before_match()).cloned());
            let late = !running && current.as_ref().is_some_and(|(s, _)| s.scheduled_start < now());
            let last_done = mine.iter().rev().find(|(_, slot)| slot.queue == QueueState::Done).cloned();
            let device = presence.iter().find(|p| p.pod_id == Some(pod.id)).cloned();
            let edge = if running { "border-l-success" } else if late { "border-l-warning" } else { "border-l-line" };
            let current_id = current.as_ref().map(|(s, _)| s.id);
            rsx! {
              div { key: "{pod.id}", class: "flex flex-col gap-3 rounded-panel border border-l-4 border-line bg-surface p-4 shadow-panel {edge}",
                div { class: "flex items-start justify-between gap-2",
                  div {
                    p { class: "font-semibold", "{pod.name}" }
                    if let Some(room) = pod.room.clone() {
                      p { class: "text-xs text-muted", "{room}" }
                    }
                  }
                  match device {
                      Some(d) => rsx! {
                        div { class: "flex flex-wrap justify-end gap-1.5",
                          if d.waiting > 0 {
                            Badge { tone: Tone::Warning, "{d.waiting} waiting to send" }
                          }
                          span { title: "{d.label}", Badge { tone: Tone::Success, "Device online" } }
                        }
                      },
                      None => rsx! { Badge { tone: Tone::Danger, "No device" } },
                  }
                }
                if running {
                  PodClock { timer: timer.clone(), size_class: "text-4xl" }
                }
                match current {
                    Some((s, slot)) => rsx! {
                      div {
                        p { class: "text-base font-semibold", "{team_label(&teams, slot.team_id)}" }
                        p { class: "text-sm text-muted",
                          if running { "Session {s.number}, {format_time(s.scheduled_start, &event.timezone)}" } else { "Session {s.number}, {format_time(s.scheduled_start, &event.timezone)} · {relative(s.scheduled_start, now())}" }
                        }
                      }
                      div { class: "flex flex-wrap gap-1.5",
                        JudgingBadge { state: slot.queue }
                        if late {
                          Badge { tone: Tone::Warning, "Not started" }
                        }
                      }
                    },
                    None => rsx! { p { class: "text-sm text-muted", "No more sessions." } },
                }
                div { class: "mt-auto flex items-center gap-1.5 border-t border-line pt-3",
                  for (s , slot) in mine.iter().filter(|(_, slot)| slot.team_id.is_some()) {
                    span {
                      key: "{slot.id}",
                      title: "Session {s.number}: {team_label(&teams, slot.team_id)}",
                      class: match slot.queue {
                          QueueState::Done => "h-2.5 w-2.5 rounded-full bg-success",
                          QueueState::NoShow => "h-2.5 w-2.5 rounded-full bg-danger",
                          _ if Some(s.id) == current_id => "h-2.5 w-2.5 rounded-full bg-primary ring-2 ring-primary/30",
                          _ => "h-2.5 w-2.5 rounded-full bg-surface-2 ring-1 ring-line-strong ring-inset",
                      },
                    }
                  }
                  span { class: "ml-auto text-xs text-muted",
                    if let Some((_, slot)) = last_done.clone() {
                      match slot.rubric {
                          Some(status) => rsx! { Badge { tone: rubric_tone(status), "Last rubrics: {status.label()}" } },
                          None => rsx! { Badge { tone: Tone::Warning, "Last rubrics: not in yet" } },
                      }
                    }
                  }
                }
              }
            }
        }
      }
    }
    Card { title: "Robot game (do not share with teams)", class: "mt-4",
      if top.iter().all(|r| r.best.is_none()) {
        p { class: "text-sm text-muted", "No scores yet." }
      }
      ol { class: "text-sm",
        for row in top.into_iter().filter(|r| r.best.is_some()) {
          li { class: "flex justify-between border-b border-line py-1.5 last:border-b-0",
            span { "{row.rank}. {team_label(&teams, Some(row.team_id))}" }
            span { class: "font-semibold tabular-nums", {row.best.map_or_else(|| "–".to_owned(), |b| b.to_string())} }
          }
        }
      }
    }
  }
}

#[component]
pub fn RubricReview() -> Element {
  use_subscription(Topic::Rubrics);
  use_subscription(Topic::Pods);
  let realtime = use_context::<Realtime>();
  let mut filter = use_signal(|| "waiting".to_owned());
  let mut open = use_signal(|| None::<Uuid>);
  let error = use_signal(|| None::<ApiFailure>);
  let Some(event) = realtime.stores.event.read().clone() else {
    return rsx! { PageHeader { title: "Rubrics" } NeedsActiveEvent {} };
  };
  let mut rubrics = realtime.stores.rubrics.read().clone();
  rubrics.sort_by_key(|r| std::cmp::Reverse(r.received_at));
  let waiting = rubrics.iter().filter(|r| r.status == RubricStatus::Submitted).count();
  let shown: Vec<Rubric> = rubrics
    .into_iter()
    .filter(|r| match filter().as_str() {
      "waiting" => r.status == RubricStatus::Submitted,
      "accepted" => r.status == RubricStatus::Accepted,
      _ => true,
    })
    .collect();
  let pods = realtime.stores.pods.read().clone();

  rsx! {
    PageHeader {
      title: "Rubrics",
      subtitle: "{waiting} waiting for review. Accepting rubrics replaces any accepted earlier for that team.",
      back: (Route::JudgingDashboard {}, "Judging".to_owned()),
    }
    div { class: "mb-4",
      Tabs {
        for (key , label) in [("waiting", format!("Waiting ({waiting})")), ("accepted", "Accepted".to_owned()), ("all", "All".to_owned())] {
          Tab { active: filter() == key, onclick: move |_| filter.set(key.to_owned()), "{label}" }
        }
      }
    }
    if let Some(e) = error() {
      div { class: "mb-3", ErrorBox { error: e } }
    }
    if shown.is_empty() {
      p { class: "text-sm text-muted", "No rubrics here." }
    }
    div { class: "flex flex-col gap-2",
      for r in shown {
        {
            let pod = r.pod_id.and_then(|id| pods.iter().find(|p| p.id == id)).map(|p| p.name.clone()).unwrap_or_default();
            rsx! {
              RubricCard {
                key: "{r.id}",
                expanded: open() == Some(r.id),
                ontoggle: move |id| open.set(if open() == Some(id) { None } else { Some(id) }),
                rubric: r,
                pod,
                season_id: event.season_id.clone(),
                timezone: event.timezone.clone(),
                error,
              }
            }
        }
      }
    }
  }
}

#[component]
fn RubricCard(
  rubric: Rubric,
  expanded: bool,
  ontoggle: EventHandler<Uuid>,
  pod: String,
  season_id: String,
  timezone: String,
  error: Signal<Option<ApiFailure>>,
) -> Element {
  let session = use_context::<Session>();
  let mut rejecting = use_signal(|| false);
  let mut note = use_signal(String::new);
  let id = rubric.id;
  let accept = move |_| async move {
    error.set(None);
    if let Err(e) = api::post::<_, Rubric>(&format!("/rubrics/{id}/accept"), token(session).as_deref(), &()).await {
      error.set(Some(e));
    }
  };
  let season = tms_seasons::by_id(&season_id);
  rsx! {
    Card {
      div { class: "flex flex-wrap items-center gap-3", "data-testid": "rubric-row",
        button { class: "flex min-w-0 flex-1 flex-wrap items-center gap-3 text-left", onclick: move |_| ontoggle.call(id),
          span { class: "font-mono text-lg font-bold", "{rubric.team_number}" }
          span { class: "text-sm text-muted", "{pod}" }
          span { class: "font-mono text-sm", "IP {rubric.innovation_project} · RD {rubric.robot_design} · CV {rubric.core_values_rows}" }
          Badge { tone: rubric_tone(rubric.status), "{rubric.status.label()}" }
          if rubric.duplicate {
            Badge { tone: Tone::Warning, "Team already had accepted rubrics" }
          }
          span { class: "text-xs text-muted", "{format_time(rubric.received_at, &timezone)} by {rubric.judge_names}" }
        }
        if rubric.status == RubricStatus::Submitted {
          Button { size: ButtonSize::Small, variant: ButtonVariant::Success, onclick: accept, "Accept" }
        }
        if matches!(rubric.status, RubricStatus::Submitted | RubricStatus::Accepted) {
          Button { size: ButtonSize::Small, variant: ButtonVariant::Danger, onclick: move |_| rejecting.set(true), "Reject" }
        }
      }
      if expanded && let Some(season) = season {
        div { class: "mt-3 grid gap-4 border-t border-line pt-3 text-sm md:grid-cols-2",
          for r in season.rubrics {
            div {
              p { class: "mb-1 font-semibold", "{r.name}" }
              for row in r.rows() {
                {
                    let level = rubric.scores.get(row.id).copied().unwrap_or(0);
                    let name = LEVELS.get(usize::from(level).saturating_sub(1)).copied().unwrap_or("–");
                    rsx! {
                      p { class: "flex justify-between gap-3",
                        span { class: "text-muted", "{row.label}" if row.core_values { " (CV)" } }
                        span { "{level} {name}" }
                      }
                      if let Some(comment) = rubric.exceeds_comments.get(row.id) {
                        p { class: "pl-3 text-xs italic", "{comment}" }
                      }
                    }
                }
              }
            }
          }
        }
        div { class: "mt-3 border-t border-line pt-3 text-sm",
          p { "Great job (Core Values): {rubric.feedback.core_values_great}" }
          p { "Think about (Core Values): {rubric.feedback.core_values_think}" }
          if !rubric.nominations.is_empty() {
            p { "Candidate for: " {nomination_list(&rubric.nominations)} }
          }
          if !rubric.review_note.is_empty() {
            p { class: "text-danger-strong", "Rejected because: {rubric.review_note}" }
          }
        }
      }
    }
    if rejecting() {
      Modal {
        title: "Reject team {rubric.team_number}'s rubrics?",
        onclose: move |()| rejecting.set(false),
        footer: rsx! {
          Button { variant: ButtonVariant::Secondary, onclick: move |_| rejecting.set(false), "Cancel" }
          Button {
            variant: ButtonVariant::Danger,
            disabled: note().trim().is_empty(),
            onclick: move |_| async move {
                let body = ReviewRequest { note: note() };
                if let Err(e) = api::post::<_, Rubric>(&format!("/rubrics/{id}/reject"), token(session).as_deref(), &body).await {
                    error.set(Some(e));
                }
                rejecting.set(false);
            },
            "Reject"
          }
        },
        p { class: "mb-3 text-sm", "The judges see this note at their station." }
        TextField { label: "Reason", value: note(), oninput: move |v| note.set(v), autofocus: true }
      }
    }
  }
}

fn nomination_list(nominations: &[Nomination]) -> String {
  nominations.iter().map(|n| n.label()).collect::<Vec<_>>().join(", ")
}

fn cell<T: std::fmt::Display>(score: Option<T>, rank: u32) -> String {
  match score {
    Some(s) => format!("{s} ({rank})"),
    None => "–".to_owned(),
  }
}

#[component]
pub fn JudgingScores() -> Element {
  use_subscription(Topic::Teams);
  use_subscription(Topic::Deliberation);
  let realtime = use_context::<Realtime>();
  if realtime.stores.event.read().is_none() {
    return rsx! { PageHeader { title: "Scores" } NeedsActiveEvent {} };
  }
  let teams = realtime.stores.teams.read().clone();
  let mut rows: Vec<TeamScores> = realtime
    .stores
    .deliberation
    .read()
    .as_ref()
    .map(|d| d.teams.clone())
    .unwrap_or_default();
  rows.sort_by_key(|r| r.champions_rank);

  rsx! {
    PageHeader {
      title: "Scores",
      back: (Route::JudgingDashboard {}, "Judging".to_owned()),
      subtitle: "Area scores with ranks in brackets, as the Official Judging Spreadsheet computes them. Champion's score is the sum of the four ranks; lowest is best. Core Values is the CV rubric rows plus Gracious Professionalism (one to three matches add up; four count 0.75 each, five 0.6). Robot game ties break on the second, then third best score.",
      actions: rsx! {
        Link { to: Route::JudgingDeliberation {}, class: "inline-flex h-10 items-center rounded-control font-semibold shadow-sm border border-line-strong bg-surface px-3 text-sm hover:bg-surface-2", "Deliberation" }
      },
    }
    DataTable {
      columns: vec!["Champion's".into(), "Team".into(), "Innovation Project".into(), "Robot Design".into(), "Core Values".into(), "GP".into(), "Robot game".into(), "Sum of ranks".into()],
      empty: "No teams yet.",
      rows: rows
          .iter()
          .map(|r| rsx! {
            tr {
              td { class: "font-mono font-bold", "{r.champions_rank}" }
              td { "{team_label(&teams, Some(r.team_id))}" }
              td { class: "font-mono", "{cell(r.innovation_project, r.innovation_project_rank)}" }
              td { class: "font-mono", "{cell(r.robot_design, r.robot_design_rank)}" }
              td { class: "font-mono", "{cell(r.core_values, r.core_values_rank)}" }
              td { class: "font-mono", {r.gracious_professionalism.map_or_else(|| "–".to_owned(), |g| g.to_string())} }
              td { class: "font-mono", "{cell(r.robot_game, r.robot_game_rank)}" }
              td { class: "font-mono", "{r.champions_score}" }
            }
          })
          .collect(),
    }
  }
}
