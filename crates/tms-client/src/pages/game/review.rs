//! Scoresheet review for the head referee: sheets waiting for review first, each with its answers.

use dioxus::prelude::*;
use tms_core::Topic;
use tms_core::game::{ReviewRequest, Scoresheet, ScoresheetStatus};
use tms_seasons::{Answer, FieldKind};
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Card, Modal, Tab, Tabs, TextField, Tone};
use uuid::Uuid;

use super::shared::{sheet_tone, table_name};
use crate::components::{ErrorBox, NeedsActiveEvent, PageHeader, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::{Realtime, use_subscription};
use crate::routes::Route;
use crate::store::session::Session;
use crate::time::format_time;

#[component]
pub fn ScoresheetReview() -> Element {
  use_subscription(Topic::Scoresheets);
  use_subscription(Topic::Tables);
  let realtime = use_context::<Realtime>();
  let mut filter = use_signal(|| "waiting".to_owned());
  let mut open = use_signal(|| None::<Uuid>);
  let error = use_signal(|| None::<ApiFailure>);

  let Some(event) = realtime.stores.event.read().clone() else {
    return rsx! { PageHeader { title: "Scoresheets" } NeedsActiveEvent {} };
  };
  let mut sheets: Vec<Scoresheet> = realtime.stores.scoresheets.read().clone();
  sheets.sort_by_key(|s| std::cmp::Reverse(s.received_at));
  let count = |status| sheets.iter().filter(|s| s.status == status).count();
  let waiting = count(ScoresheetStatus::Submitted);
  let published = count(ScoresheetStatus::Published);
  let rejected = count(ScoresheetStatus::Rejected);
  let shown: Vec<Scoresheet> = sheets
    .into_iter()
    .filter(|s| match filter().as_str() {
      "waiting" => s.status == ScoresheetStatus::Submitted,
      "published" => s.status == ScoresheetStatus::Published,
      "rejected" => s.status == ScoresheetStatus::Rejected,
      _ => true,
    })
    .collect();

  rsx! {
    PageHeader {
      title: "Scoresheets",
      subtitle: "{waiting} waiting for review. Publishing a sheet replaces any earlier published sheet for that round.",
      back: (Route::MatchControl {}, "Match control".to_owned()),
    }
    div { class: "mb-4",
      Tabs {
        for (key , label) in [
            ("waiting", format!("Waiting ({waiting})")),
            ("published", format!("Published ({published})")),
            ("rejected", format!("Rejected ({rejected})")),
            ("all", "All".to_owned()),
        ]
        {
          Tab { active: filter() == key, onclick: move |_| filter.set(key.to_owned()), "{label}" }
        }
      }
    }
    if let Some(e) = error() {
      div { class: "mb-3", ErrorBox { error: e } }
    }
    if shown.is_empty() {
      p { class: "text-sm text-muted", "No scoresheets here." }
    }
    div { class: "flex flex-col gap-2",
      for sheet in shown {
        SheetCard {
          key: "{sheet.id}",
          expanded: open() == Some(sheet.id),
          ontoggle: move |id| open.set(if open() == Some(id) { None } else { Some(id) }),
          sheet,
          season_id: event.season_id.clone(),
          timezone: event.timezone.clone(),
          error,
        }
      }
    }
  }
}

/// "Blue table" from "key:Blue table": who sent a sheet, without the kind of login in front.
fn device_name(submitted_by: &str) -> &str {
  submitted_by.split_once(':').map_or(submitted_by, |(_, name)| name)
}

#[component]
fn SheetCard(
  sheet: Scoresheet,
  expanded: bool,
  ontoggle: EventHandler<Uuid>,
  season_id: String,
  timezone: String,
  error: Signal<Option<ApiFailure>>,
) -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let mut rejecting = use_signal(|| false);
  let tables = realtime.stores.tables.read().clone();
  let id = sheet.id;
  let review = move |action: &'static str| async move {
    error.set(None);
    if let Err(e) =
      api::post::<_, Scoresheet>(&format!("/scoresheets/{id}/{action}"), token(session).as_deref(), &()).await
    {
      error.set(Some(e));
    }
  };
  let table = sheet.table_id.map(|t| table_name(&tables, t)).unwrap_or_default();
  let kind = sheet.kind.label();

  rsx! {
    Card {
      div { class: "flex flex-wrap items-center gap-3", "data-testid": "sheet-row",
        button {
          class: "flex min-w-0 flex-1 flex-wrap items-center gap-3 text-left",
          onclick: move |_| ontoggle.call(id),
          span { class: "font-mono text-lg font-bold", "{sheet.team_number}" }
          span { class: "text-sm", "{kind} round {sheet.round}" }
          span { class: "text-sm text-muted", "{table}" }
          span { class: "font-mono text-lg font-semibold tabular-nums", "{sheet.score}" }
          if sheet.no_show {
            Badge { tone: Tone::Danger, "No show" }
          }
          Badge { tone: sheet_tone(sheet.status), "{sheet.status.label()}" }
          for flag in sheet.flags.clone() {
            Badge { tone: Tone::Warning, "{flag.label()}" }
          }
          span { class: "text-xs text-muted", "{format_time(sheet.received_at, &timezone)} · {sheet.referee_name} · {device_name(&sheet.submitted_by)}" }
        }
        div { class: "flex gap-1",
          if sheet.status == ScoresheetStatus::Submitted {
            Button { size: ButtonSize::Small, variant: ButtonVariant::Success, onclick: move |_| review("accept"), "Publish" }
          }
          if sheet.status == ScoresheetStatus::Published {
            Button { size: ButtonSize::Small, variant: ButtonVariant::Secondary, onclick: move |_| review("unpublish"), "Unpublish" }
          }
          if matches!(sheet.status, ScoresheetStatus::Submitted | ScoresheetStatus::Published) {
            Button { size: ButtonSize::Small, variant: ButtonVariant::Danger, onclick: move |_| rejecting.set(true), "Reject" }
          }
        }
      }
      if expanded {
        SheetDetails { sheet: sheet.clone(), season_id }
      }
    }
    if rejecting() {
      RejectDialog { id, team: sheet.team_number.clone(), onclose: move |()| rejecting.set(false), error }
    }
  }
}

#[component]
fn SheetDetails(sheet: Scoresheet, season_id: String) -> Element {
  let Some(season) = tms_seasons::by_id(&season_id) else {
    return rsx! { p { class: "text-sm text-muted", "Unknown season." } };
  };
  let gp = sheet.gp.map_or_else(|| "–".to_owned(), |g| g.to_string());
  rsx! {
    div { class: "mt-3 grid gap-x-6 gap-y-1 border-t border-line pt-3 text-sm md:grid-cols-2",
      for mission in season.missions {
        div { class: "py-1",
          p { class: "font-semibold", "{mission.name}" }
          for field in mission.fields {
            p { class: "flex justify-between gap-3",
              span { class: "text-muted", "{field.label}" }
              span { class: "font-mono", "{answer_text(field.kind, sheet.answers.get(field.id))}" }
            }
          }
        }
      }
    }
    div { class: "mt-3 flex flex-col gap-1 border-t border-line pt-3 text-sm",
      p { "Gracious Professionalism: {gp}" }
      if !sheet.gp_comment.is_empty() {
        p { class: "text-muted", "GP comment: {sheet.gp_comment}" }
      }
      p {
        if sheet.team_agreed {
          "Team agreed ({sheet.team_initials})"
        } else {
          "The team did not agree"
        }
      }
      if !sheet.private_comment.is_empty() {
        p { class: "text-muted", "Referee's note: {sheet.private_comment}" }
      }
      for issue in sheet.issues.clone() {
        p { class: "text-warning-strong", "Warning: {issue.message}" }
      }
      if !sheet.review_note.is_empty() {
        p { class: "text-danger-strong", "Rejected because: {sheet.review_note}" }
      }
    }
  }
}

fn answer_text(kind: FieldKind, answer: Option<&Answer>) -> String {
  match (kind, answer) {
    (_, None) => "–".into(),
    (_, Some(Answer::Bool(true))) => "Yes".into(),
    (_, Some(Answer::Bool(false))) => "No".into(),
    (_, Some(Answer::Count(n))) => n.to_string(),
    (FieldKind::Choice { options }, Some(Answer::Choice(key))) => options
      .iter()
      .find(|o| o.key == key)
      .map_or_else(|| key.clone(), |o| o.label.to_owned()),
    (_, Some(Answer::Choice(key))) => key.clone(),
  }
}

#[component]
fn RejectDialog(id: Uuid, team: String, onclose: EventHandler<()>, error: Signal<Option<ApiFailure>>) -> Element {
  let session = use_context::<Session>();
  let mut note = use_signal(String::new);
  rsx! {
    Modal {
      title: "Reject team {team}'s sheet?",
      onclose,
      footer: rsx! {
        Button { variant: ButtonVariant::Secondary, onclick: move |_| onclose.call(()), "Cancel" }
        Button {
          variant: ButtonVariant::Danger,
          disabled: note().trim().is_empty(),
          onclick: move |_| async move {
              let body = ReviewRequest { note: note() };
              match api::post::<_, Scoresheet>(&format!("/scoresheets/{id}/reject"), token(session).as_deref(), &body).await {
                  Ok(_) => error.set(None),
                  Err(e) => error.set(Some(e)),
              }
              onclose.call(());
          },
          "Reject"
        }
      },
      p { class: "mb-3 text-sm", "The referee sees this note and can score the round again." }
      TextField { label: "Reason", value: note(), oninput: move |v| note.set(v), autofocus: true }
    }
  }
}
