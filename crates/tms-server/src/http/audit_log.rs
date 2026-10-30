use axum::Json;
use axum::extract::{Query, State};
use serde::Deserialize;
use tms_core::Role;
use tms_core::dto::AuditEntry;
use uuid::Uuid;

use crate::AppState;
use crate::auth::Auth;
use crate::error::ApiResult;
use crate::repo::audit;

const MAX_PAGE: i64 = 200;

#[derive(Debug, Deserialize)]
pub struct AuditQuery {
  event_id: Option<Uuid>,
  entity_type: Option<String>,
  before: Option<i64>,
  limit: Option<i64>,
}

/// Newest first, `limit` entries (default 50, at most 200). Page backwards with `before`.
pub async fn list(
  State(state): State<AppState>,
  auth: Auth,
  Query(q): Query<AuditQuery>,
) -> ApiResult<Json<Vec<AuditEntry>>> {
  auth.require(Role::Admin)?;
  let limit = q.limit.unwrap_or(50).clamp(1, MAX_PAGE);
  let entity_type = q.entity_type.as_deref().filter(|s| !s.is_empty());
  Ok(Json(
    audit::list(&state.pool, q.event_id, entity_type, q.before, limit).await?,
  ))
}
