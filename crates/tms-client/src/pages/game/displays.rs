//! Screens for the venue: the scoreboard and the match timer, full screen and without a login, plus the emcee's
//! page.

use dioxus::prelude::*;
use tms_core::Topic;
use tms_core::game::{MatchTimer, TimerStartRequest};
use tms_core::model::{GameMatch, MatchState};
use tms_ui::{Button, ButtonSize, ButtonVariant, Card};

use super::queue_ui::relative;
use super::shared::{
  Sound, TimerBar, TimerClock, chosen_label, chosen_tables, sorted_matches, table_name, table_pairs, team_label,
  timer_is_for, use_server_now, use_timer_sounds,
};
use crate::components::{ErrorBox, NeedsActiveEvent, PageHeader, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::{Realtime, use_subscription};
use crate::pages::judging::CeremonyControls;
use crate::pages::setup::team_order;
use crate::routes::Route;
use crate::store::session::Session;
use crate::time::format_time;

/// More rows than this and the scoreboard scrolls.
const ROWS_ON_SCREEN: usize = 10;
/// Seconds each row stays in view while scrolling.
const SECONDS_PER_ROW: usize = 3;

/// The screens for the venue's TVs and projectors, none of which needs a login.
pub fn venue_screens() -> [(Route, &'static str, &'static str); 5] {
  [
    (
      Route::ScoreboardDisplay {},
      "Scoreboard",
      "Robot game ranking, scrolling when it doesn't fit",
    ),
    (
      Route::TimerDisplay { tables: String::new() },
      "Match timer",
      "The clock, the teams on each table, and the sounds",
    ),
    (
      Route::ScheduleDisplay {},
      "Schedule",
      "The next matches and judging sessions",
    ),
    (
      Route::QueueDisplay { tables: String::new() },
      "Queue",
      "Teams to come to the queue, for the pits",
    ),
    (Route::AwardsDisplay {}, "Awards", "The ceremony, one award at a time"),
  ]
}

/// Pick what this TV shows; the address to bookmark is under each. A TV beside a pair of tables can show just
/// that pair's timer or queue.
#[component]
pub fn DisplayIndex() -> Element {
  use_subscription(Topic::Tables);
  let realtime = use_context::<Realtime>();
  let pairs = table_pairs(&realtime.stores.tables.read());
  rsx! {
    DisplayFrame { title: "Venue screens",
      div { class: "flex min-h-0 flex-1 flex-col justify-center gap-10 overflow-y-auto",
      div { class: "grid gap-5 md:grid-cols-2 xl:grid-cols-3", "data-testid": "display-index",
        for (to , name , description) in venue_screens() {
          Link {
            to: to.clone(),
            class: "rounded-control group flex flex-col gap-2 border border-line bg-surface p-6 hover:border-primary",
            span { class: "text-3xl font-extrabold tracking-tight group-hover:text-primary", "{name}" }
            span { class: "text-lg text-muted", "{description}" }
            span { class: "font-mono text-sm text-muted", "{to}" }
          }
        }
      }
      if pairs.len() > 1 {
        section {
          h2 { class: "mb-3 text-xl font-semibold uppercase tracking-widest text-muted", "For one pair of tables" }
          div { class: "grid gap-3 md:grid-cols-2 xl:grid-cols-3", "data-testid": "display-pairs",
            for (label , _) in pairs {
              {
                  let spec = label.replace(" & ", ",");
                  rsx! {
                    div { class: "flex items-center justify-between gap-3 rounded-control border border-line bg-surface p-4",
                      span { class: "text-2xl font-bold", "{label}" }
                      div { class: "flex gap-2",
                        Link { to: Route::TimerDisplay { tables: spec.clone() }, class: "rounded-control border border-line-strong px-3 py-1.5 font-semibold hover:border-primary hover:text-primary", "Timer" }
                        Link { to: Route::QueueDisplay { tables: spec }, class: "rounded-control border border-line-strong px-3 py-1.5 font-semibold hover:border-primary hover:text-primary", "Queue" }
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
}

/// Full-screen frame on the dark stage palette: event name, what this screen is, and the event clock.
#[component]
pub fn DisplayFrame(title: String, #[props(default)] sound: Option<Sound>, children: Element) -> Element {
  use_subscription(Topic::Event);
  let realtime = use_context::<Realtime>();
  let event = realtime.stores.event.read().clone();
  let now = use_server_now();
  let clock = event
    .as_ref()
    .map(|e| crate::time::format_time(now(), &e.timezone))
    .unwrap_or_default();
  rsx! {
    div { class: "stage flex h-screen flex-col overflow-hidden bg-bg text-fg",
      header { class: "flex items-center gap-5 border-b border-line bg-surface px-8 py-4",
        div { class: "h-8 w-1.5 bg-primary" }
        span { class: "text-3xl font-extrabold tracking-tight", {event.as_ref().map_or_else(|| "TMS".to_owned(), |e| e.name.clone())} }
        span { class: "text-xl font-medium uppercase tracking-widest text-muted", "{title}" }
        div { class: "ml-auto flex items-center gap-4",
          if let Some(sound) = sound {
            button {
              class: "rounded-control border border-line-strong px-3 py-1 text-sm text-muted hover:text-fg",
              onclick: move |_| sound.toggle(),
              if sound.on() { "Sound on" } else { "Sound off" }
            }
          }
          span { class: "text-3xl font-semibold tabular-nums text-muted", "{clock}" }
        }
      }
      main { class: "flex min-h-0 flex-1 flex-col px-8 py-6", {children} }
    }
  }
}

/// A colour for a table named after one (Red, Blue…); other names get the accent.
pub fn table_colour(name: &str) -> &'static str {
  match name.trim().to_ascii_lowercase().as_str() {
    "red" => "#ef4444",
    "blue" => "#3b82f6",
    "green" => "#22c55e",
    "yellow" => "#eab308",
    "orange" => "#f97316",
    "pink" => "#ec4899",
    "purple" => "#a855f7",
    "black" => "#6b7280",
    "white" => "#e5e7eb",
    _ => "var(--tms-primary)",
  }
}

/// Text that reads on `table_colour`: dark on the light colours, white on the rest.
pub fn on_table_colour(name: &str) -> &'static str {
  match name.trim().to_ascii_lowercase().as_str() {
    "yellow" | "white" | "green" | "orange" => "#111827",
    _ => "#ffffff",
  }
}

#[component]
fn RankBadge(rank: u32) -> Element {
  let style = match rank {
    1 => "background:#f5c542;color:#1a1300",
    2 => "background:#c9d1dc;color:#10141a",
    3 => "background:#d08a4e;color:#1a0d00",
    _ => "",
  };
  rsx! {
    span {
      class: "inline-flex h-12 min-w-12 items-center justify-center px-2 text-2xl font-extrabold tabular-nums",
      style,
      "{rank}"
    }
  }
}

#[component]
pub fn ScoreboardDisplay() -> Element {
  use_subscription(Topic::Rankings);
  use_subscription(Topic::Teams);
  let realtime = use_context::<Realtime>();
  let rankings = realtime.stores.rankings.read().clone();
  let teams = realtime.stores.teams.read().clone();
  let rounds = rankings.first().map_or(0, |r| r.scores.len());
  let scrolls = rankings.len() > ROWS_ON_SCREEN;
  let columns = format!("grid-template-columns: 6rem minmax(0,1fr) repeat({rounds}, 7rem) 8rem");
  let rows = |copy: bool| {
    rsx! {
      table {
        class: "block w-full text-3xl",
        "data-testid": if copy { "" } else { "scoreboard" },
        "aria-hidden": if copy { "true" } else { "false" },
        tbody { class: "block",
          for row in rankings.clone() {
            tr { class: "grid items-center border-b border-line py-2", style: "{columns}",
              td { RankBadge { rank: row.rank } }
              td { class: "truncate pr-4",
                span { class: "font-extrabold tabular-nums", {crate::pages::game::shared::team_number(&teams, Some(row.team_id))} }
                " "
                span { class: "ml-2 font-medium text-muted", {teams.iter().find(|t| t.id == row.team_id).map(|t| t.name.clone()).unwrap_or_default()} }
              }
              for score in row.scores.clone() {
                td { class: "text-right tabular-nums text-muted", {score.map_or_else(|| "–".to_owned(), |s| s.to_string())} }
              }
              td { class: "text-right text-4xl font-extrabold tabular-nums text-primary-strong", {row.best.map_or_else(|| "–".to_owned(), |s| s.to_string())} }
            }
          }
        }
      }
    }
  };

  rsx! {
    DisplayFrame { title: "Robot game rankings",
      div { class: "grid border-b-2 border-line-strong pb-2 text-lg font-semibold uppercase tracking-widest text-muted", style: "{columns}",
        span { "Rank" }
        span { "Team" }
        for r in 1..=rounds {
          span { class: "text-right", "Round {r}" }
        }
        span { class: "text-right", "Best" }
      }
      div { class: "relative min-h-0 flex-1 overflow-hidden",
        div {
          class: if scrolls { "tms-scroll" } else { "" },
          style: "--tms-scroll-seconds: {rankings.len() * SECONDS_PER_ROW}s",
          {rows(false)}
          if scrolls {
            {rows(true)}
          }
        }
      }
    }
  }
}

/// The matches on the clock, or the next ones staged.
fn on_the_field(matches: &[GameMatch]) -> Vec<GameMatch> {
  matches
    .iter()
    .filter(|m| matches!(m.state, MatchState::Staged | MatchState::Running))
    .cloned()
    .collect()
}

#[component]
fn FieldLineup(matches: Vec<GameMatch>, large: bool, #[props(default = 2)] columns: usize) -> Element {
  let realtime = use_context::<Realtime>();
  let teams = realtime.stores.teams.read().clone();
  let tables = realtime.stores.tables.read().clone();
  let (number, name) = if large {
    ("text-6xl", "text-2xl")
  } else {
    ("text-2xl", "text-sm")
  };
  rsx! {
    div { class: "flex flex-col gap-4",
      for m in matches {
        div {
          p { class: "mb-2 text-sm font-semibold uppercase tracking-widest text-muted", "{m.label()}" }
          div { class: if columns == 3 { "grid gap-3 sm:grid-cols-3" } else { "grid gap-3 sm:grid-cols-2" },
            for slot in m.slots.clone() {
              {
                  let table = table_name(&tables, slot.table_id);
                  let colour = table_colour(&table);
                  let team = slot.team_id.and_then(|id| teams.iter().find(|t| t.id == id)).cloned();
                  rsx! {
                    div { class: "rounded-control flex items-stretch border border-line bg-surface",
                      div { class: "w-2", style: "background:{colour}" }
                      div { class: "flex min-w-0 flex-1 flex-col px-5 py-3",
                        span { class: "text-sm font-semibold uppercase tracking-widest text-muted", "{table}" }
                        match team {
                            Some(t) => rsx! {
                              span { class: "{number} font-extrabold tabular-nums leading-tight", "{t.number}" }
                              span { class: "{name} truncate text-muted", "{t.name}" }
                            },
                            None => rsx! { span { class: "{number} font-extrabold text-muted", "–" } },
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
}

/// The match clock for the venue. With `?tables=Red,Blue` it is for those tables only: while another pair's match
/// runs it shows when theirs is instead, so teams waiting there are not confused by a clock that isn't theirs.
#[component]
pub fn TimerDisplay(tables: String) -> Element {
  use_subscription(Topic::Timer);
  use_subscription(Topic::Matches);
  use_subscription(Topic::Teams);
  use_subscription(Topic::Tables);
  let realtime = use_context::<Realtime>();
  let now = use_server_now();
  let sound = use_timer_sounds(tables.clone());
  let all_tables = realtime.stores.tables.read().clone();
  let chosen = chosen_tables(&all_tables, &tables);
  let matches = sorted_matches(&realtime.stores.matches.read());
  let timer = realtime.stores.timer.read().clone();
  let ours = |m: &GameMatch| -> Option<GameMatch> {
    match &chosen {
      None => Some(m.clone()),
      Some(ids) => {
        let slots: Vec<_> = m.slots.iter().filter(|s| ids.contains(&s.table_id)).cloned().collect();
        slots
          .iter()
          .any(|s| s.team_id.is_some())
          .then(|| GameMatch { slots, ..m.clone() })
      }
    }
  };
  let phase = timer.as_ref().map(|t| t.phase_at(now()));
  let live = phase.is_some_and(tms_core::game::TimerPhase::is_live);
  let timer_for_us = timer
    .as_ref()
    .is_some_and(|t| timer_is_for(t, &matches, chosen.as_deref()));
  let staged: Vec<GameMatch> = matches
    .iter()
    .filter(|m| matches!(m.state, MatchState::Staged | MatchState::Running))
    .filter_map(ours)
    .collect();
  let timed: Vec<GameMatch> = timer
    .as_ref()
    .map(|t| {
      matches
        .iter()
        .filter(|m| t.match_ids.contains(&m.id))
        .filter_map(ours)
        .collect()
    })
    .unwrap_or_default();
  let show_clock = chosen.is_none() || timer_for_us || (!live && !staged.is_empty());
  let lineup = if timed.is_empty() || (!live && !staged.is_empty()) {
    staged.clone()
  } else {
    timed
  };
  let slots = lineup.iter().map(|m| m.slots.len()).sum::<usize>();
  let clock_size = match slots {
    0..=2 => "text-[min(40vh,30vw)]",
    3..=4 => "text-[min(30vh,24vw)]",
    _ => "text-[min(24vh,20vw)]",
  };
  let pair = chosen_label(&all_tables, chosen.as_deref());
  let title = pair
    .as_ref()
    .map_or_else(|| "Match timer".to_owned(), |p| format!("Match timer · {p}"));
  let next = if staged.is_empty() {
    matches
      .iter()
      .filter(|m| m.state == MatchState::Scheduled)
      .find_map(ours)
  } else {
    staged.first().cloned()
  };
  let timezone = realtime
    .stores
    .event
    .read()
    .as_ref()
    .map_or_else(|| "UTC".to_owned(), |e| e.timezone.clone());

  rsx! {
    DisplayFrame { title, sound,
      if show_clock {
        div { class: "flex min-h-0 flex-1 flex-col items-center justify-center gap-5",
          TimerClock { timer: timer.clone(), size_class: clock_size }
          div { class: "w-full max-w-6xl", TimerBar { timer } }
          div { class: "w-full max-w-6xl", FieldLineup { matches: lineup, large: true, columns: if slots > 4 { 3 } else { 2 } } }
        }
      } else {
        div { class: "flex min-h-0 flex-1 flex-col items-center justify-center gap-6 text-center", "data-testid": "timer-waiting",
          p { class: "text-3xl font-semibold uppercase tracking-widest text-muted",
            if live { "Another match is running" } else { "Next match" }
          }
          match next {
              Some(m) => rsx! {
                p { class: "text-[min(14vh,9vw)] font-extrabold leading-none tracking-tight", "{m.label()}" }
                p { class: "text-4xl font-semibold text-muted", "starts at {format_time(m.scheduled_start, &timezone)} · {relative(m.scheduled_start, now())}" }
                div { class: "w-full max-w-6xl text-left", FieldLineup { matches: vec![m], large: true, columns: 2 } }
              },
              None => rsx! { p { class: "text-5xl font-bold", "No more matches on these tables." } },
          }
        }
      }
    }
  }
}

/// The emcee's page: the clock, who is on the field, who is next, and the ranking to read out.
#[component]
pub fn Emcee() -> Element {
  use_subscription(Topic::Timer);
  use_subscription(Topic::Matches);
  use_subscription(Topic::Teams);
  use_subscription(Topic::Tables);
  use_subscription(Topic::Rankings);
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let now = use_server_now();
  let mut error = use_signal(|| None::<ApiFailure>);

  let Some(event) = realtime.stores.event.read().clone() else {
    return rsx! { PageHeader { title: "Emcee" } NeedsActiveEvent {} };
  };
  let matches = sorted_matches(&realtime.stores.matches.read());
  let field = on_the_field(&matches);
  let next: Vec<GameMatch> = matches
    .iter()
    .filter(|m| m.state == MatchState::Scheduled)
    .take(1)
    .cloned()
    .collect();
  let timer = realtime.stores.timer.read().clone();
  let all_ready = !event.settings.start_needs_ready || field.iter().all(|m| m.not_ready().next().is_none());
  let can_start = !timer.as_ref().is_some_and(|t| t.phase_at(now()).is_live())
    && field.iter().any(|m| m.state == MatchState::Staged)
    && all_ready;
  let mut teams = realtime.stores.teams.read().clone();
  teams.sort_by(team_order);
  let top: Vec<_> = realtime.stores.rankings.read().iter().take(10).cloned().collect();
  let event_id = event.id;

  let say = |m: &GameMatch| -> String {
    let tables = realtime.stores.tables.peek();
    let parts: Vec<String> = m
      .slots
      .iter()
      .filter_map(|s| {
        let team = s.team_id.and_then(|id| teams.iter().find(|t| t.id == id))?;
        Some(format!(
          "on {}, team {}, {}",
          table_name(&tables, s.table_id),
          team.number,
          team.name
        ))
      })
      .collect();
    format!("{}: {}.", m.label(), parts.join("; "))
  };
  let scored: Vec<_> = top.iter().filter(|r| r.best.is_some()).cloned().collect();

  rsx! {
    PageHeader { title: "Emcee", subtitle: "What is happening on the field, worded to read out." }
    if let Some(e) = error() {
      div { class: "mb-3", ErrorBox { error: e } }
    }
    div { class: "grid items-start gap-4 lg:grid-cols-[minmax(0,3fr)_minmax(0,2fr)]",
      div { class: "flex flex-col gap-4",
        section { class: "overflow-hidden rounded-panel border border-line bg-surface shadow-panel", "data-testid": "emcee-script",
          div { class: "border-b border-line bg-primary-soft px-5 py-2.5 text-sm font-semibold text-primary-strong", "Read this out" }
          div { class: "flex flex-col gap-4 p-5 text-2xl leading-snug",
            if field.is_empty() {
              p { class: "text-muted", "Nothing staged yet. The head referee stages the next match." }
            }
            for m in field.iter() {
              p { span { class: "font-bold", "Now on the field. " } "{say(m)}" }
            }
            for m in next.iter() {
              p { class: "text-muted",
                span { class: "font-bold text-fg", "Coming up next, at {format_time(m.scheduled_start, &event.timezone)}. " }
                "{say(m)}"
              }
            }
          }
        }
        section { class: "stage flex flex-wrap items-center justify-between gap-4 rounded-panel border border-line bg-bg p-5 text-fg shadow-panel",
          TimerClock { timer, size_class: "text-7xl" }
          Button {
            size: ButtonSize::Huge,
            variant: ButtonVariant::Primary,
            disabled: !can_start,
            onclick: move |_| async move {
                error.set(None);
                let body = TimerStartRequest {
                    countdown: true,
                    ..TimerStartRequest::default()
                };
                if let Err(e) = api::post::<_, MatchTimer>(&format!("/events/{event_id}/timer/start"), token(session).as_deref(), &body).await {
                    error.set(Some(e));
                }
            },
            "Start with countdown"
          }
        }
        Card { title: "On the field",
          if field.is_empty() {
            p { class: "text-sm text-muted", "Nothing staged yet." }
          }
          FieldLineup { matches: field.clone(), large: false, columns: 3 }
        }
      }
      div { class: "flex flex-col gap-4",
        Card { title: "Top 10",
          if scored.is_empty() {
            p { class: "text-sm text-muted", "No scores yet." }
          }
          ol { class: "flex flex-col",
            for row in scored {
              li { class: "flex items-center gap-3 border-b border-line py-2 last:border-b-0",
                span { class: "flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-surface-2 text-sm font-bold tabular-nums", "{row.rank}" }
                span { class: "min-w-0 flex-1 truncate", "{row.rank}. {team_label(&teams, Some(row.team_id))}" }
                span { class: "font-semibold tabular-nums", {row.best.map_or_else(|| "–".to_owned(), |s| s.to_string())} }
              }
            }
          }
        }
      }
    }
    div { class: "mt-4", CeremonyControls {} }
  }
}
