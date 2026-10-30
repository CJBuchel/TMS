//! The scoresheet form. Everything on it comes from the season's field definitions, and the total and problems
//! are computed by the same code the server runs, so what the referee sees is what the server accepts.

use chrono::Utc;
use dioxus::prelude::*;
use tms_core::game::ScoresheetDoc;
use tms_core::model::MatchKind;
use tms_seasons::{Answer, FieldKind, Severity};
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Card, Checkbox, Select, TextField, Tone};
use uuid::{NoContext, Timestamp, Uuid};

use crate::net::realtime::Realtime;
use crate::pages::setup::team_order;
use crate::store::outbox::{Document, Outbox, OutboxState};
use crate::time::now_ms;

/// What the sheet is for: a scheduled slot, or an unscheduled sheet where the referee picks the team and round.
#[derive(Debug, Clone, PartialEq)]
pub struct FormTarget {
  pub slot_id: Option<Uuid>,
  pub team_number: String,
  pub kind: MatchKind,
  pub round: Option<i32>,
  pub title: String,
}

/// A time-ordered id made on the device, so a sheet sent twice is stored once.
fn new_id() -> Uuid {
  let ms = u64::try_from(now_ms()).unwrap_or(0);
  Uuid::new_v7(Timestamp::from_unix(
    NoContext,
    ms / 1000,
    u32::try_from(ms % 1000).unwrap_or(0) * 1_000_000,
  ))
}

#[component]
pub fn ScoresheetForm(
  target: FormTarget,
  table_id: Option<Uuid>,
  referee_name: String,
  /// Shown over another page rather than as the page, so its header sticks to the top of the overlay.
  #[props(default)]
  overlay: bool,
  onclose: EventHandler<Option<OutboxState>>,
) -> Element {
  let realtime = use_context::<Realtime>();
  let mut outbox = use_context::<Outbox>();
  let Some(event) = realtime.stores.event.read().clone() else {
    return rsx! {};
  };
  let Some(season) = tms_seasons::by_id(&event.season_id) else {
    return rsx! { p { "This event's season can't be scored by this version of TMS." } };
  };

  let id = use_signal(new_id);
  let mut answers = use_signal(|| season.defaults());
  let mut no_show = use_signal(|| false);
  let mut gp = use_signal(|| None::<u8>);
  let mut gp_comment = use_signal(String::new);
  let mut team_agreed = use_signal(|| false);
  let mut initials = use_signal(String::new);
  let mut note = use_signal(String::new);
  let mut team = use_signal(|| target.team_number.clone());
  let mut kind = use_signal(|| target.kind);
  let mut round = use_signal(|| target.round);
  let mut sending = use_signal(|| false);
  let mut failure = use_signal(|| None::<String>);

  let doc = ScoresheetDoc {
    id: id(),
    event_id: event.id,
    event_code: event.code.clone(),
    season_id: season.id.to_owned(),
    schema_version: season.schema_version,
    team_number: team(),
    slot_id: target.slot_id,
    kind: kind(),
    round: round(),
    table_id,
    referee_name: referee_name.clone(),
    no_show: no_show(),
    answers: answers(),
    score: 0,
    gp: gp(),
    gp_comment: gp_comment(),
    team_agreed: team_agreed(),
    team_initials: initials(),
    private_comment: note(),
    created_at: Utc::now(),
  };
  let result = doc.check(season, &event.settings);
  let errors = result.issues.iter().filter(|i| i.severity == Severity::Error).count();
  let field_issues = |field: &str| -> Vec<(Severity, String)> {
    result
      .issues_for(field)
      .map(|i| (i.severity, i.message.clone()))
      .collect()
  };
  let unscheduled = target.slot_id.is_none();
  let mut teams = realtime.stores.teams.read().clone();
  teams.sort_by(team_order);
  let rounds = match kind() {
    MatchKind::Ranking => event.settings.ranking_rounds,
    MatchKind::Practice => event.settings.practice_rounds.max(1),
  };

  // The sheet goes to the device's outbox first, so it is never lost. Wait briefly for the server's answer:
  // a sheet it can't place stays open here to fix; one that is sent, or still waiting for a connection, closes.
  let submit = {
    let doc = ScoresheetDoc {
      score: result.total,
      ..doc.clone()
    };
    move |_| {
      let doc = doc.clone();
      async move {
        sending.set(true);
        failure.set(None);
        let sheet = doc.id;
        outbox.add(Document::Scoresheet(doc));
        let mut state = OutboxState::Pending;
        for _ in 0..30 {
          gloo_timers::future::TimeoutFuture::new(100).await;
          state = outbox.state_of(sheet).unwrap_or(OutboxState::Pending);
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

  rsx! {
    div { class: if overlay { "sticky top-0 z-20 -mx-3 mb-4 flex flex-wrap items-center gap-3 border-b border-line bg-surface/90 px-3 py-2.5 shadow-sm backdrop-blur md:-mx-6 md:px-6" } else { "sticky top-12 z-20 -mx-3 mb-4 flex flex-wrap items-center gap-3 border-b border-line bg-surface/90 px-3 py-2.5 shadow-sm backdrop-blur md:-mx-5 md:px-5" },
      div { class: "min-w-0 flex-1",
        p { class: "text-xl font-extrabold tracking-tight", if team().is_empty() { "Choose a team" } else { "Team {team()}" } }
        p { class: "text-sm text-muted", "{target.title}, {kind().label()} round {round().map(|r| r.to_string()).unwrap_or_else(|| \"?\".into())}" }
      }
      span { class: "flex items-baseline gap-1 rounded-control bg-primary-soft px-3 py-1 text-primary-strong",
        span { class: "text-3xl font-extrabold tabular-nums", "data-testid": "sheet-total", "{result.total}" }
        span { class: "text-sm font-semibold", "pts" }
      }
      if errors > 0 {
        Badge { tone: Tone::Danger, "{errors} to fix" }
      }
      Checkbox { label: "No show", checked: no_show(), onchange: move |v| no_show.set(v) }
      Button { variant: ButtonVariant::Secondary, onclick: move |_| onclose.call(None), "Cancel" }
    }

    if unscheduled {
      Card { title: "Team and round", class: "mb-4",
        div { class: "grid gap-3 sm:grid-cols-3",
          Select {
            label: "Team",
            value: team(),
            options: std::iter::once((String::new(), "Choose a team".to_owned()))
                .chain(teams.iter().map(|t| (t.number.clone(), format!("{} {}", t.number, t.name))))
                .collect(),
            onchange: move |v| team.set(v),
          }
          Select {
            label: "Kind",
            value: if kind() == MatchKind::Ranking { "ranking" } else { "practice" },
            options: vec![("ranking".into(), "Ranking".into()), ("practice".into(), "Practice".into())],
            onchange: move |v: String| kind.set(if v == "practice" { MatchKind::Practice } else { MatchKind::Ranking }),
          }
          Select {
            label: "Round",
            value: round().map(|r| r.to_string()).unwrap_or_default(),
            options: std::iter::once((String::new(), "Choose".to_owned()))
                .chain((1..=rounds).map(|r| (r.to_string(), r.to_string())))
                .collect(),
            onchange: move |v: String| round.set(v.parse().ok()),
          }
        }
        for (_ , message) in field_issues("team") {
          p { class: "mt-1 text-sm text-danger-strong", "{message}" }
        }
      }
    }

    if no_show() {
      Card { class: "mb-4",
        p { "The team did not come to the table. The sheet records a no-show and no score." }
      }
    } else {
      div { class: "flex flex-col gap-3",
        for mission in season.missions {
          Card { key: "{mission.id}",
            div { class: "flex gap-4",
              if let Some(image) = mission.image {
                img { class: "rounded-control hidden h-24 w-24 shrink-0 border border-line object-cover sm:block", src: "/{image}", alt: "" }
              }
              div { class: "min-w-0 flex-1",
                div { class: "mb-2 flex items-baseline justify-between gap-3",
                  h3 { class: "font-semibold", "{mission.name}" }
                  {
                      let points = result.missions.iter().find(|m| m.mission == mission.id).map_or(0, |m| m.points);
                      rsx! {
                        span { class: if points > 0 { "rounded-full bg-primary-soft px-2.5 py-0.5 text-sm font-semibold tabular-nums text-primary-strong" } else { "rounded-full bg-surface-2 px-2.5 py-0.5 text-sm tabular-nums text-muted" },
                          "{points} pts"
                        }
                      }
                  }
                }
                for field in mission.fields {
                  FieldInput {
                    key: "{field.id}",
                    season_id: season.id,
                    field_id: field.id,
                    enabled: season.is_enabled(field, &answers()),
                    value: answers().get(field.id).cloned(),
                    issues: field_issues(field.id),
                    onchange: move |answer: Answer| {
                        let mut next = answers();
                        season.set(&mut next, field.id, answer);
                        answers.set(next);
                    },
                  }
                }
              }
            }
          }
        }
        Card { title: "Gracious Professionalism",
          div { class: "flex flex-wrap gap-2",
            for (value , label) in [(2u8, "2 Developing"), (3, "3 Accomplished"), (4, "4 Exceeds")] {
              Button {
                size: ButtonSize::Large,
                variant: if gp() == Some(value) { ButtonVariant::Primary } else { ButtonVariant::Secondary },
                onclick: move |_| gp.set(Some(value)),
                "{label}"
              }
            }
          }
          if matches!(gp(), Some(2 | 4)) {
            div { class: "mt-3",
              TextField { label: "Comment", value: gp_comment(), oninput: move |v| gp_comment.set(v), hint: "What did the team do?" }
            }
          }
          for (_ , message) in field_issues("gp") {
            p { class: "mt-1 text-sm text-danger-strong", "{message}" }
          }
        }
      }
    }

    Card { class: "mt-3",
      div { class: "grid gap-3 sm:grid-cols-2",
        div {
          Checkbox { label: "The team agrees with this scoresheet", checked: team_agreed(), onchange: move |v| team_agreed.set(v) }
          for (_ , message) in field_issues("team_agreed") {
            p { class: "mt-1 text-sm text-danger-strong", "{message}" }
          }
        }
        TextField { label: "Team initials", value: initials(), oninput: move |v| initials.set(v) }
        div { class: "sm:col-span-2",
          TextField { label: "Note for the head referee", value: note(), oninput: move |v| note.set(v), hint: "Not shown to the team." }
        }
      }
      if let Some(message) = failure() {
        div { role: "alert", class: "rounded-control mt-3 border border-danger bg-danger-soft px-3 py-2 text-sm text-danger-strong", "{message}" }
      }
      div { class: "mt-4 flex justify-end gap-2",
        Button { variant: ButtonVariant::Secondary, onclick: move |_| onclose.call(None), "Cancel" }
        Button { size: ButtonSize::Large, disabled: errors > 0, loading: sending(), onclick: submit, "Submit {result.total} points" }
      }
    }
  }
}

/// One question: yes/no, a count, or a choice, as a row of large buttons. The field is looked up by id, so the
/// props stay comparable.
#[component]
fn FieldInput(
  season_id: &'static str,
  field_id: &'static str,
  enabled: bool,
  value: Option<Answer>,
  issues: Vec<(Severity, String)>,
  onchange: EventHandler<Answer>,
) -> Element {
  let Some(field) = tms_seasons::by_id(season_id).and_then(|s| s.field(field_id)) else {
    return rsx! {};
  };
  let options: Vec<(String, Answer)> = match field.kind {
    FieldKind::Bool => vec![("No".into(), Answer::Bool(false)), ("Yes".into(), Answer::Bool(true))],
    FieldKind::Count { max } => (0..=max).map(|n| (n.to_string(), Answer::Count(n))).collect(),
    FieldKind::Choice { options } => options
      .iter()
      .map(|o| (o.label.to_owned(), Answer::Choice(o.key.to_owned())))
      .collect(),
  };
  rsx! {
    div { class: if enabled { "py-2" } else { "py-2 opacity-50" }, "data-field": "{field_id}",
      p { class: "mb-1.5 text-sm", "{field.label}" }
      div { class: "inline-flex flex-wrap gap-1 rounded-control bg-surface-2 p-1",
        for (label , answer) in options {
          button {
            r#type: "button",
            disabled: !enabled,
            "aria-pressed": "{value.as_ref() == Some(&answer)}",
            class: if value.as_ref() == Some(&answer) { "h-11 min-w-14 rounded-md bg-primary px-4 text-sm font-semibold text-on-primary shadow-sm transition" } else { "h-11 min-w-14 rounded-md px-4 text-sm font-medium text-fg transition hover:bg-surface disabled:cursor-not-allowed" },
            onclick: move |_| onchange.call(answer.clone()),
            "{label}"
          }
        }
      }
      for (severity , message) in issues {
        p { class: if severity == Severity::Error { "mt-1 text-sm text-danger-strong" } else { "mt-1 text-sm text-warning-strong" }, "{message}" }
      }
    }
  }
}
