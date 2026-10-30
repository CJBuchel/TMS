//! Match control, the match timer, and rankings.

use axum::Json;
use axum::extract::{Path, State};
use sqlx::PgPool;
use tms_core::game::{MatchAction, MatchTimer, RankingRow, StageRequest, TimerStartRequest};
use tms_core::model::GameMatch;
use tms_core::ws::TopicItem;
use tms_core::{Role, Topic};
use uuid::Uuid;

use super::support::{audit, is_active, publish_upsert};
use crate::AppState;
use crate::auth::Auth;
use crate::error::{ApiError, ApiResult};
use crate::repo::{events, game, queue, schedule, scoresheets, teams};
use crate::timer;

/// Puts a match on deck for the next timer start.
pub async fn stage(
  State(state): State<AppState>,
  auth: Auth,
  Path(id): Path<Uuid>,
  body: Option<Json<Option<StageRequest>>>,
) -> ApiResult<Json<GameMatch>> {
  auth.require(Role::HeadReferee)?;
  let request = body.and_then(|Json(b)| b).unwrap_or_default();
  if request.force && request.reason.trim().is_empty() {
    return Err(ApiError::BadRequest(
      "match.force_reason",
      "give a reason for staging anyway".into(),
    ));
  }
  let clashes = game::table_clashes(&state.pool, id).await?;
  if !clashes.is_empty() {
    return Err(ApiError::Conflict(
      "match.table_in_use",
      format!("{} is already staged on the same tables", clashes.join(", ")),
    ));
  }
  let unscored = game::unscored_before(&state.pool, id).await?;
  if !unscored.is_empty() && !request.force {
    return Err(ApiError::Conflict(
      "match.unscored_tables",
      format!(
        "{} on the same tables still needs scoresheets. Stage anyway with a reason, or wait for the sheets.",
        unscored.join(", ")
      ),
    ));
  }
  let data = serde_json::json!({ "force": request.force, "reason": request.reason, "unscored": unscored });
  transition(&state, &auth, id, MatchAction::Stage, data).await
}

pub async fn unstage(State(state): State<AppState>, auth: Auth, Path(id): Path<Uuid>) -> ApiResult<Json<GameMatch>> {
  auth.require(Role::HeadReferee)?;
  transition(&state, &auth, id, MatchAction::Unstage, serde_json::Value::Null).await
}

pub async fn cancel(State(state): State<AppState>, auth: Auth, Path(id): Path<Uuid>) -> ApiResult<Json<GameMatch>> {
  auth.require(Role::HeadReferee)?;
  transition(&state, &auth, id, MatchAction::Cancel, serde_json::Value::Null).await
}

/// Back to scheduled, to replay a finished match or restore a cancelled one. Its scoresheets stay.
pub async fn reset(State(state): State<AppState>, auth: Auth, Path(id): Path<Uuid>) -> ApiResult<Json<GameMatch>> {
  auth.require(Role::HeadReferee)?;
  transition(&state, &auth, id, MatchAction::Reset, serde_json::Value::Null).await
}

/// Applies one action from the match state machine and pushes the change.
async fn transition(
  state: &AppState,
  auth: &Auth,
  id: Uuid,
  action: MatchAction,
  data: serde_json::Value,
) -> ApiResult<Json<GameMatch>> {
  let mut tx = state.pool.begin().await?;
  let row = game::lock_match(&mut tx, id)
    .await?
    .ok_or(ApiError::NotFound("match"))?;
  let next = row
    .state
    .apply(action)
    .map_err(|e| ApiError::Conflict("match.invalid_state", e.to_string()))?;
  game::set_state(&mut tx, id, next).await?;
  if action == MatchAction::Reset {
    queue::reset_match(&mut tx, id, &auth.actor()).await?;
  }
  audit(
    &mut *tx,
    auth,
    Some(row.event_id),
    &format!("match.{}", action.past_tense()),
    ("match", Some(id)),
    data,
  )
  .await?;
  tx.commit().await?;
  let m = load_match(state, row.event_id, id).await?;
  publish_upsert(state, row.event_id, Topic::Matches, TopicItem::Match(m.clone())).await?;
  if matches!(action, MatchAction::Cancel | MatchAction::Reset) {
    // A cancelled match doesn't count in the schedule checks.
    let teams = m.slots.iter().filter_map(|s| s.team_id).collect();
    let active = is_active(state, row.event_id).await?;
    state
      .issues
      .refresh_teams(&state.pool, row.event_id, &teams, active)
      .await?;
  }
  Ok(Json(m))
}

pub async fn load_match(state: &AppState, event_id: Uuid, id: Uuid) -> ApiResult<GameMatch> {
  let mut conn = state.pool.acquire().await?;
  schedule::matches_by_id(&mut conn, event_id, &[id])
    .await?
    .into_iter()
    .next()
    .ok_or(ApiError::NotFound("match"))
}

pub async fn get_timer(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<MatchTimer>> {
  auth.require(Role::Display)?;
  Ok(Json(timer::current(&state, event_id).await?))
}

pub async fn start_timer(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
  body: Option<Json<Option<TimerStartRequest>>>,
) -> ApiResult<Json<MatchTimer>> {
  timer::may_run(&auth)?;
  let request = body.and_then(|Json(b)| b).unwrap_or_default();
  Ok(Json(timer::start(&state, &auth, event_id, &request).await?))
}

pub async fn abort_timer(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<MatchTimer>> {
  auth.require(Role::HeadReferee)?;
  Ok(Json(timer::abort(&state, &auth, event_id).await?))
}

pub async fn end_timer(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<MatchTimer>> {
  auth.require(Role::HeadReferee)?;
  Ok(Json(timer::end(&state, &auth, event_id).await?))
}

pub async fn get_rankings(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Vec<RankingRow>>> {
  auth.require(Role::Display)?;
  Ok(Json(rankings(&state.pool, event_id).await?))
}

/// The robot game ranking, computed from published ranking-round scoresheets.
pub async fn rankings(pool: &PgPool, event_id: Uuid) -> sqlx::Result<Vec<RankingRow>> {
  let Some(event) = events::get(pool, event_id).await? else {
    return Ok(Vec::new());
  };
  let team_ids: Vec<Uuid> = teams::list(pool, event_id).await?.into_iter().map(|t| t.id).collect();
  let results = scoresheets::ranking_results(pool, event_id).await?;
  Ok(tms_core::game::rank(&team_ids, event.settings.ranking_rounds, &results))
}

/// Tells subscribers to reload the ranking, and the scores deliberation goes by, after a scoresheet change.
pub async fn publish_rankings(state: &AppState, event_id: Uuid) -> ApiResult<()> {
  if is_active(state, event_id).await? {
    state.bus.resnapshot(Topic::Rankings);
    state.bus.resnapshot(Topic::Deliberation);
  }
  Ok(())
}
