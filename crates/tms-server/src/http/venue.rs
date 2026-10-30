//! Competition tables and judging pods.

use axum::Json;
use axum::extract::{Path, State};
use axum::http::StatusCode;
use tms_core::dto::{PodInput, ReorderRequest, TableInput};
use tms_core::model::{GameTable, Pod};
use tms_core::ws::TopicItem;
use tms_core::{Role, Topic};
use uuid::Uuid;

use super::support::{audit, is_active, optional, publish_delete, publish_upsert, required};
use super::teams::in_use;
use crate::AppState;
use crate::auth::Auth;
use crate::error::{ApiError, ApiResult};
use crate::repo::{events, venue};

pub async fn tables(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Vec<GameTable>>> {
  auth.require(Role::Display)?;
  Ok(Json(venue::tables(&state.pool, event_id).await?))
}

pub async fn create_table(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
  Json(input): Json<TableInput>,
) -> ApiResult<Json<GameTable>> {
  auth.require(Role::Admin)?;
  let name = required(&input.name, "Table name", 60)?;
  events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  let mut tx = state.pool.begin().await?;
  let table = venue::insert_table(&mut *tx, event_id, &name).await?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "table.create",
    ("table", Some(table.id)),
    serde_json::json!({ "name": name }),
  )
  .await?;
  tx.commit().await?;
  publish_upsert(&state, event_id, Topic::Tables, TopicItem::Table(table.clone())).await?;
  Ok(Json(table))
}

pub async fn rename_table(
  State(state): State<AppState>,
  auth: Auth,
  Path(id): Path<Uuid>,
  Json(input): Json<TableInput>,
) -> ApiResult<Json<GameTable>> {
  auth.require(Role::Admin)?;
  let name = required(&input.name, "Table name", 60)?;
  let mut tx = state.pool.begin().await?;
  let table = venue::rename_table(&mut *tx, id, &name)
    .await?
    .ok_or(ApiError::NotFound("table"))?;
  audit(
    &mut *tx,
    &auth,
    Some(table.event_id),
    "table.rename",
    ("table", Some(id)),
    serde_json::json!({ "name": name }),
  )
  .await?;
  tx.commit().await?;
  publish_upsert(&state, table.event_id, Topic::Tables, TopicItem::Table(table.clone())).await?;
  Ok(Json(table))
}

pub async fn delete_table(State(state): State<AppState>, auth: Auth, Path(id): Path<Uuid>) -> ApiResult<StatusCode> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  let event_id = venue::delete_table(&mut *tx, id)
    .await
    .map_err(|e| {
      in_use(
        e,
        "This table has matches in the schedule. Import a schedule without it first.",
      )
    })?
    .ok_or(ApiError::NotFound("table"))?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "table.delete",
    ("table", Some(id)),
    serde_json::json!({}),
  )
  .await?;
  tx.commit().await?;
  publish_delete(&state, event_id, Topic::Tables, id).await?;
  Ok(StatusCode::NO_CONTENT)
}

pub async fn reorder_tables(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
  Json(input): Json<ReorderRequest>,
) -> ApiResult<Json<Vec<GameTable>>> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  venue::reorder_tables(&mut tx, event_id, &input.ids).await?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "table.reorder",
    ("event", Some(event_id)),
    serde_json::json!({ "ids": input.ids }),
  )
  .await?;
  tx.commit().await?;
  if is_active(&state, event_id).await? {
    state.bus.resnapshot(Topic::Tables);
  }
  Ok(Json(venue::tables(&state.pool, event_id).await?))
}

pub async fn pods(State(state): State<AppState>, auth: Auth, Path(event_id): Path<Uuid>) -> ApiResult<Json<Vec<Pod>>> {
  auth.require(Role::Display)?;
  Ok(Json(venue::pods(&state.pool, event_id).await?))
}

pub async fn create_pod(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
  Json(input): Json<PodInput>,
) -> ApiResult<Json<Pod>> {
  auth.require(Role::Admin)?;
  let name = required(&input.name, "Pod name", 60)?;
  let room = optional(input.room.as_deref(), "Room", 60)?;
  events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  let mut tx = state.pool.begin().await?;
  let pod = venue::insert_pod(&mut *tx, event_id, &name, room.as_deref()).await?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "pod.create",
    ("pod", Some(pod.id)),
    serde_json::json!({ "name": name, "room": room }),
  )
  .await?;
  tx.commit().await?;
  publish_upsert(&state, event_id, Topic::Pods, TopicItem::Pod(pod.clone())).await?;
  Ok(Json(pod))
}

pub async fn update_pod(
  State(state): State<AppState>,
  auth: Auth,
  Path(id): Path<Uuid>,
  Json(input): Json<PodInput>,
) -> ApiResult<Json<Pod>> {
  auth.require(Role::Admin)?;
  let name = required(&input.name, "Pod name", 60)?;
  let room = optional(input.room.as_deref(), "Room", 60)?;
  let mut tx = state.pool.begin().await?;
  let pod = venue::update_pod(&mut *tx, id, &name, room.as_deref())
    .await?
    .ok_or(ApiError::NotFound("pod"))?;
  audit(
    &mut *tx,
    &auth,
    Some(pod.event_id),
    "pod.update",
    ("pod", Some(id)),
    serde_json::json!({ "name": name, "room": room }),
  )
  .await?;
  tx.commit().await?;
  publish_upsert(&state, pod.event_id, Topic::Pods, TopicItem::Pod(pod.clone())).await?;
  Ok(Json(pod))
}

pub async fn delete_pod(State(state): State<AppState>, auth: Auth, Path(id): Path<Uuid>) -> ApiResult<StatusCode> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  let event_id = venue::delete_pod(&mut *tx, id)
    .await
    .map_err(|e| {
      in_use(
        e,
        "This pod has judging sessions in the schedule. Import a schedule without it first.",
      )
    })?
    .ok_or(ApiError::NotFound("pod"))?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "pod.delete",
    ("pod", Some(id)),
    serde_json::json!({}),
  )
  .await?;
  tx.commit().await?;
  publish_delete(&state, event_id, Topic::Pods, id).await?;
  Ok(StatusCode::NO_CONTENT)
}

pub async fn reorder_pods(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
  Json(input): Json<ReorderRequest>,
) -> ApiResult<Json<Vec<Pod>>> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  venue::reorder_pods(&mut tx, event_id, &input.ids).await?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "pod.reorder",
    ("event", Some(event_id)),
    serde_json::json!({ "ids": input.ids }),
  )
  .await?;
  tx.commit().await?;
  if is_active(&state, event_id).await? {
    state.bus.resnapshot(Topic::Pods);
  }
  Ok(Json(venue::pods(&state.pool, event_id).await?))
}
