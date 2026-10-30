//! Maintenance the launcher window does while the server is stopped: password recovery and purging an event.
//! Each change is audited with the actor `launcher`.

use anyhow::{Context, bail};
use chrono::Utc;
use sqlx::PgPool;
use tms_core::dto::EventSummary;

use crate::auth::crypto;
use crate::repo::{audit, events, users};

const ACTOR: &str = "launcher";

/// Gives a user the chosen password, or a one-time password (changed at their next login) when none is given,
/// and ends every login they have. Returns the one-time password. Works for a disabled user too, and re-enables
/// them, so a locked-out admin can always get back in.
pub async fn reset_password(pool: &PgPool, username: &str, chosen: Option<String>) -> anyhow::Result<Option<String>> {
  let user = users::find_by_username(pool, username.trim())
    .await?
    .with_context(|| format!("there is no user `{}`", username.trim()))?;
  let chosen = chosen.filter(|p| !p.is_empty());
  let one_time = chosen.is_none();
  let password = chosen.unwrap_or_else(|| crypto::new_token()[..12].to_owned());
  let hash = crypto::hash_password_blocking(password.clone()).await?;
  let mut tx = pool.begin().await?;
  users::set_password(&mut *tx, user.id, &hash, one_time, Utc::now()).await?;
  sqlx::query("update users set disabled = false where id = $1")
    .bind(user.id)
    .execute(&mut *tx)
    .await?;
  audit::insert(
    &mut *tx,
    audit::Entry {
      event_id: None,
      actor: ACTOR,
      action: "user.reset_password",
      entity_type: "user",
      entity_id: Some(user.id),
      data: serde_json::json!({ "username": user.username }),
    },
  )
  .await?;
  tx.commit().await?;
  Ok(one_time.then_some(password))
}

pub async fn event_list(pool: &PgPool) -> anyhow::Result<Vec<EventSummary>> {
  Ok(events::list(pool).await?)
}

/// Deletes an event and everything in it. `confirm_code` must be the event's code, typed by the person.
pub async fn purge_event(pool: &PgPool, event_id: uuid::Uuid, confirm_code: &str) -> anyhow::Result<()> {
  let event = events::get(pool, event_id)
    .await?
    .context("that event no longer exists")?;
  if !event.code.eq_ignore_ascii_case(confirm_code.trim()) {
    bail!("type the event code {} to confirm", event.code);
  }
  let mut tx = pool.begin().await?;
  // Children first: scoresheets point at teams and matches, and slots refuse to lose their team.
  sqlx::query!("delete from scoresheets where event_id = $1", event_id)
    .execute(&mut *tx)
    .await?;
  sqlx::query!("delete from rubrics where event_id = $1", event_id)
    .execute(&mut *tx)
    .await?;
  sqlx::query!("delete from awards where event_id = $1", event_id)
    .execute(&mut *tx)
    .await?;
  sqlx::query!("delete from advancements where event_id = $1", event_id)
    .execute(&mut *tx)
    .await?;
  sqlx::query!("delete from game_matches where event_id = $1", event_id)
    .execute(&mut *tx)
    .await?;
  sqlx::query!("delete from judging_sessions where event_id = $1", event_id)
    .execute(&mut *tx)
    .await?;
  sqlx::query("delete from events where id = $1")
    .bind(event_id)
    .execute(&mut *tx)
    .await?;
  audit::insert(
    &mut *tx,
    audit::Entry {
      event_id: None,
      actor: ACTOR,
      action: "event.purge",
      entity_type: "event",
      entity_id: Some(event_id),
      data: serde_json::json!({ "code": event.code, "name": event.name }),
    },
  )
  .await?;
  tx.commit().await?;
  Ok(())
}
