//! Settings: the scoresheets and rubrics made on this device and where each one is. Documents the server could
//! not place are fixed here; sent ones can be cleared.

use dioxus::prelude::*;
use tms_core::model::MatchKind;
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Card, Select, Tone};
use uuid::Uuid;

use crate::components::ConfirmButton;
use crate::net::realtime::Realtime;
use crate::pages::setup::team_order;
use crate::store::outbox::{Outbox, OutboxItem, OutboxState};
use crate::time::format_datetime;

fn state_tone(state: &OutboxState) -> Tone {
  match state {
    OutboxState::Pending => Tone::Warning,
    OutboxState::Sent { .. } => Tone::Success,
    OutboxState::NeedsBinding { .. } | OutboxState::Rejected { .. } => Tone::Danger,
  }
}

#[component]
pub fn DeviceSheets() -> Element {
  let realtime = use_context::<Realtime>();
  let mut outbox = use_context::<Outbox>();
  let event = realtime.stores.event.read().clone();
  let mut items = outbox.items();
  items.sort_by_key(|i| std::cmp::Reverse(i.doc.created_at()));
  let any_sent = items.iter().any(|i| matches!(i.state, OutboxState::Sent { .. }));
  let timezone = event.as_ref().map_or_else(|| "UTC".to_owned(), |e| e.timezone.clone());
  let event_id = event.as_ref().map(|e| e.id);

  rsx! {
    Card {
      title: "Scoresheets and rubrics on this device",
      actions: rsx! {
        if any_sent {
          Button { size: ButtonSize::Small, variant: ButtonVariant::Secondary, onclick: move |_| outbox.clear_sent(), "Clear sent" }
        }
      },
      if items.is_empty() {
        p { class: "text-sm text-muted", "No scoresheets or rubrics have been made on this device." }
      }
      ul { class: "divide-y divide-line", "data-testid": "device-sheets",
        for item in items {
          SheetRow { key: "{item.doc.id()}", other_event: Some(item.doc.event_id()) != event_id, item, timezone: timezone.clone() }
        }
      }
    }
  }
}

#[component]
fn SheetRow(item: OutboxItem, other_event: bool, timezone: String) -> Element {
  let mut outbox = use_context::<Outbox>();
  let id = item.doc.id();
  let team = item.doc.team_number().to_owned();
  rsx! {
    li { class: "py-2 text-sm",
      div { class: "flex flex-wrap items-center gap-2",
        span { class: "font-mono font-semibold", if team.is_empty() { "No team" } else { "{team}" } }
        span { "{item.doc.describe()}" }
        Badge { tone: state_tone(&item.state), "{item.state.label()}" }
        if let OutboxState::Sent { status, .. } = &item.state {
          span { class: "text-muted", "({status})" }
        }
        if other_event {
          Badge { tone: Tone::Neutral, "Other event: {item.doc.event_code()}" }
        }
        span { class: "text-xs text-muted", "{format_datetime(item.doc.created_at(), &timezone)}" }
      }
      match &item.state {
        OutboxState::Pending => rsx! {
          if let Some(error) = &item.last_error {
            p { class: "text-xs text-muted", "Last try: {error} ({item.attempts} tries)" }
          }
        },
        OutboxState::NeedsBinding { reason } => rsx! {
          p { class: "text-danger-strong", "{reason}" }
          if !other_event {
            BindForm { id, team, kind: item.doc.match_kind() }
          }
        },
        OutboxState::Rejected { message } => rsx! {
          p { class: "text-danger-strong", "{message}" }
          if !other_event {
            Button { size: ButtonSize::Small, variant: ButtonVariant::Secondary, onclick: move |_| outbox.retry(id), "Try again" }
          }
        },
        OutboxState::Sent { .. } => rsx! {},
      }
      if !matches!(item.state, OutboxState::Sent { .. }) {
        div { class: "mt-1",
          ConfirmButton {
            label: "Delete",
            title: "Delete this document?",
            message: "It has not reached the server. Deleting it removes it from this device for good.",
            confirm_label: "Delete",
            onconfirm: move |()| outbox.remove(id),
          }
        }
      }
    }
  }
}

/// Choose the team (and the round, for a scoresheet) the server couldn't work out, then send it again.
#[component]
fn BindForm(id: Uuid, team: String, kind: Option<MatchKind>) -> Element {
  let realtime = use_context::<Realtime>();
  let mut outbox = use_context::<Outbox>();
  let mut team = use_signal(|| team);
  let mut round = use_signal(String::new);
  let mut teams = realtime.stores.teams.read().clone();
  teams.sort_by(team_order);
  let rounds = realtime.stores.event.read().as_ref().map_or(3, |e| match kind {
    Some(MatchKind::Practice) => e.settings.practice_rounds.max(1),
    _ => e.settings.ranking_rounds,
  });
  let needs_round = kind.is_some();
  let ready = !team().is_empty() && (!needs_round || round().parse::<i32>().is_ok());
  rsx! {
    div { class: "mt-2 grid max-w-xl gap-2 sm:grid-cols-[1fr_8rem_auto] sm:items-end",
      Select {
        label: "Team",
        value: team(),
        options: std::iter::once((String::new(), "Choose a team".to_owned()))
            .chain(teams.iter().map(|t| (t.number.clone(), format!("{} {}", t.number, t.name))))
            .collect(),
        onchange: move |v| team.set(v),
      }
      if needs_round {
        Select {
          label: "Round",
          value: round(),
          options: std::iter::once((String::new(), "Choose".to_owned()))
              .chain((1..=rounds).map(|r| (r.to_string(), r.to_string())))
              .collect(),
          onchange: move |v| round.set(v),
        }
      } else {
        div {}
      }
      Button {
        disabled: !ready,
        onclick: move |_| outbox.bind(id, team(), round().parse().ok()),
        "Send again"
      }
    }
  }
}
