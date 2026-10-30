//! The match timer. The database row is the truth; one tokio task per event moves a live run through its
//! phases at the right moments. Every start, abort and early end writes a new `run_id`, and a task only writes
//! while its run is current, so an aborted run can never end a later one. Tasks are also aborted directly.

use std::collections::HashMap;
use std::sync::Mutex;

use chrono::{DateTime, TimeDelta, Utc};
use tms_core::game::{MatchTimer, TimerPhase, TimerStartRequest};
use tms_core::model::{GameMatch, MatchState, QueueState};
use tms_core::ws::TopicItem;
use tms_core::{Role, Topic};
use tokio::task::AbortHandle;
use uuid::Uuid;

use crate::AppState;
use crate::auth::Auth;
use crate::error::{ApiError, ApiResult};
use crate::http::support::{audit, publish_upsert};
use crate::repo::{events, game, queue, schedule, teams};

pub struct TimerService {
  tasks: Mutex<HashMap<Uuid, AbortHandle>>,
  /// Divides match timings. 1 in production; tests raise it so a match lasts milliseconds.
  speedup: u32,
}

impl TimerService {
  pub fn new(speedup: u32) -> Self {
    Self {
      tasks: Mutex::default(),
      speedup: speedup.max(1),
    }
  }

  fn replace_task(&self, event_id: Uuid, task: Option<AbortHandle>) {
    let mut tasks = self.tasks.lock().expect("timer task map poisoned");
    if let Some(old) = tasks.remove(&event_id) {
      old.abort();
    }
    if let Some(task) = task {
      tasks.insert(event_id, task);
    }
  }
}

/// The idle timer for an event, with its configured timings.
async fn idle(state: &AppState, event_id: Uuid) -> ApiResult<MatchTimer> {
  let event = events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  let mut timer = MatchTimer::idle(event_id, &event.settings);
  let speedup = state.timers.speedup;
  timer.countdown_ms /= speedup;
  timer.duration_ms /= speedup;
  timer.endgame_ms /= speedup;
  Ok(timer)
}

pub async fn current(state: &AppState, event_id: Uuid) -> ApiResult<MatchTimer> {
  match game::timer(&state.pool, event_id).await? {
    Some((timer, _)) => Ok(timer),
    None => idle(state, event_id).await,
  }
}

/// Runs every staged match on the timer, with or without the countdown. When the event says so, every team must
/// be ready, a no-show or scratched first, unless the head referee forces the start with a reason.
pub async fn start(
  state: &AppState,
  auth: &Auth,
  event_id: Uuid,
  request: &TimerStartRequest,
) -> ApiResult<MatchTimer> {
  if request.force {
    auth.require(Role::HeadReferee)?;
    if request.reason.trim().is_empty() {
      return Err(ApiError::BadRequest(
        "timer.force_reason",
        "give a reason for starting before every team is ready".into(),
      ));
    }
  }
  let event = events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  let fresh = idle(state, event_id).await?;
  let now = Utc::now();
  let mut tx = state.pool.begin().await?;
  let (current, _) = game::lock_timer(&mut tx, &fresh).await?;
  if current.phase_at(now).is_live() {
    return Err(ApiError::Conflict(
      "timer.running",
      "the timer is already running".into(),
    ));
  }
  let staged: Vec<GameMatch> = schedule::matches(&mut tx, event_id)
    .await?
    .into_iter()
    .filter(|m| m.state == MatchState::Staged)
    .collect();
  if staged.is_empty() {
    return Err(ApiError::Conflict(
      "timer.nothing_staged",
      "stage a match before starting the timer".into(),
    ));
  }
  let waiting_for: Vec<Uuid> = staged
    .iter()
    .flat_map(GameMatch::not_ready)
    .filter_map(|s| s.team_id)
    .collect();
  if event.settings.start_needs_ready && !request.force && !waiting_for.is_empty() {
    let numbers: Vec<String> = teams::list(&mut *tx, event_id)
      .await?
      .into_iter()
      .filter(|t| waiting_for.contains(&t.id))
      .map(|t| t.number)
      .collect();
    return Err(ApiError::Conflict(
      "timer.not_ready",
      format!("not every team is ready: {}", numbers.join(", ")),
    ));
  }
  let match_ids = game::start_staged(&mut tx, event_id, now).await?;
  queue::timer_moves(&mut tx, &match_ids, &QueueState::BEFORE_MATCH, QueueState::Running).await?;
  let countdown = request.countdown;
  let countdown_ms = if countdown { fresh.countdown_ms } else { 0 };
  let timer = MatchTimer {
    phase: if countdown_ms > 0 {
      TimerPhase::Countdown
    } else {
      TimerPhase::Running
    },
    starts_at: Some(now + TimeDelta::milliseconds(countdown_ms.into())),
    match_ids,
    ..fresh
  };
  let run_id = Uuid::now_v7();
  game::save_timer(&mut tx, &timer, run_id).await?;
  audit(
    &mut *tx,
    auth,
    Some(event_id),
    "timer.start",
    ("event", Some(event_id)),
    serde_json::json!({
      "countdown": countdown, "matches": timer.match_ids, "force": request.force, "reason": request.reason,
      "not_ready": waiting_for,
    }),
  )
  .await?;
  tx.commit().await?;
  publish(state, &timer).await?;
  spawn(state, timer.clone(), run_id);
  Ok(timer)
}

/// Stops a live run. Its matches go back to staged so they can be run again.
pub async fn abort(state: &AppState, auth: &Auth, event_id: Uuid) -> ApiResult<MatchTimer> {
  stop(state, auth, event_id, TimerPhase::Aborted).await
}

/// Ends a live run now. Its matches finish as if the time had run out.
pub async fn end(state: &AppState, auth: &Auth, event_id: Uuid) -> ApiResult<MatchTimer> {
  stop(state, auth, event_id, TimerPhase::Ended).await
}

async fn stop(state: &AppState, auth: &Auth, event_id: Uuid, phase: TimerPhase) -> ApiResult<MatchTimer> {
  let fresh = idle(state, event_id).await?;
  let mut tx = state.pool.begin().await?;
  let (current, _) = game::lock_timer(&mut tx, &fresh).await?;
  if !current.phase_at(Utc::now()).is_live() {
    return Err(ApiError::Conflict(
      "timer.not_running",
      "the timer is not running".into(),
    ));
  }
  if phase == TimerPhase::Aborted {
    game::unstart_running(&mut tx, &current.match_ids).await?;
    queue::timer_moves(&mut tx, &current.match_ids, &[QueueState::Running], QueueState::Ready).await?;
  } else {
    game::finish_running(&mut tx, &current.match_ids, Utc::now()).await?;
    queue::timer_moves(&mut tx, &current.match_ids, &[QueueState::Running], QueueState::Done).await?;
  }
  let timer = MatchTimer { phase, ..current };
  game::save_timer(&mut tx, &timer, Uuid::now_v7()).await?;
  let action = if phase == TimerPhase::Aborted {
    "timer.abort"
  } else {
    "timer.end"
  };
  audit(
    &mut *tx,
    auth,
    Some(event_id),
    action,
    ("event", Some(event_id)),
    serde_json::json!({ "matches": timer.match_ids }),
  )
  .await?;
  tx.commit().await?;
  state.timers.replace_task(event_id, None);
  publish(state, &timer).await?;
  Ok(timer)
}

/// Picks up live runs after a restart. A run that should have ended while the server was down ends now.
pub async fn resume(state: &AppState) -> anyhow::Result<()> {
  for (timer, run_id) in game::live_timers(&state.pool).await? {
    tracing::info!(event_id = %timer.event_id, "resuming the match timer");
    spawn(state, timer, run_id);
  }
  Ok(())
}

fn spawn(state: &AppState, timer: MatchTimer, run_id: Uuid) {
  let event_id = timer.event_id;
  let task_state = state.clone();
  let handle = tokio::spawn(async move {
    if let Err(e) = run(&task_state, timer, run_id).await {
      tracing::error!(error = ?e, %event_id, "match timer task failed");
    }
  });
  state.timers.replace_task(event_id, Some(handle.abort_handle()));
}

/// Brings the stored phase up to the clock (catching up at once after a restart), then sleeps until the next
/// change, until the run has ended.
async fn run(state: &AppState, mut timer: MatchTimer, run_id: Uuid) -> ApiResult<()> {
  loop {
    let now = Utc::now();
    let due = timer.phase_at(now);
    if due != timer.phase {
      let mut tx = state.pool.begin().await?;
      if !game::advance_timer(&mut tx, timer.event_id, run_id, due).await? {
        return Ok(());
      }
      if due == TimerPhase::Ended {
        let ended_at = timer.ends_at().unwrap_or(now);
        game::finish_running(&mut tx, &timer.match_ids, ended_at).await?;
        queue::timer_moves(&mut tx, &timer.match_ids, &[QueueState::Running], QueueState::Done).await?;
      }
      tx.commit().await?;
      timer.phase = due;
      publish(state, &timer).await?;
    }
    let Some((at, _)) = timer.next_change(now) else {
      return Ok(());
    };
    sleep_until(at).await;
  }
}

async fn sleep_until(at: DateTime<Utc>) {
  if let Ok(wait) = (at - Utc::now()).to_std() {
    tokio::time::sleep(wait).await;
  }
}

/// Pushes the timer and the matches it runs.
async fn publish(state: &AppState, timer: &MatchTimer) -> ApiResult<()> {
  let event_id = timer.event_id;
  publish_upsert(state, event_id, Topic::Timer, TopicItem::Timer(timer.clone())).await?;
  let mut conn = state.pool.acquire().await?;
  for m in schedule::matches_by_id(&mut conn, event_id, &timer.match_ids).await? {
    publish_upsert(state, event_id, Topic::Matches, TopicItem::Match(m)).await?;
  }
  Ok(())
}

/// Whether the caller may run the timer: head referees, and the emcee who starts matches on the microphone.
pub fn may_run(auth: &Auth) -> ApiResult<()> {
  auth.require(Role::HeadReferee).or_else(|_| auth.require(Role::Emcee))
}
