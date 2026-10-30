use axum::Json;
use axum::extract::{Path, State};
use tms_core::Role;
use tms_core::dto::{AccessKeySummary, CreateAccessKeyRequest, CreatedAccessKey};
use uuid::Uuid;

use super::support::{audit, required};
use crate::AppState;
use crate::auth::{Auth, Revocation, crypto};
use crate::error::{ApiError, ApiResult};
use crate::repo::{events, keys, venue};

pub async fn list(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Vec<AccessKeySummary>>> {
  auth.require(Role::Admin)?;
  Ok(Json(keys::list(&state.pool, event_id).await?))
}

/// A table binding is for referee stations, a pod binding for judging stations; the table or pod must belong
/// to the same event.
async fn check_binding(state: &AppState, event_id: Uuid, req: &CreateAccessKeyRequest) -> ApiResult<()> {
  if let Some(table_id) = req.table_id {
    if !matches!(req.role, Role::Referee | Role::HeadReferee) {
      return Err(ApiError::BadRequest(
        "key.invalid_binding",
        "only referee keys can be bound to a table".into(),
      ));
    }
    if !venue::tables(&state.pool, event_id)
      .await?
      .iter()
      .any(|t| t.id == table_id)
    {
      return Err(ApiError::BadRequest(
        "key.invalid_binding",
        "that table is not part of this event".into(),
      ));
    }
  }
  if let Some(pod_id) = req.pod_id {
    if !matches!(req.role, Role::Judge | Role::JudgeAdvisor) {
      return Err(ApiError::BadRequest(
        "key.invalid_binding",
        "only judge keys can be bound to a pod".into(),
      ));
    }
    if !venue::pods(&state.pool, event_id).await?.iter().any(|p| p.id == pod_id) {
      return Err(ApiError::BadRequest(
        "key.invalid_binding",
        "that pod is not part of this event".into(),
      ));
    }
  }
  Ok(())
}

/// The plaintext key is in this response only; the database keeps a SHA-256 of it.
pub async fn create(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
  Json(req): Json<CreateAccessKeyRequest>,
) -> ApiResult<Json<CreatedAccessKey>> {
  auth.require(Role::Admin)?;
  let label = required(&req.label, "Label", 100)?;
  events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  check_binding(&state, event_id, &req).await?;

  let key = crypto::new_access_key(req.role);
  let mut tx = state.pool.begin().await?;
  let summary = keys::insert(
    &mut *tx,
    keys::NewKey {
      event_id,
      key_hash: crypto::sha256(&key),
      prefix: req.role.key_prefix(),
      label: &label,
      roles: &[req.role],
      table_id: req.table_id,
      pod_id: req.pod_id,
      expires_at: req.expires_at,
      created_by: auth.user_id(),
    },
  )
  .await?;
  let data = serde_json::json!({ "label": label, "role": req.role, "table_id": req.table_id, "pod_id": req.pod_id });
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "key.create",
    ("access_key", Some(summary.id)),
    data,
  )
  .await?;
  tx.commit().await?;
  Ok(Json(CreatedAccessKey { key, summary }))
}

/// Revoking a key rejects every login token issued for it at once, and closes live connections using one.
pub async fn revoke(
  State(state): State<AppState>,
  auth: Auth,
  Path(id): Path<Uuid>,
) -> ApiResult<Json<AccessKeySummary>> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  let summary = keys::revoke(&mut *tx, id)
    .await?
    .ok_or(ApiError::NotFound("access key"))?;
  audit(
    &mut *tx,
    &auth,
    Some(summary.event_id),
    "key.revoke",
    ("access_key", Some(id)),
    serde_json::json!({}),
  )
  .await?;
  tx.commit().await?;
  state.auth.apply(Revocation::Key(id));
  Ok(Json(summary))
}
