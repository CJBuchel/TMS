use axum::Json;
use axum::extract::{Path, State};
use axum::http::StatusCode;
use tms_core::dto::{Banner, CreateBannerRequest};
use tms_core::ws::TopicItem;
use tms_core::{Role, Topic};
use uuid::Uuid;

use crate::AppState;
use crate::auth::Auth;
use crate::error::{ApiError, ApiResult};
use crate::repo::audit::{self, Entry};
use crate::repo::{banners, events};

pub async fn list(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Vec<Banner>>> {
  auth.require(Role::Display)?;
  Ok(Json(banners::list_active(&state.pool, event_id).await?))
}

pub async fn create(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
  Json(req): Json<CreateBannerRequest>,
) -> ApiResult<Json<Banner>> {
  auth.require(Role::Admin)?;
  let message = req.message.trim();
  if message.is_empty() || message.chars().count() > 500 {
    return Err(ApiError::BadRequest(
      "banner.invalid",
      "message must be 1-500 characters".into(),
    ));
  }
  let event = events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;

  let mut tx = state.pool.begin().await?;
  let banner = banners::insert(&mut *tx, event_id, req.severity, message, auth.user_id()).await?;
  audit::insert(
    &mut *tx,
    Entry {
      event_id: Some(event_id),
      actor: &auth.actor(),
      action: "banner.create",
      entity_type: "banner",
      entity_id: Some(banner.id),
      data: serde_json::json!({ "severity": req.severity, "message": message }),
    },
  )
  .await?;
  tx.commit().await?;

  if event.status == tms_core::dto::EventStatus::Active {
    state.bus.upsert(Topic::Banners, TopicItem::Banner(banner.clone()));
  }
  Ok(Json(banner))
}

pub async fn clear(State(state): State<AppState>, auth: Auth, Path(id): Path<Uuid>) -> ApiResult<StatusCode> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  let event_id = banners::clear(&mut *tx, id)
    .await?
    .ok_or(ApiError::NotFound("active banner"))?;
  audit::insert(
    &mut *tx,
    Entry {
      event_id: Some(event_id),
      actor: &auth.actor(),
      action: "banner.clear",
      entity_type: "banner",
      entity_id: Some(id),
      data: serde_json::json!({}),
    },
  )
  .await?;
  tx.commit().await?;

  // Harmless if the event is not active: nobody holding that banner is subscribed.
  state.bus.delete(Topic::Banners, id);
  Ok(StatusCode::NO_CONTENT)
}
