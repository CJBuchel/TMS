//! Queue state of match slots.

use sqlx::PgConnection;
use tms_core::model::QueueState;
use uuid::Uuid;

pub struct SlotRow {
  pub event_id: Uuid,
  pub match_id: Uuid,
  pub team_id: Option<Uuid>,
  pub state: QueueState,
  pub previous: Option<QueueState>,
}

/// Locks a slot for the rest of the transaction.
pub async fn lock_slot(tx: &mut PgConnection, id: Uuid) -> sqlx::Result<Option<SlotRow>> {
  sqlx::query_as!(
    SlotRow,
    r#"select m.event_id, s.match_id, s.team_id, s.queue_state as "state: QueueState",
              s.queue_previous as "previous: QueueState"
       from match_slots s join game_matches m on m.id = s.match_id
       where s.id = $1 for update of s"#,
    id
  )
  .fetch_optional(&mut *tx)
  .await
}

/// Records a person's change, keeping the old state for undo.
pub async fn change(
  tx: &mut PgConnection,
  id: Uuid,
  from: QueueState,
  to: QueueState,
  actor: &str,
  note: &str,
) -> sqlx::Result<()> {
  // Undo returns to the previous state; the one before that is not kept, so undo works once.
  let previous = if to == QueueState::NotCalled { None } else { Some(from) };
  sqlx::query!(
    "update match_slots set queue_state = $2, queue_previous = $3, queue_changed_at = now(), queue_changed_by = $4
     where id = $1",
    id,
    to as QueueState,
    previous as Option<QueueState>,
    actor,
  )
  .execute(&mut *tx)
  .await?;
  sqlx::query!(
    "insert into slot_queue_events (slot_id, from_state, to_state, actor, note) values ($1, $2, $3, $4, $5)",
    id,
    from as QueueState,
    to as QueueState,
    actor,
    note,
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

/// The match timer moves slots of `match_ids` that are in one of `from` to `to`. Undo is cleared, because these
/// changes are the timer's, not a person's.
pub async fn timer_moves(
  tx: &mut PgConnection,
  match_ids: &[Uuid],
  from: &[QueueState],
  to: QueueState,
) -> sqlx::Result<()> {
  sqlx::query!(
    "update match_slots set queue_state = $3, queue_previous = null, queue_changed_at = now(), queue_changed_by = 'timer'
     where match_id = any($1) and team_id is not null and queue_state = any($2)",
    match_ids,
    from as &[QueueState],
    to as QueueState,
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

/// A reset match starts its queue again.
pub async fn reset_match(tx: &mut PgConnection, match_id: Uuid, actor: &str) -> sqlx::Result<()> {
  sqlx::query!(
    "update match_slots set queue_state = 'not_called', queue_previous = null, queue_changed_at = now(),
            queue_changed_by = $2
     where match_id = $1",
    match_id,
    actor,
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}
