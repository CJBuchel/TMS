//! The rubric form: Innovation Project, Robot Design and the feedback page, from the season's rubric
//! definitions. Each row is one tap on a level; Exceeds asks for a comment.

use std::collections::BTreeMap;

use chrono::Utc;
use dioxus::prelude::*;
use tms_core::judging::{Feedback, Nomination, RubricDoc};
use tms_seasons::rubric::{self, LEVELS, Rubric, RubricRow};
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Card, Checkbox, Select, Tab, Tabs, TextField, Tone};
use uuid::{NoContext, Timestamp, Uuid};

use crate::net::realtime::Realtime;
use crate::pages::setup::team_order;
use crate::store::outbox::{Document, Outbox, OutboxState};
use crate::time::now_ms;

#[derive(Debug, Clone, PartialEq)]
pub struct RubricTarget {
  pub slot_id: Option<Uuid>,
  pub pod_id: Option<Uuid>,
  pub team_number: String,
  pub title: String,
}

fn new_id() -> Uuid {
  let ms = u64::try_from(now_ms()).unwrap_or(0);
  Uuid::new_v7(Timestamp::from_unix(
    NoContext,
    ms / 1000,
    u32::try_from(ms % 1000).unwrap_or(0) * 1_000_000,
  ))
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Page {
  Rubric(usize),
  Feedback,
}

#[component]
pub fn RubricForm(target: RubricTarget, judge_names: String, onclose: EventHandler<Option<OutboxState>>) -> Element {
  let realtime = use_context::<Realtime>();
  let mut outbox = use_context::<Outbox>();
  let Some(event) = realtime.stores.event.read().clone() else {
    return rsx! {};
  };
  let Some(season) = tms_seasons::by_id(&event.season_id) else {
    return rsx! { p { "This event's season can't be judged by this version of TMS." } };
  };
  let id = use_signal(new_id);
  let mut page = use_signal(|| Page::Rubric(0));
  let mut scores = use_signal(BTreeMap::<String, u8>::new);
  let mut comments = use_signal(BTreeMap::<String, String>::new);
  let mut feedback = use_signal(Feedback::default);
  let mut nominations = use_signal(Vec::<Nomination>::new);
  let mut team = use_signal(|| target.team_number.clone());
  let mut judges = use_signal(|| judge_names.clone());
  let mut sending = use_signal(|| false);
  let mut failure = use_signal(|| None::<String>);

  let doc = RubricDoc {
    id: id(),
    event_id: event.id,
    event_code: event.code.clone(),
    season_id: season.id.to_owned(),
    schema_version: season.schema_version,
    team_number: team(),
    slot_id: target.slot_id,
    pod_id: target.pod_id,
    judge_names: judges(),
    scores: scores(),
    exceeds_comments: comments(),
    feedback: feedback(),
    nominations: nominations(),
    created_at: Utc::now(),
  };
  let issues = doc.check(season);
  let totals = rubric::totals(season.rubrics, &scores());
  let mut teams = realtime.stores.teams.read().clone();
  teams.sort_by(team_order);

  let submit = {
    let doc = doc.clone();
    move |_| {
      let doc = doc.clone();
      async move {
        sending.set(true);
        failure.set(None);
        let rubric_id = doc.id;
        outbox.add(Document::Rubric(doc));
        let mut state = OutboxState::Pending;
        for _ in 0..30 {
          gloo_timers::future::TimeoutFuture::new(100).await;
          state = outbox.state_of(rubric_id).unwrap_or(OutboxState::Pending);
          if state != OutboxState::Pending {
            break;
          }
        }
        sending.set(false);
        match state {
          OutboxState::NeedsBinding { reason } => failure.set(Some(reason)),
          OutboxState::Rejected { message } => failure.set(Some(message)),
          state => onclose.call(Some(state)),
        }
      }
    }
  };

  let tabs: Vec<(Page, String)> = season
    .rubrics
    .iter()
    .enumerate()
    .map(|(i, r)| (Page::Rubric(i), r.name.to_owned()))
    .chain(std::iter::once((Page::Feedback, "Feedback".to_owned())))
    .collect();

  rsx! {
    div { class: "sticky top-12 z-20 -mx-3 mb-4 flex flex-wrap items-center gap-3 border-b border-line bg-surface/90 px-3 py-2.5 shadow-sm backdrop-blur md:-mx-5 md:px-5",
      div { class: "min-w-0 flex-1",
        p { class: "text-xl font-extrabold tracking-tight", if team().is_empty() { "Choose a team" } else { "Team {team()}" } }
        p { class: "text-sm text-muted", "{target.title}" }
      }
      span { class: "rounded-control bg-primary-soft px-3 py-1.5 text-sm font-semibold tabular-nums text-primary-strong", "data-testid": "rubric-totals",
        "IP {totals.innovation_project}/40 · RD {totals.robot_design}/40 · CV {totals.core_values_rows}/40"
      }
      if !issues.is_empty() {
        Badge { tone: Tone::Danger, "{issues.len()} to fix" }
      }
      Button { variant: ButtonVariant::Secondary, onclick: move |_| onclose.call(None), "Cancel" }
    }
    if target.slot_id.is_none() {
      div { class: "mb-4 max-w-sm",
        Select {
          label: "Team",
          value: team(),
          options: std::iter::once((String::new(), "Choose a team".to_owned()))
              .chain(teams.iter().map(|t| (t.number.clone(), format!("{} {}", t.number, t.name))))
              .collect(),
          onchange: move |v| team.set(v),
        }
      }
    }
    div { class: "mb-4",
      Tabs {
        for (tab , name) in tabs {
          Tab { active: page() == tab, onclick: move |_| page.set(tab), "{name}" }
        }
      }
    }
    match page() {
      Page::Rubric(i) => rsx! {
        RubricPage {
          rubric_index: i,
          season_id: season.id,
          scores: scores(),
          comments: comments(),
          onlevel: move |(row, level): (String, u8)| {
              scores.write().insert(row.clone(), level);
              if level < 4 {
                  comments.write().remove(&row);
              }
          },
          oncomment: move |(row, text): (String, String)| {
              comments.write().insert(row, text);
          },
        }
      },
      Page::Feedback => rsx! {
        Card { title: "Feedback for the team",
          div { class: "grid gap-3 md:grid-cols-2",
            TextField { label: "Core Values: great job", value: feedback().core_values_great, oninput: move |v| feedback.write().core_values_great = v }
            TextField { label: "Core Values: think about", value: feedback().core_values_think, oninput: move |v| feedback.write().core_values_think = v }
            TextField { label: "Innovation Project: great job", value: feedback().innovation_project_great, oninput: move |v| feedback.write().innovation_project_great = v }
            TextField { label: "Innovation Project: think about", value: feedback().innovation_project_think, oninput: move |v| feedback.write().innovation_project_think = v }
            TextField { label: "Robot Design: great job", value: feedback().robot_design_great, oninput: move |v| feedback.write().robot_design_great = v }
            TextField { label: "Robot Design: think about", value: feedback().robot_design_think, oninput: move |v| feedback.write().robot_design_think = v }
          }
          h3 { class: "mt-4 mb-1 text-sm font-semibold", "Candidate for" }
          div { class: "flex flex-wrap gap-4",
            for nomination in Nomination::ALL {
              Checkbox {
                label: "{nomination.label()}",
                checked: nominations().contains(&nomination),
                onchange: move |on: bool| {
                    let mut list = nominations.write();
                    list.retain(|n| *n != nomination);
                    if on {
                        list.push(nomination);
                    }
                },
              }
            }
          }
        }
      },
    }
    Card { class: "mt-3",
      div { class: "max-w-sm",
        TextField { label: "Judges", value: judges(), oninput: move |v| judges.set(v) }
      }
      if !issues.is_empty() {
        ul { class: "mt-3 list-disc pl-5 text-sm text-danger-strong",
          for issue in issues.iter().take(5) {
            li { "{issue.message}" }
          }
          if issues.len() > 5 {
            li { "and {issues.len() - 5} more" }
          }
        }
      }
      if let Some(message) = failure() {
        div { role: "alert", class: "rounded-control mt-3 border border-danger bg-danger-soft px-3 py-2 text-sm text-danger-strong", "{message}" }
      }
      div { class: "mt-4 flex justify-end gap-2",
        Button { variant: ButtonVariant::Secondary, onclick: move |_| onclose.call(None), "Cancel" }
        Button { size: ButtonSize::Large, disabled: !issues.is_empty(), loading: sending(), onclick: submit, "Submit rubrics" }
      }
    }
  }
}

fn rubric_by_index(season_id: &str, i: usize) -> Option<&'static Rubric> {
  tms_seasons::by_id(season_id).and_then(|s| s.rubrics.get(i))
}

#[component]
fn RubricPage(
  rubric_index: usize,
  season_id: &'static str,
  scores: BTreeMap<String, u8>,
  comments: BTreeMap<String, String>,
  onlevel: EventHandler<(String, u8)>,
  oncomment: EventHandler<(String, String)>,
) -> Element {
  let Some(rubric) = rubric_by_index(season_id, rubric_index) else {
    return rsx! {};
  };
  rsx! {
    div { class: "flex flex-col gap-3",
      for section in rubric.sections {
        Card { key: "{section.name}",
          h3 { class: "text-lg font-semibold tracking-tight", "{section.name}" }
          p { class: "mb-2 text-sm text-muted", "{section.description}" }
          for row in section.rows {
            RowInput {
              key: "{row.id}",
              row_id: row.id,
              season_id,
              level: scores.get(row.id).copied(),
              comment: comments.get(row.id).cloned().unwrap_or_default(),
              onlevel,
              oncomment,
            }
          }
        }
      }
      p { class: "text-xs text-muted", "Rows marked CV also count toward Core Values." }
    }
  }
}

fn find_row(season_id: &str, id: &str) -> Option<&'static RubricRow> {
  tms_seasons::by_id(season_id)?
    .rubrics
    .iter()
    .flat_map(Rubric::rows)
    .find(|r| r.id == id)
}

#[component]
fn RowInput(
  row_id: &'static str,
  season_id: &'static str,
  level: Option<u8>,
  comment: String,
  onlevel: EventHandler<(String, u8)>,
  oncomment: EventHandler<(String, String)>,
) -> Element {
  let Some(row) = find_row(season_id, row_id) else {
    return rsx! {};
  };
  rsx! {
    div { class: "border-t border-line py-3", "data-row": "{row_id}",
      p { class: "mb-1 flex items-center gap-2 text-sm font-semibold",
        "{row.label}"
        if row.core_values {
          Badge { tone: Tone::Primary, "CV" }
        }
      }
      div { class: "grid gap-1.5 sm:grid-cols-4",
        for (i , name) in LEVELS.iter().enumerate() {
          button {
            r#type: "button",
            "aria-pressed": "{level == Some(u8::try_from(i + 1).unwrap_or(0))}",
            class: if level == Some(u8::try_from(i + 1).unwrap_or(0)) { "min-h-14 rounded-control border border-primary bg-primary px-2.5 py-1.5 text-left text-xs text-on-primary shadow-sm transition" } else { "min-h-14 rounded-control border border-line bg-surface px-2.5 py-1.5 text-left text-xs transition hover:border-line-strong hover:bg-surface-2" },
            onclick: move |_| onlevel.call((row_id.to_owned(), u8::try_from(i + 1).unwrap_or(1))),
            span { class: "block font-semibold", "{i + 1} {name}" }
            span { class: "block", {row.levels.get(i).copied().unwrap_or("How has the team exceeded?")} }
          }
        }
      }
      if level == Some(4) {
        div { class: "mt-2",
          TextField {
            label: "How did the team exceed?",
            value: comment,
            oninput: move |v: String| oncomment.call((row_id.to_owned(), v)),
          }
        }
      }
    }
  }
}
