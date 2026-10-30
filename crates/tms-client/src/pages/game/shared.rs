//! Pieces every robot game screen uses: the live match clock, sounds, and team and table names.

use chrono::{DateTime, Utc};
use dioxus::prelude::*;
use gloo_storage::{LocalStorage, Storage};
use tms_core::game::{MatchTimer, TimerPhase};
use tms_core::model::{GameMatch, GameTable, MatchState, ScoresheetStatus, Team};
use tms_ui::{Badge, Tone};
use uuid::Uuid;

use crate::net::realtime::Realtime;

const SOUND_KEY: &str = "tms.sound";

/// Server time as a `DateTime`, refreshed every 100 ms while the calling component is mounted.
pub fn use_server_now() -> Signal<DateTime<Utc>> {
  let realtime = use_context::<Realtime>();
  let mut now = use_signal(|| server_now(&realtime));
  use_future(move || async move {
    loop {
      gloo_timers::future::TimeoutFuture::new(100).await;
      now.set(server_now(&realtime));
    }
  });
  now
}

fn server_now(realtime: &Realtime) -> DateTime<Utc> {
  DateTime::from_timestamp_millis(realtime.server_now_ms()).unwrap_or_default()
}

/// `2:30`, or whole seconds during the countdown.
pub fn format_remaining(ms: i64, phase: TimerPhase) -> String {
  let seconds = (ms + 999) / 1000;
  if phase == TimerPhase::Countdown {
    return seconds.to_string();
  }
  format!("{}:{:02}", seconds / 60, seconds % 60)
}

pub fn phase_tone(phase: TimerPhase) -> Tone {
  match phase {
    TimerPhase::Idle => Tone::Neutral,
    TimerPhase::Countdown => Tone::Info,
    TimerPhase::Running => Tone::Success,
    TimerPhase::Endgame => Tone::Warning,
    TimerPhase::Ended | TimerPhase::Aborted => Tone::Danger,
  }
}

fn phase_text_class(phase: TimerPhase) -> &'static str {
  match phase {
    TimerPhase::Idle => "text-muted",
    TimerPhase::Countdown => "text-info",
    TimerPhase::Running => "text-fg",
    TimerPhase::Endgame => "text-warning",
    TimerPhase::Ended | TimerPhase::Aborted => "text-danger",
  }
}

/// The match clock with its phase. `size_class` sets the digit size, from a panel to a full screen.
#[component]
pub fn TimerClock(timer: Option<MatchTimer>, size_class: String) -> Element {
  let now = use_server_now();
  let Some(timer) = timer else {
    return rsx! { p { class: "text-muted", "No timer yet." } };
  };
  let phase = timer.phase_at(now());
  let remaining = format_remaining(timer.display_ms(now()), phase);
  rsx! {
    div { class: "flex flex-col items-center gap-2",
      span {
        class: "font-extrabold tracking-tight tabular-nums leading-none {phase_text_class(phase)} {size_class}",
        "data-testid": "timer-clock",
        "{remaining}"
      }
      Badge { tone: phase_tone(phase), "{phase.label()}" }
    }
  }
}

/// How far through the match the clock is, with the end game marked at the end.
#[component]
pub fn TimerBar(timer: Option<MatchTimer>) -> Element {
  let now = use_server_now();
  let Some(timer) = timer else {
    return rsx! {};
  };
  let phase = timer.phase_at(now());
  let total = f64::from(timer.duration_ms.max(1));
  #[allow(clippy::cast_precision_loss)]
  let done = match phase {
    TimerPhase::Running | TimerPhase::Endgame => total - timer.display_ms(now()) as f64,
    TimerPhase::Ended => total,
    _ => 0.0,
  };
  let percent = (done / total * 100.0).clamp(0.0, 100.0);
  let endgame = f64::from(timer.endgame_ms) / total * 100.0;
  let fill = match phase {
    TimerPhase::Endgame => "bg-warning",
    TimerPhase::Ended | TimerPhase::Aborted => "bg-danger",
    _ => "bg-success",
  };
  rsx! {
    div { class: "relative h-3 rounded-full w-full overflow-hidden bg-surface-2", "data-testid": "timer-bar",
      div { class: "absolute inset-y-0 right-0 bg-warning-soft", style: "width: {endgame}%" }
      div { class: "absolute inset-y-0 left-0 {fill}", style: "width: {percent}%" }
    }
  }
}

/// Whether this device plays sounds. Off until someone turns it on, because browsers only allow sound after a
/// tap on the page, and a silent display is better than a surprising one.
#[derive(Clone, Copy, PartialEq)]
pub struct Sound(Signal<bool>);

impl Sound {
  pub fn on(self) -> bool {
    (self.0)()
  }

  pub fn toggle(mut self) {
    let next = !*self.0.peek();
    let _ = LocalStorage::set(SOUND_KEY, next);
    self.0.set(next);
  }
}

/// The tables named in a venue screen's `?tables=Red,Blue`, ignoring case; `None` for every table.
pub fn chosen_tables(tables: &[GameTable], spec: &str) -> Option<Vec<Uuid>> {
  let names: Vec<String> = spec
    .split(',')
    .map(|n| n.trim().to_lowercase())
    .filter(|n| !n.is_empty())
    .collect();
  if names.is_empty() {
    return None;
  }
  Some(
    tables
      .iter()
      .filter(|t| names.contains(&t.name.to_lowercase()))
      .map(|t| t.id)
      .collect(),
  )
}

/// "Red & Blue" for the chosen tables, in their set order.
pub fn chosen_label(tables: &[GameTable], chosen: Option<&[Uuid]>) -> Option<String> {
  let chosen = chosen?;
  let mut named: Vec<&GameTable> = tables.iter().filter(|t| chosen.contains(&t.id)).collect();
  named.sort_by_key(|t| t.sort_order);
  Some(named.iter().map(|t| t.name.as_str()).collect::<Vec<_>>().join(" & "))
}

/// Whether the timer's run includes a match on one of these tables (every table when `None`).
pub fn timer_is_for(timer: &MatchTimer, matches: &[GameMatch], chosen: Option<&[Uuid]>) -> bool {
  let Some(chosen) = chosen else {
    return true;
  };
  matches.iter().filter(|m| timer.match_ids.contains(&m.id)).any(|m| {
    m.slots
      .iter()
      .any(|s| s.team_id.is_some() && chosen.contains(&s.table_id))
  })
}

/// Plays the start, end game, end and abort sounds as the clock reaches each phase, when sound is on and the run is
/// for the screen's tables (`tables` as in `?tables=Red,Blue`; empty for all).
pub fn use_timer_sounds(tables: String) -> Sound {
  let realtime = use_context::<Realtime>();
  let sound = Sound(use_signal(|| LocalStorage::get(SOUND_KEY).unwrap_or(false)));
  let now = use_server_now();
  let mut last = use_signal(|| None::<TimerPhase>);
  use_effect(move || {
    let phase = realtime.stores.timer.read().as_ref().map(|t| t.phase_at(now()));
    let previous = *last.peek();
    if phase == previous {
      return;
    }
    last.set(phase);
    // The first phase seen is where the page joined, not a change worth announcing.
    if previous.is_none() || !sound.on() {
      return;
    }
    let chosen = chosen_tables(&realtime.stores.tables.peek(), &tables);
    let ours = realtime
      .stores
      .timer
      .peek()
      .as_ref()
      .is_some_and(|t| timer_is_for(t, &realtime.stores.matches.peek(), chosen.as_deref()));
    if !ours {
      return;
    }
    let file = match phase {
      Some(TimerPhase::Running) => "start",
      Some(TimerPhase::Endgame) => "end-game",
      Some(TimerPhase::Ended) => "end",
      Some(TimerPhase::Aborted) => "stop",
      _ => return,
    };
    document::eval(&format!("new Audio('/audio/{file}.mp3').play().catch(() => {{}})"));
  });
  sound
}

pub fn team_label(teams: &[Team], id: Option<Uuid>) -> String {
  match id.and_then(|id| teams.iter().find(|t| t.id == id)) {
    Some(t) => format!("{} {}", t.number, t.name),
    None => "No team".into(),
  }
}

pub fn team_number(teams: &[Team], id: Option<Uuid>) -> String {
  id.and_then(|id| teams.iter().find(|t| t.id == id))
    .map(|t| t.number.clone())
    .unwrap_or_default()
}

/// Tables two by two in their set order, as the queue board and venue screens group them: ("Red & Blue", ids).
pub fn table_pairs(tables: &[GameTable]) -> Vec<(String, Vec<Uuid>)> {
  let mut sorted = tables.to_vec();
  sorted.sort_by_key(|t| t.sort_order);
  sorted
    .chunks(2)
    .map(|pair| {
      let names: Vec<&str> = pair.iter().map(|t| t.name.as_str()).collect();
      (names.join(" & "), pair.iter().map(|t| t.id).collect())
    })
    .collect()
}

pub fn table_name(tables: &[GameTable], id: Uuid) -> String {
  tables
    .iter()
    .find(|t| t.id == id)
    .map_or_else(|| "Table".into(), |t| t.name.clone())
}

pub fn match_tone(state: MatchState) -> Tone {
  match state {
    MatchState::Scheduled => Tone::Neutral,
    MatchState::Staged => Tone::Info,
    MatchState::Running => Tone::Success,
    MatchState::Finished => Tone::Primary,
    MatchState::Cancelled => Tone::Danger,
  }
}

pub fn sheet_tone(status: ScoresheetStatus) -> Tone {
  match status {
    ScoresheetStatus::Submitted => Tone::Warning,
    ScoresheetStatus::Published => Tone::Success,
    ScoresheetStatus::Rejected => Tone::Danger,
    ScoresheetStatus::Superseded => Tone::Neutral,
  }
}

/// Matches in running order.
pub fn sorted_matches(matches: &[GameMatch]) -> Vec<GameMatch> {
  let mut sorted = matches.to_vec();
  sorted.sort_by_key(|m| {
    (
      m.scheduled_start,
      m.kind == tms_core::model::MatchKind::Ranking,
      m.number,
    )
  });
  sorted
}
