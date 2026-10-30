use axum::Json;
use axum::extract::{Path, State};
use axum::http::StatusCode;
use tms_core::dto::TeamInput;
use tms_core::model::Team;
use tms_core::ws::TopicItem;
use tms_core::{Role, Topic};
use uuid::Uuid;

use super::support::{audit, optional, publish_delete, publish_upsert, required};
use crate::AppState;
use crate::auth::Auth;
use crate::error::{ApiError, ApiResult};
use crate::repo::{events, teams};

fn clean(input: &TeamInput) -> ApiResult<TeamInput> {
  Ok(TeamInput {
    number: required(&input.number, "Team number", 12)?,
    name: required(&input.name, "Team name", 120)?,
    affiliation: input.affiliation.trim().to_owned(),
    pit: optional(input.pit.as_deref(), "Pit", 40)?,
    notes: input.notes.trim().to_owned(),
  })
}

pub async fn list(State(state): State<AppState>, auth: Auth, Path(event_id): Path<Uuid>) -> ApiResult<Json<Vec<Team>>> {
  auth.require(Role::Display)?;
  Ok(Json(teams::list(&state.pool, event_id).await?))
}

pub async fn create(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
  Json(input): Json<TeamInput>,
) -> ApiResult<Json<Team>> {
  auth.require(Role::Admin)?;
  let input = clean(&input)?;
  events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  let mut tx = state.pool.begin().await?;
  let team = teams::insert(&mut *tx, event_id, &input)
    .await
    .map_err(|e| duplicate_number(e, &input.number))?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "team.create",
    ("team", Some(team.id)),
    serde_json::to_value(&input).unwrap_or_default(),
  )
  .await?;
  tx.commit().await?;
  publish_upsert(&state, event_id, Topic::Teams, TopicItem::Team(team.clone())).await?;
  recheck(&state, event_id, team.id).await?;
  Ok(Json(team))
}

pub async fn update(
  State(state): State<AppState>,
  auth: Auth,
  Path(id): Path<Uuid>,
  Json(input): Json<TeamInput>,
) -> ApiResult<Json<Team>> {
  auth.require(Role::Admin)?;
  let input = clean(&input)?;
  let mut tx = state.pool.begin().await?;
  let team = teams::update(&mut *tx, id, &input)
    .await
    .map_err(|e| duplicate_number(e, &input.number))?
    .ok_or(ApiError::NotFound("team"))?;
  audit(
    &mut *tx,
    &auth,
    Some(team.event_id),
    "team.update",
    ("team", Some(id)),
    serde_json::to_value(&input).unwrap_or_default(),
  )
  .await?;
  tx.commit().await?;
  publish_upsert(&state, team.event_id, Topic::Teams, TopicItem::Team(team.clone())).await?;
  recheck(&state, team.event_id, team.id).await?;
  Ok(Json(team))
}

/// Refused while the team is in the schedule: the database restricts it, and the error says why.
pub async fn delete(State(state): State<AppState>, auth: Auth, Path(id): Path<Uuid>) -> ApiResult<StatusCode> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  let event_id = teams::delete(&mut *tx, id)
    .await
    .map_err(|e| {
      in_use(
        e,
        "This team is in the schedule. Remove it from its matches and judging sessions first.",
      )
    })?
    .ok_or(ApiError::NotFound("team"))?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "team.delete",
    ("team", Some(id)),
    serde_json::json!({}),
  )
  .await?;
  tx.commit().await?;
  publish_delete(&state, event_id, Topic::Teams, id).await?;
  recheck(&state, event_id, id).await?;
  Ok(StatusCode::NO_CONTENT)
}

/// Re-runs the schedule checks for one team: a new team has no matches yet, a renamed one changes the messages.
async fn recheck(state: &AppState, event_id: Uuid, team_id: Uuid) -> ApiResult<()> {
  let active = super::support::is_active(state, event_id).await?;
  state
    .issues
    .refresh_teams(
      &state.pool,
      event_id,
      &std::collections::BTreeSet::from([team_id]),
      active,
    )
    .await?;
  Ok(())
}

fn duplicate_number(e: sqlx::Error, number: &str) -> ApiError {
  match ApiError::from(e) {
    ApiError::Conflict("conflict.duplicate", _) => ApiError::Conflict(
      "team.duplicate_number",
      format!("another team already has number {number}"),
    ),
    other => other,
  }
}

/// Turns a foreign-key refusal into a message about the specific thing in use.
pub fn in_use(e: sqlx::Error, message: &str) -> ApiError {
  match ApiError::from(e) {
    ApiError::Conflict("conflict.in_use", _) => ApiError::Conflict("conflict.in_use", message.to_owned()),
    other => other,
  }
}
