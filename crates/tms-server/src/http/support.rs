//! Small helpers every handler uses.

use sqlx::PgExecutor;
use tms_core::Topic;
use tms_core::ws::TopicItem;
use uuid::Uuid;

use crate::AppState;
use crate::auth::Auth;
use crate::error::{ApiError, ApiResult};
use crate::repo::{audit, events};

/// Records who did what. Call inside the same transaction as the change.
pub async fn audit(
  db: impl PgExecutor<'_>,
  auth: &Auth,
  event_id: Option<Uuid>,
  action: &str,
  entity: (&str, Option<Uuid>),
  data: serde_json::Value,
) -> sqlx::Result<()> {
  audit::insert(
    db,
    audit::Entry {
      event_id,
      actor: &auth.actor(),
      action,
      entity_type: entity.0,
      entity_id: entity.1,
      data,
    },
  )
  .await
}

/// Live-feed topics carry the active event only; changes to any other event are not pushed.
pub async fn is_active(state: &AppState, event_id: Uuid) -> ApiResult<bool> {
  Ok(events::active_id(&state.pool).await? == Some(event_id))
}

pub async fn publish_upsert(state: &AppState, event_id: Uuid, topic: Topic, item: TopicItem) -> ApiResult<()> {
  if is_active(state, event_id).await? {
    state.bus.upsert(topic, item);
  }
  Ok(())
}

pub async fn publish_delete(state: &AppState, event_id: Uuid, topic: Topic, id: Uuid) -> ApiResult<()> {
  if is_active(state, event_id).await? {
    state.bus.delete(topic, id);
  }
  Ok(())
}

/// Trims `value` and checks it is 1..=`max` characters.
pub fn required(value: &str, what: &str, max: usize) -> ApiResult<String> {
  let value = value.trim();
  if value.is_empty() {
    return Err(ApiError::BadRequest("input.required", format!("{what} is required")));
  }
  if value.chars().count() > max {
    return Err(ApiError::BadRequest(
      "input.too_long",
      format!("{what} can be at most {max} characters"),
    ));
  }
  Ok(value.to_owned())
}

/// Trims `value`; empty becomes `None`.
pub fn optional(value: Option<&str>, what: &str, max: usize) -> ApiResult<Option<String>> {
  match value.map(str::trim) {
    None | Some("") => Ok(None),
    Some(v) => required(v, what, max).map(Some),
  }
}
