use axum::Json;
use axum::extract::{Path, State};
use chrono::NaiveDate;
use tms_core::dto::{CreateEventRequest, EventStatus, EventSummary, Season, UpdateEventRequest};
use tms_core::ws::TopicItem;
use tms_core::{Role, Topic};
use uuid::Uuid;

use super::support::{audit, is_active, required};
use crate::AppState;
use crate::auth::{Auth, Revocation};
use crate::error::{ApiError, ApiResult};
use crate::repo::{awards, events, keys};

/// Seasons TMS can score, from `tms-seasons`.
pub async fn seasons() -> Json<Vec<Season>> {
  Json(
    tms_seasons::SEASONS
      .iter()
      .map(|s| Season {
        id: s.id.to_owned(),
        name: s.name.to_owned(),
      })
      .collect(),
  )
}

fn check_common(season_id: &str, timezone: &str, starts_on: NaiveDate, ends_on: NaiveDate) -> ApiResult<()> {
  if tms_seasons::by_id(season_id).is_none() {
    return Err(ApiError::BadRequest(
      "event.unknown_season",
      format!("`{season_id}` is not a season TMS knows"),
    ));
  }
  if timezone.parse::<chrono_tz::Tz>().is_err() {
    return Err(ApiError::BadRequest(
      "event.invalid_timezone",
      format!("`{timezone}` is not an IANA timezone"),
    ));
  }
  if ends_on < starts_on {
    return Err(ApiError::BadRequest(
      "event.invalid_dates",
      "the event cannot end before it starts".into(),
    ));
  }
  if (ends_on - starts_on).num_days() > 13 {
    return Err(ApiError::BadRequest(
      "event.invalid_dates",
      "an event can be at most 14 days long".into(),
    ));
  }
  Ok(())
}

pub async fn list(State(state): State<AppState>, auth: Auth) -> ApiResult<Json<Vec<EventSummary>>> {
  auth.require(Role::Admin)?;
  Ok(Json(events::list(&state.pool).await?))
}

/// Public: the login page and displays need the active event before anyone logs in.
pub async fn active(State(state): State<AppState>) -> ApiResult<Json<Option<EventSummary>>> {
  Ok(Json(events::active(&state.pool).await?))
}

pub async fn create(
  State(state): State<AppState>,
  auth: Auth,
  Json(mut req): Json<CreateEventRequest>,
) -> ApiResult<Json<EventSummary>> {
  auth.require(Role::Admin)?;
  req.code = req.code.trim().to_ascii_uppercase();
  req.name = req.name.trim().to_owned();
  req.timezone = req.timezone.trim().to_owned();
  check_common(&req.season_id, &req.timezone, req.starts_on, req.ends_on)?;

  let mut tx = state.pool.begin().await?;
  let event = events::insert(&mut *tx, &req).await.map_err(|e| match e {
    sqlx::Error::Database(db) if db.is_check_violation() => ApiError::BadRequest(
      "event.invalid",
      "code must be 3-32 of A-Z, 0-9 or '-', and name 1-200 characters".into(),
    ),
    e => e.into(),
  })?;
  awards::insert_required(&mut tx, event.id).await?;
  audit(
    &mut *tx,
    &auth,
    Some(event.id),
    "event.create",
    ("event", Some(event.id)),
    serde_json::to_value(&req).unwrap_or_default(),
  )
  .await?;
  tx.commit().await?;
  Ok(Json(event))
}

pub async fn update(
  State(state): State<AppState>,
  auth: Auth,
  Path(id): Path<Uuid>,
  Json(mut req): Json<UpdateEventRequest>,
) -> ApiResult<Json<EventSummary>> {
  auth.require(Role::Admin)?;
  req.name = required(&req.name, "Event name", 200)?;
  req.timezone = req.timezone.trim().to_owned();
  check_common(&req.season_id, &req.timezone, req.starts_on, req.ends_on)?;
  let problems = req.settings.problems();
  if !problems.is_empty() {
    return Err(ApiError::Invalid(
      "event.invalid_settings",
      "Some settings are out of range.".into(),
      problems,
    ));
  }

  let mut tx = state.pool.begin().await?;
  let event = events::update(&mut *tx, id, &req)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  audit(
    &mut *tx,
    &auth,
    Some(id),
    "event.update",
    ("event", Some(id)),
    serde_json::to_value(&req).unwrap_or_default(),
  )
  .await?;
  tx.commit().await?;
  if is_active(&state, id).await? {
    state.bus.upsert(Topic::Event, TopicItem::Event(event.clone()));
    state.bus.resnapshot(Topic::Deliberation);
  }
  state
    .issues
    .refresh_all(&state.pool, id, is_active(&state, id).await?)
    .await?;
  Ok(Json(event))
}

pub async fn activate(
  State(state): State<AppState>,
  auth: Auth,
  Path(id): Path<Uuid>,
) -> ApiResult<Json<EventSummary>> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  let event = events::activate(&mut tx, id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  audit(
    &mut *tx,
    &auth,
    Some(id),
    "event.activate",
    ("event", Some(id)),
    serde_json::json!({}),
  )
  .await?;
  tx.commit().await?;

  // Every topic now refers to a different event.
  for topic in Topic::ALL {
    state.bus.resnapshot(topic);
  }
  Ok(Json(event))
}

/// Archiving ends the event: it stops being active, and every access key for it is revoked (devices are logged
/// out and offline scoresheets for it are refused from then on).
pub async fn archive(State(state): State<AppState>, auth: Auth, Path(id): Path<Uuid>) -> ApiResult<Json<EventSummary>> {
  auth.require(Role::Admin)?;
  let was_active = is_active(&state, id).await?;
  let mut tx = state.pool.begin().await?;
  let event = events::archive(&mut *tx, id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  let revoked = keys::revoke_all(&mut *tx, id).await?;
  audit(
    &mut *tx,
    &auth,
    Some(id),
    "event.archive",
    ("event", Some(id)),
    serde_json::json!({ "keys_revoked": revoked.len() }),
  )
  .await?;
  tx.commit().await?;

  for key_id in revoked {
    state.auth.apply(Revocation::Key(key_id));
  }
  if was_active {
    for topic in Topic::ALL {
      state.bus.resnapshot(topic);
    }
  }
  debug_assert_eq!(event.status, EventStatus::Archived);
  Ok(Json(event))
}
