//! Match state and the match timer.

use chrono::{DateTime, Utc};
use sqlx::{PgConnection, PgExecutor};
use tms_core::game::{MatchState, MatchTimer, TimerPhase};
use uuid::Uuid;

pub struct MatchRow {
  pub id: Uuid,
  pub event_id: Uuid,
  pub state: MatchState,
}

/// Locks the match row for the rest of the transaction.
pub async fn lock_match(tx: &mut PgConnection, id: Uuid) -> sqlx::Result<Option<MatchRow>> {
  sqlx::query_as!(
    MatchRow,
    r#"select id, event_id, state as "state: MatchState" from game_matches where id = $1 for update"#,
    id
  )
  .fetch_optional(&mut *tx)
  .await
}

/// Locks the event's timer row, creating it if needed, so timer actions on one event run one at a time.
pub async fn lock_timer(tx: &mut PgConnection, idle: &MatchTimer) -> sqlx::Result<(MatchTimer, Uuid)> {
  sqlx::query!(
    "insert into match_timers (event_id, run_id, countdown_ms, duration_ms, endgame_ms) values ($1, $2, $3, $4, $5)
     on conflict (event_id) do nothing",
    idle.event_id,
    Uuid::now_v7(),
    ms(idle.countdown_ms),
    ms(idle.duration_ms),
    ms(idle.endgame_ms),
  )
  .execute(&mut *tx)
  .await?;
  let row = sqlx::query!(
    r#"select event_id, run_id, phase as "phase: TimerPhase", starts_at, countdown_ms, duration_ms, endgame_ms, match_ids
       from match_timers where event_id = $1 for update"#,
    idle.event_id
  )
  .fetch_one(&mut *tx)
  .await?;
  Ok((
    MatchTimer {
      event_id: row.event_id,
      phase: row.phase,
      starts_at: row.starts_at,
      countdown_ms: unsigned(row.countdown_ms),
      duration_ms: unsigned(row.duration_ms),
      endgame_ms: unsigned(row.endgame_ms),
      match_ids: row.match_ids,
    },
    row.run_id,
  ))
}

pub async fn timer(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Option<(MatchTimer, Uuid)>> {
  Ok(timers(db, Some(event_id)).await?.into_iter().next())
}

/// Every timer in a live phase, to resume after a restart.
pub async fn live_timers(db: impl PgExecutor<'_>) -> sqlx::Result<Vec<(MatchTimer, Uuid)>> {
  Ok(
    timers(db, None)
      .await?
      .into_iter()
      .filter(|(t, _)| t.phase.is_live())
      .collect(),
  )
}

async fn timers(db: impl PgExecutor<'_>, event_id: Option<Uuid>) -> sqlx::Result<Vec<(MatchTimer, Uuid)>> {
  let rows = sqlx::query!(
    r#"select event_id, run_id, phase as "phase: TimerPhase", starts_at, countdown_ms, duration_ms, endgame_ms, match_ids
       from match_timers where $1::uuid is null or event_id = $1"#,
    event_id
  )
  .fetch_all(db)
  .await?;
  Ok(
    rows
      .into_iter()
      .map(|row| {
        (
          MatchTimer {
            event_id: row.event_id,
            phase: row.phase,
            starts_at: row.starts_at,
            countdown_ms: unsigned(row.countdown_ms),
            duration_ms: unsigned(row.duration_ms),
            endgame_ms: unsigned(row.endgame_ms),
            match_ids: row.match_ids,
          },
          row.run_id,
        )
      })
      .collect(),
  )
}

/// Replaces the timer with a new run.
pub async fn save_timer(tx: &mut PgConnection, timer: &MatchTimer, run_id: Uuid) -> sqlx::Result<()> {
  sqlx::query!(
    "update match_timers set run_id = $2, phase = $3, starts_at = $4, countdown_ms = $5, duration_ms = $6,
            endgame_ms = $7, match_ids = $8
     where event_id = $1",
    timer.event_id,
    run_id,
    timer.phase as TimerPhase,
    timer.starts_at,
    ms(timer.countdown_ms),
    ms(timer.duration_ms),
    ms(timer.endgame_ms),
    &timer.match_ids,
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

/// Moves a run to `phase`, only if that run is still the current one. Returns whether it was.
pub async fn advance_timer(
  tx: &mut PgConnection,
  event_id: Uuid,
  run_id: Uuid,
  phase: TimerPhase,
) -> sqlx::Result<bool> {
  let done = sqlx::query!(
    "update match_timers set phase = $3 where event_id = $1 and run_id = $2",
    event_id,
    run_id,
    phase as TimerPhase,
  )
  .execute(&mut *tx)
  .await?;
  Ok(done.rows_affected() == 1)
}

pub async fn set_state(tx: &mut PgConnection, id: Uuid, state: MatchState) -> sqlx::Result<()> {
  sqlx::query!(
    "update game_matches set state = $2,
            started_at = case when $2 in ('scheduled'::match_state, 'staged'::match_state) then null else started_at end,
            finished_at = case when $2 in ('scheduled'::match_state, 'staged'::match_state) then null else finished_at end
     where id = $1",
    id,
    state as MatchState,
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

/// Staged matches become running. Returns their ids.
pub async fn start_staged(tx: &mut PgConnection, event_id: Uuid, at: DateTime<Utc>) -> sqlx::Result<Vec<Uuid>> {
  sqlx::query_scalar!(
    "update game_matches set state = 'running', started_at = $2 where event_id = $1 and state = 'staged' returning id",
    event_id,
    at,
  )
  .fetch_all(&mut *tx)
  .await
}

/// Running matches among `ids` become finished.
pub async fn finish_running(tx: &mut PgConnection, ids: &[Uuid], at: DateTime<Utc>) -> sqlx::Result<Vec<Uuid>> {
  sqlx::query_scalar!(
    "update game_matches set state = 'finished', finished_at = $2 where id = any($1) and state = 'running' returning id",
    ids,
    at,
  )
  .fetch_all(&mut *tx)
  .await
}

/// Running matches among `ids` go back to staged, ready to run again.
pub async fn unstart_running(tx: &mut PgConnection, ids: &[Uuid]) -> sqlx::Result<Vec<Uuid>> {
  sqlx::query_scalar!(
    "update game_matches set state = 'staged', started_at = null where id = any($1) and state = 'running' returning id",
    ids,
  )
  .fetch_all(&mut *tx)
  .await
}

/// Labels of other staged matches that use one of this match's tables. They would run on the same timer start.
pub async fn table_clashes(db: impl PgExecutor<'_>, match_id: Uuid) -> sqlx::Result<Vec<String>> {
  sqlx::query_scalar!(
    r#"select distinct initcap(m.kind::text) || ' ' || m.number as "label!"
       from game_matches m
       join match_slots s on s.match_id = m.id
       where m.id <> $1 and m.state = 'staged'
         and m.event_id = (select event_id from game_matches where id = $1)
         and s.table_id in (select table_id from match_slots where match_id = $1)"#,
    match_id
  )
  .fetch_all(db)
  .await
}

/// Labels of earlier finished matches on this match's tables that still have a team without a scoresheet.
pub async fn unscored_before(db: impl PgExecutor<'_>, match_id: Uuid) -> sqlx::Result<Vec<String>> {
  sqlx::query_scalar!(
    r#"select distinct initcap(m.kind::text) || ' ' || m.number as "label!"
       from game_matches m
       join match_slots s on s.match_id = m.id
       join game_matches this on this.id = $1
       where m.event_id = this.event_id and m.state = 'finished' and m.scheduled_start < this.scheduled_start
         and s.team_id is not null and s.queue_state not in ('no_show', 'scratched')
         and s.table_id in (select table_id from match_slots where match_id = $1)
         and not exists (select 1 from scoresheets c where c.slot_id = s.id and c.status in ('published', 'submitted', 'superseded'))"#,
    match_id
  )
  .fetch_all(db)
  .await
}

fn ms(value: u32) -> i32 {
  i32::try_from(value).unwrap_or(i32::MAX)
}

fn unsigned(value: i32) -> u32 {
  u32::try_from(value).unwrap_or(0)
}
