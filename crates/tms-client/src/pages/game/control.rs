//! Match control for the head referee: stage matches, run the timer, see what still needs scoring.

use dioxus::prelude::*;
use tms_core::Topic;
use tms_core::game::{MatchTimer, StageRequest, TimerStartRequest};
use tms_core::model::{GameMatch, GameTable, MatchSlot, MatchState, QueueState, ScoresheetStatus, Team};
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Card, Checkbox, Modal, TextField, Tone};
use uuid::Uuid;

use super::displays::table_colour;
use super::missing::MissingSheets;
use super::queue_ui::{QueueBadge, QueueButtons, QueueProgress};
use super::shared::{
  TimerBar, TimerClock, match_tone, sheet_tone, sorted_matches, table_name, team_label, use_server_now,
};
use crate::components::{ConfirmButton, ErrorBox, NeedsActiveEvent, PageHeader, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::{Realtime, use_subscription};
use crate::routes::Route;
use crate::store::session::Session;
use crate::time::format_time;

#[component]
pub fn MatchControl() -> Element {
  use_subscription(Topic::Matches);
  use_subscription(Topic::Teams);
  use_subscription(Topic::Tables);
  use_subscription(Topic::Timer);
  use_subscription(Topic::Scoresheets);
  use_subscription(Topic::Presence);
  let realtime = use_context::<Realtime>();
  let mut show_done = use_signal(|| false);
  let error = use_signal(|| None::<ApiFailure>);
  let force = use_signal(|| None::<(Uuid, String)>);

  let Some(event) = realtime.stores.event.read().clone() else {
    return rsx! { PageHeader { title: "Match control" } NeedsActiveEvent {} };
  };
  let matches = sorted_matches(&realtime.stores.matches.read());
  let waiting = realtime
    .stores
    .scoresheets
    .read()
    .iter()
    .filter(|s| s.status == ScoresheetStatus::Submitted)
    .count();
  let unscored: Vec<String> = matches
    .iter()
    .filter(|m| m.is_unscored())
    .map(GameMatch::label)
    .collect();
  let next_id = matches.iter().find(|m| m.state == MatchState::Scheduled).map(|m| m.id);
  let shown: Vec<GameMatch> = matches
    .iter()
    .filter(|m| show_done() || !matches!(m.state, MatchState::Finished | MatchState::Cancelled))
    .cloned()
    .collect();
  let staged: Vec<GameMatch> = matches
    .iter()
    .filter(|m| matches!(m.state, MatchState::Staged | MatchState::Running))
    .cloned()
    .collect();

  rsx! {
    PageHeader {
      title: "Match control",
      subtitle: "Stage the next matches, then start the timer. Matches end on their own when time runs out.",
      actions: rsx! {
        Pace {}
        Link { to: Route::ScoresheetReview {}, class: "inline-flex h-10 items-center gap-2 rounded-control border border-line-strong bg-surface px-4 text-sm font-semibold shadow-sm hover:bg-surface-2",
          "Scoresheets"
          if waiting > 0 {
            Badge { tone: Tone::Warning, "{waiting} to review" }
          }
        }
      },
    }
    if let Some(e) = error() {
      div { class: "mb-3", ErrorBox { error: e } }
    }
    if !unscored.is_empty() {
      div { class: "mb-3 flex items-center gap-2 rounded-control border border-warning bg-warning-soft px-3 py-2 text-sm text-warning-strong",
        span { class: "h-2 w-2 rounded-full bg-warning" }
        "Waiting for scoresheets: {unscored.join(\", \")}"
      }
    }
    div { class: "mb-4",
      TimerPanel {
        event_id: event.id,
        timer: realtime.stores.timer.read().clone(),
        staged,
        next: matches.iter().find(|m| Some(m.id) == next_id).cloned(),
        needs_ready: event.settings.start_needs_ready,
        error,
        force,
      }
    }
    div { class: "grid items-start gap-4 xl:grid-cols-[minmax(0,3fr)_minmax(0,2fr)]",
      Card {
        title: "Matches",
        actions: rsx! {
          Checkbox { label: "Show finished", checked: show_done(), onchange: move |v| show_done.set(v) }
        },
        if shown.is_empty() {
          p { class: "text-sm text-muted", "No matches to show. Import a schedule in event setup." }
        }
        ul { class: "-mx-2 flex flex-col gap-0.5",
          for m in shown {
            MatchRow { key: "{m.id}", is_next: Some(m.id) == next_id, m: m.clone(), timezone: event.timezone.clone(), error, force }
          }
        }
      }
      div { class: "flex flex-col gap-4",
        MissingSheets {}
        FieldPanel { timezone: event.timezone.clone() }
      }
    }
    if let Some((id, label)) = force() {
      ForceStage { id, label, error, force }
    }
  }
}

fn team_of(teams: &[Team], id: Option<Uuid>) -> Option<Team> {
  id.and_then(|id| teams.iter().find(|t| t.id == id)).cloned()
}

/// A table's colour dot and name, then the team's number and name.
#[component]
fn SlotTeam(tables: Vec<GameTable>, teams: Vec<Team>, slot: MatchSlot) -> Element {
  let table = table_name(&tables, slot.table_id);
  rsx! {
    span { class: "inline-flex min-w-0 items-center gap-2",
      span { class: "h-2.5 w-2.5 shrink-0 rounded-full", style: "background:{table_colour(&table)}" }
      span { class: "w-10 shrink-0 text-xs text-muted", "{table}" }
      match team_of(&teams, slot.team_id) {
          Some(team) => rsx! {
            span { class: "font-bold tabular-nums", "{team.number}" }
            span { class: "truncate", "{team.name}" }
          },
          None => rsx! { span { class: "text-muted", "No team" } },
      }
    }
  }
}

#[component]
fn MatchRow(
  m: GameMatch,
  is_next: bool,
  timezone: String,
  error: Signal<Option<ApiFailure>>,
  force: Signal<Option<(Uuid, String)>>,
) -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let teams = realtime.stores.teams.read().clone();
  let tables = realtime.stores.tables.read().clone();
  let id = m.id;
  // A signal, so the action closure stays `Copy` and every button can use it.
  let label = use_signal(|| m.label());

  let act = move |action: &'static str| async move {
    error.set(None);
    let result: Result<GameMatch, ApiFailure> =
      api::post(&format!("/matches/{id}/{action}"), token(session).as_deref(), &()).await;
    match result {
      Err(ApiFailure::Api { code, .. }) if code == "match.unscored_tables" => force.set(Some((id, label()))),
      Err(e) => error.set(Some(e)),
      Ok(_) => {}
    }
  };
  let row = match m.state {
    MatchState::Staged => "bg-info-soft ring-1 ring-inset ring-info/30",
    MatchState::Running => "bg-success-soft ring-1 ring-inset ring-success/30",
    MatchState::Finished | MatchState::Cancelled => "opacity-60",
    MatchState::Scheduled if is_next => "bg-surface-2",
    MatchState::Scheduled => "hover:bg-surface-2/60",
  };

  rsx! {
    li { class: "flex flex-wrap items-center gap-x-4 gap-y-2 rounded-control px-3 py-2.5 {row}", "data-testid": "match-row",
      div { class: "w-24 shrink-0",
        p { class: "font-semibold", "{m.label()}" }
        p { class: "font-mono text-xs text-muted", "{format_time(m.scheduled_start, &timezone)}" }
      }
      div { class: "grid min-w-0 flex-1 gap-x-4 gap-y-1 text-sm sm:grid-cols-2",
        for slot in m.slots.clone() {
          div { class: "flex min-w-0 items-center gap-2",
            SlotTeam { tables: tables.clone(), teams: teams.clone(), slot: slot.clone() }
            if slot.team_id.is_some() && m.state != MatchState::Cancelled && slot.queue != QueueState::NotCalled {
              QueueBadge { state: slot.queue }
            }
            if let Some(status) = slot.sheet {
              Badge { tone: sheet_tone(status), "{status.label()}" }
            }
            if m.state == MatchState::Finished && slot.queue == QueueState::NoShow {
              QueueButtons { slot_id: slot.id, state: slot.queue, previous: slot.queue_previous }
            }
          }
        }
      }
      div { class: "ml-auto flex items-center gap-1",
        if m.state != MatchState::Scheduled {
          Badge { tone: match_tone(m.state), "{m.state.label()}" }
        } else if is_next {
          Badge { tone: Tone::Primary, "Next" }
        }
        match m.state {
          MatchState::Scheduled => rsx! {
            Button {
              size: ButtonSize::Small,
              variant: if is_next { ButtonVariant::Primary } else { ButtonVariant::Secondary },
              onclick: move |_| act("stage"),
              "Stage"
            }
          },
          MatchState::Staged => rsx! {
            Button { size: ButtonSize::Small, variant: ButtonVariant::Secondary, onclick: move |_| act("unstage"), "Unstage" }
          },
          MatchState::Finished | MatchState::Cancelled => rsx! {
            ConfirmButton {
              label: "Reset",
              title: "Reset {m.label()}?",
              message: "The match goes back to scheduled so it can be run again. Its scoresheets stay.",
              confirm_label: "Reset",
              variant: ButtonVariant::Ghost,
              onconfirm: move |()| { spawn(act("reset")); },
            }
          },
          MatchState::Running => rsx! {},
        }
        if matches!(m.state, MatchState::Scheduled | MatchState::Staged | MatchState::Finished) {
          ConfirmButton {
            label: "Cancel",
            title: "Cancel {m.label()}?",
            message: "A cancelled match is not played. Reset it to bring it back.",
            confirm_label: "Cancel match",
            variant: ButtonVariant::DangerGhost,
            onconfirm: move |()| { spawn(act("cancel")); },
          }
        }
      }
    }
  }
}

/// Staging past an unscored match needs a reason, which the audit log keeps.
#[component]
fn ForceStage(
  id: Uuid,
  label: String,
  error: Signal<Option<ApiFailure>>,
  force: Signal<Option<(Uuid, String)>>,
) -> Element {
  let session = use_context::<Session>();
  let mut reason = use_signal(String::new);
  let mut local_error = use_signal(|| None::<ApiFailure>);
  rsx! {
    Modal {
      title: "Stage {label} anyway?",
      onclose: move |()| force.set(None),
      footer: rsx! {
        Button { variant: ButtonVariant::Secondary, onclick: move |_| force.set(None), "Cancel" }
        Button {
          variant: ButtonVariant::Warning,
          disabled: reason().trim().is_empty(),
          onclick: move |_| async move {
              let body = StageRequest { force: true, reason: reason() };
              match api::post::<_, GameMatch>(&format!("/matches/{id}/stage"), token(session).as_deref(), &body).await {
                  Ok(_) => {
                      error.set(None);
                      force.set(None);
                  }
                  Err(e) => local_error.set(Some(e)),
              }
          },
          "Stage anyway"
        }
      },
      p { class: "mb-3 text-sm", "An earlier match on the same tables still has a team without a scoresheet. Say why it is fine to go ahead." }
      TextField { label: "Reason", value: reason(), oninput: move |v| reason.set(v), autofocus: true }
      if let Some(e) = local_error() {
        div { class: "mt-3", ErrorBox { error: e } }
      }
    }
  }
}

#[component]
fn TimerPanel(
  event_id: Uuid,
  timer: Option<MatchTimer>,
  staged: Vec<GameMatch>,
  /// The next match to stage, offered here when nothing is staged so the head referee need not scroll for it.
  next: Option<GameMatch>,
  needs_ready: bool,
  error: Signal<Option<ApiFailure>>,
  force: Signal<Option<(Uuid, String)>>,
) -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let now = use_server_now();
  let mut start_anyway = use_signal(|| false);
  let teams = realtime.stores.teams.read().clone();
  let tables = realtime.stores.tables.read().clone();
  let live = timer.as_ref().is_some_and(|t| t.phase_at(now()).is_live());
  let has_staged = !live && staged.iter().any(|m| m.state == MatchState::Staged);
  let not_ready: Vec<String> = staged
    .iter()
    .filter(|m| m.state == MatchState::Staged)
    .flat_map(GameMatch::not_ready)
    .map(|s| team_label(&teams, s.team_id))
    .collect();
  let can_start = has_staged && (!needs_ready || not_ready.is_empty());

  let start = move |countdown: bool| async move {
    error.set(None);
    let body = TimerStartRequest {
      countdown,
      ..TimerStartRequest::default()
    };
    if let Err(e) = api::post::<_, MatchTimer>(
      &format!("/events/{event_id}/timer/start"),
      token(session).as_deref(),
      &body,
    )
    .await
    {
      error.set(Some(e));
    }
  };
  let stop = move |action: &'static str| async move {
    error.set(None);
    if let Err(e) = api::post::<_, MatchTimer>(
      &format!("/events/{event_id}/timer/{action}"),
      token(session).as_deref(),
      &(),
    )
    .await
    {
      error.set(Some(e));
    }
  };

  rsx! {
    section { class: "stage overflow-hidden rounded-panel border border-line bg-bg text-fg shadow-panel", "data-testid": "timer-panel",
      div { class: "grid gap-6 p-5 lg:grid-cols-[minmax(0,2fr)_minmax(0,3fr)]",
        div { class: "flex flex-col items-center justify-center gap-4",
          TimerClock { timer: timer.clone(), size_class: "text-7xl md:text-8xl" }
          div { class: "w-full max-w-sm", TimerBar { timer } }
          div { class: "flex flex-wrap justify-center gap-2",
            Button { size: ButtonSize::Large, disabled: !can_start, onclick: move |_| start(true), "Start with countdown" }
            Button { size: ButtonSize::Large, variant: ButtonVariant::Secondary, disabled: !can_start, onclick: move |_| start(false), "Start now" }
          }
          if has_staged && needs_ready && !not_ready.is_empty() {
            div { class: "flex flex-wrap items-center justify-center gap-2 text-sm",
              span { class: "text-warning-strong", "Waiting for: {not_ready.join(\", \")}" }
              Button { size: ButtonSize::Small, variant: ButtonVariant::Warning, onclick: move |_| start_anyway.set(true), "Start anyway" }
            }
          }
          if live {
            div { class: "flex flex-wrap justify-center gap-2",
              ConfirmButton {
                label: "End now",
                title: "End the match now?",
                message: "The running matches finish as if time ran out.",
                confirm_label: "End now",
                variant: ButtonVariant::Warning,
                size: ButtonSize::Medium,
                onconfirm: move |()| { spawn(stop("end")); },
              }
              ConfirmButton {
                label: "Abort",
                title: "Abort the match?",
                message: "The timer stops and the matches go back to staged, ready to start again.",
                confirm_label: "Abort",
                size: ButtonSize::Medium,
                onconfirm: move |()| { spawn(stop("abort")); },
              }
            }
          }
        }
        div { class: "flex min-w-0 flex-col gap-3",
          p { class: "text-xs font-semibold uppercase tracking-wider text-muted", "On the timer" }
          if staged.is_empty() {
            div { class: "flex flex-1 flex-col items-center justify-center gap-3 rounded-control border border-dashed border-line-strong p-6 text-center",
              p { class: "text-lg font-semibold", "Nothing staged." }
              match next.clone() {
                  Some(m) => {
                      let (id, label) = (m.id, m.label());
                      rsx! {
                        div { class: "flex flex-wrap justify-center gap-x-5 gap-y-1 text-sm",
                          for slot in m.slots.iter().filter(|s| s.team_id.is_some()).cloned() {
                            SlotTeam { tables: tables.clone(), teams: teams.clone(), slot }
                          }
                        }
                        Button {
                          size: ButtonSize::Huge,
                          onclick: move |_| {
                              let label = label.clone();
                              async move {
                                  error.set(None);
                                  match api::post::<_, GameMatch>(&format!("/matches/{id}/stage"), token(session).as_deref(), &()).await {
                                      Err(ApiFailure::Api { code, .. }) if code == "match.unscored_tables" => force.set(Some((id, label))),
                                      Err(e) => error.set(Some(e)),
                                      Ok(_) => {}
                                  }
                              }
                          },
                          "Stage {m.label()}"
                        }
                      }
                  }
                  None => rsx! { p { class: "text-sm text-muted", "No more matches to stage." } },
              }
            }
          }
          for m in staged {
            div { key: "{m.id}", class: "flex flex-col gap-2",
              div { class: "flex items-center gap-2",
                span { class: "text-xl font-bold tracking-tight", "{m.label()}" }
                Badge { tone: match_tone(m.state), "{m.state.label()}" }
              }
              div { class: "grid gap-2 sm:grid-cols-2",
                for slot in m.slots.clone() {
                  {
                      let table = table_name(&tables, slot.table_id);
                      let team = team_of(&teams, slot.team_id);
                      rsx! {
                        div {
                          key: "{slot.id}",
                          class: "flex min-w-0 flex-col gap-2 rounded-control border border-line bg-surface p-3",
                          style: "border-top: 4px solid {table_colour(&table)}",
                          span { class: "text-xs font-semibold uppercase tracking-wider text-muted", "{table}" }
                          match team {
                              Some(team) => rsx! {
                                div { class: "flex min-w-0 items-baseline gap-2",
                                  span { class: "text-3xl font-extrabold tabular-nums", "{team.number}" }
                                  span { class: "truncate text-base", "{team.name}" }
                                }
                                QueueProgress { state: slot.queue }
                                if m.state == MatchState::Staged {
                                  QueueButtons { slot_id: slot.id, state: slot.queue, previous: slot.queue_previous }
                                }
                              },
                              None => rsx! { p { class: "text-muted", "No team" } },
                          }
                        }
                      }
                  }
                }
              }
            }
          }
        }
      }
    }
    if start_anyway() {
      StartAnyway { event_id, not_ready: not_ready.clone(), onclose: move |()| start_anyway.set(false), error }
    }
  }
}

/// Starting before every team is ready needs a reason, which the audit log keeps.
#[component]
fn StartAnyway(
  event_id: Uuid,
  not_ready: Vec<String>,
  onclose: EventHandler<()>,
  error: Signal<Option<ApiFailure>>,
) -> Element {
  let session = use_context::<Session>();
  let mut reason = use_signal(String::new);
  rsx! {
    Modal {
      title: "Start before every team is ready?",
      onclose,
      footer: rsx! {
        Button { variant: ButtonVariant::Secondary, onclick: move |_| onclose.call(()), "Cancel" }
        Button {
          variant: ButtonVariant::Warning,
          disabled: reason().trim().is_empty(),
          onclick: move |_| async move {
              let body = TimerStartRequest { countdown: true, force: true, reason: reason() };
              match api::post::<_, MatchTimer>(&format!("/events/{event_id}/timer/start"), token(session).as_deref(), &body).await {
                  Ok(_) => error.set(None),
                  Err(e) => error.set(Some(e)),
              }
              onclose.call(());
          },
          "Start anyway"
        }
      },
      p { class: "mb-3 text-sm", "Not ready: {not_ready.join(\", \")}. Say why the match should start now." }
      TextField { label: "Reason", value: reason(), oninput: move |v| reason.set(v), autofocus: true }
    }
  }
}

/// Which tables have their station device connected, from the live feed's own connections.
/// Every table at a glance: its device, who is on it now and where they are, who is next, and whether the last
/// match's sheet has come in.
#[component]
pub fn FieldPanel(timezone: String) -> Element {
  let realtime = use_context::<Realtime>();
  let presence = realtime.stores.presence.read().clone();
  let teams = realtime.stores.teams.read().clone();
  let mut tables = realtime.stores.tables.read().clone();
  tables.sort_by_key(|t| t.sort_order);
  let matches = sorted_matches(&realtime.stores.matches.read());
  let unbound: Vec<_> = presence
    .iter()
    .filter(|p| p.table_id.is_none() && p.pod_id.is_none())
    .cloned()
    .collect();
  rsx! {
    Card { title: "Field",
      div { class: "grid gap-3 sm:grid-cols-2", "data-testid": "stations",
        for table in tables {
          {
              let slot_of = |m: &GameMatch| m.slots.iter().find(|s| s.table_id == table.id && s.team_id.is_some()).cloned();
              let now = matches
                  .iter()
                  .filter(|m| matches!(m.state, MatchState::Staged | MatchState::Running))
                  .find_map(|m| slot_of(m).map(|s| (m.clone(), s)));
              let next = matches
                  .iter()
                  .filter(|m| m.state == MatchState::Scheduled)
                  .find_map(|m| slot_of(m).map(|s| (m.clone(), s)));
              let last = matches
                  .iter()
                  .rev()
                  .filter(|m| m.state == MatchState::Finished)
                  .find_map(|m| slot_of(m).map(|s| (m.clone(), s)));
              let device = presence.iter().find(|p| p.table_id == Some(table.id)).cloned();
              rsx! {
                div { key: "{table.id}", class: "flex flex-col overflow-hidden rounded-control border border-line bg-surface",
                  div { class: "h-1", style: "background:{table_colour(&table.name)}" }
                  div { class: "flex min-w-0 flex-1 flex-col gap-2 p-3 text-sm",
                    div { class: "flex flex-wrap items-center justify-between gap-2",
                      span { class: "text-base font-bold", "{table.name}" }
                      match device.clone() {
                          Some(p) => rsx! { Badge { tone: Tone::Success, "{p.label} connected" } },
                          None => rsx! { Badge { tone: Tone::Danger, "No device" } },
                      }
                    }
                    if let Some(p) = device.filter(|p| p.waiting > 0) {
                      div {
                        Badge { tone: Tone::Warning, "{p.waiting} sheet(s) waiting on the tablet" }
                      }
                    }
                    match now {
                        Some((m, slot)) => rsx! {
                          div { class: "flex flex-wrap items-center gap-2",
                            span { class: "text-2xl font-extrabold tabular-nums", {crate::pages::game::shared::team_number(&teams, slot.team_id)} }
                            span { class: "truncate text-muted", "{m.label()}" }
                          }
                          QueueProgress { state: slot.queue }
                        },
                        None => rsx! { p { class: "py-1 text-muted", "Nothing staged" } },
                    }
                    if let Some((m, slot)) = next {
                      p { class: "text-xs text-muted",
                        "Next: "
                        span { class: "font-semibold text-fg", {team_label(&teams, slot.team_id)} }
                        " · {m.label()} · {format_time(m.scheduled_start, &timezone)}"
                      }
                    }
                    if let Some((m, slot)) = last {
                      div { class: "flex items-center gap-2 text-xs",
                        span { class: "text-muted", "{m.label()} sheet" }
                        match slot.sheet {
                            Some(status) => rsx! { Badge { tone: sheet_tone(status), "{status.label()}" } },
                            None if slot.queue.is_out() => rsx! { Badge { tone: Tone::Neutral, "{slot.queue.label()}" } },
                            None => rsx! { Badge { tone: Tone::Warning, "Missing" } },
                        }
                      }
                    }
                  }
                }
              }
          }
        }
      }
      if !unbound.is_empty() {
        ul { class: "mt-3 text-sm",
          for p in unbound {
            li { class: "flex items-center justify-between gap-3 py-1",
              span { class: "text-muted", "{p.role.label()} key, no table" }
              Badge { tone: Tone::Success, "{p.label} connected" }
            }
          }
        }
      }
    }
  }
}

/// How far behind the schedule the robot game is: the first match not started whose time has passed.
#[component]
fn Pace() -> Element {
  let realtime = use_context::<Realtime>();
  let now = use_server_now();
  let matches = sorted_matches(&realtime.stores.matches.read());
  let behind = matches
    .iter()
    .find(|m| m.state == MatchState::Scheduled)
    .map(|m| (now() - m.scheduled_start).num_minutes())
    .filter(|minutes| *minutes > 0);
  match behind {
    Some(minutes) if minutes >= 10 => rsx! { Badge { tone: Tone::Danger, "{minutes} min behind" } },
    Some(minutes) => rsx! { Badge { tone: Tone::Warning, "{minutes} min behind" } },
    None => rsx! { Badge { tone: Tone::Success, "On time" } },
  }
}
