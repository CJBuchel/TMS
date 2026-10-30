//! Queue actions on match slots: queuers call teams, referees take them at the table.

use axum::Json;
use axum::extract::{Path, State};
use tms_core::Topic;
use tms_core::model::GameMatch;
use tms_core::queue::{QueueError, QueueRequest};
use tms_core::ws::TopicItem;
use uuid::Uuid;

use super::game::load_match;
use super::support::{audit, publish_upsert};
use crate::AppState;
use crate::auth::Auth;
use crate::error::{ApiError, ApiResult};
use crate::repo::queue;

/// Applies one queue action to a slot and returns the slot's match.
pub async fn act(
  State(state): State<AppState>,
  auth: Auth,
  Path(id): Path<Uuid>,
  Json(request): Json<QueueRequest>,
) -> ApiResult<Json<GameMatch>> {
  if auth.identity.must_change_password {
    return Err(ApiError::PasswordChangeRequired);
  }
  let mut tx = state.pool.begin().await?;
  let slot = queue::lock_slot(&mut tx, id).await?.ok_or(ApiError::NotFound("slot"))?;
  if slot.team_id.is_none() {
    return Err(ApiError::Conflict(
      "queue.no_team",
      "no team is scheduled in this slot".into(),
    ));
  }
  let next = request
    .action
    .allowed(&auth.identity.roles, slot.state)
    .and_then(|()| slot.state.apply(request.action, slot.previous))
    .map_err(|e| match e {
      QueueError::Forbidden { .. } => ApiError::Forbidden,
      QueueError::NotAllowed { .. } => ApiError::Conflict("queue.invalid_state", e.to_string()),
    })?;
  let note = request.note.trim();
  queue::change(&mut tx, id, slot.state, next, &auth.actor(), note).await?;
  audit(
    &mut *tx,
    &auth,
    Some(slot.event_id),
    &format!("slot.{}", request.action.key()),
    ("slot", Some(id)),
    serde_json::json!({ "match": slot.match_id, "team": slot.team_id, "from": slot.state, "to": next, "note": note }),
  )
  .await?;
  tx.commit().await?;
  let m = load_match(&state, slot.event_id, slot.match_id).await?;
  publish_upsert(&state, slot.event_id, Topic::Matches, TopicItem::Match(m.clone())).await?;
  Ok(Json(m))
}
