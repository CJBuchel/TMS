//! Awards: the event's award list, deliberation (allocation, advancement, finalize) and the awards ceremony.

use std::collections::HashMap;

use axum::Json;
use axum::extract::{Path, State};
use axum::http::StatusCode;
use sqlx::PgConnection;
use tms_core::deliberation::{
  AdvancementRequest, AssignRequest, Award, AwardKind, AwardPatch, AwardWinner, Ceremony, CeremonyAction,
  CeremonySlide, Deliberation, NewAward, Step, ceremony_slides,
};
use tms_core::dto::ReorderRequest;
use tms_core::{Role, Topic};
use uuid::Uuid;

use super::support::{audit, is_active, required};
use crate::AppState;
use crate::auth::Auth;
use crate::error::{ApiError, ApiResult};
use crate::repo::{awards, events, teams};

/// Tells subscribers to reload deliberation and the ceremony after anything they show changes.
pub async fn publish_deliberation(state: &AppState, event_id: Uuid) -> ApiResult<()> {
  if is_active(state, event_id).await? {
    state.bus.resnapshot(Topic::Deliberation);
    state.bus.resnapshot(Topic::Ceremony);
  }
  Ok(())
}

pub async fn load(db: &mut PgConnection, event_id: Uuid) -> ApiResult<Deliberation> {
  let event = events::get(&mut *db, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  Ok(awards::deliberation(db, event_id, event.settings.advancement_slots).await?)
}

async fn slides(db: &mut PgConnection, event_id: Uuid) -> ApiResult<Vec<CeremonySlide>> {
  let deliberation = load(&mut *db, event_id).await?;
  let names: HashMap<Uuid, (String, String)> = teams::list(&mut *db, event_id)
    .await?
    .into_iter()
    .map(|t| (t.id, (t.number, t.name)))
    .collect();
  Ok(ceremony_slides(&deliberation, |id| {
    names.get(&id).cloned().unwrap_or_default()
  }))
}

/// The ceremony as the venue screen sees it: nothing until deliberation is finalized, then only what has been
/// revealed.
pub async fn ceremony(db: &mut PgConnection, event_id: Uuid) -> ApiResult<Ceremony> {
  let state = awards::state(&mut *db, event_id).await?;
  let (total, slides) = if state.finalized.is_some() {
    let mut all = slides(&mut *db, event_id).await?;
    let total = u32::try_from(all.len()).unwrap_or(u32::MAX);
    all.truncate(state.ceremony_shown as usize);
    (total, all)
  } else {
    (0, Vec::new())
  };
  Ok(Ceremony {
    event_id,
    shown: u32::try_from(slides.len()).unwrap_or(0),
    total,
    slides,
  })
}

/// Refuses changes once deliberation is finalized.
fn not_finalized(state: &awards::State) -> ApiResult<()> {
  if state.finalized.is_some() {
    return Err(ApiError::Conflict(
      "deliberation.finalized",
      "Deliberation is finalized. An admin can reopen it.".into(),
    ));
  }
  Ok(())
}

pub async fn list(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Vec<Award>>> {
  auth.require(Role::Display)?;
  Ok(Json(awards::list(&state.pool, event_id).await?))
}

fn check_places(kind: AwardKind, places: u8) -> ApiResult<()> {
  if places == 0 || places > kind.max_places() {
    return Err(ApiError::BadRequest(
      "award.places",
      format!("{} can have 1 to {} places.", kind.label(), kind.max_places()),
    ));
  }
  Ok(())
}

pub async fn create(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
  Json(input): Json<NewAward>,
) -> ApiResult<Json<Award>> {
  auth.require(Role::Admin)?;
  check_places(input.kind, input.places)?;
  let name = if input.kind == AwardKind::Local || !input.name.trim().is_empty() {
    required(&input.name, "Award name", 80)?
  } else {
    input.kind.label().to_owned()
  };
  events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  let mut tx = state.pool.begin().await?;
  not_finalized(&awards::lock(&mut tx, event_id).await?)?;
  let award = awards::insert(&mut *tx, event_id, input.kind, &name, input.places)
    .await
    .map_err(|e| match e {
      sqlx::Error::Database(db) if db.is_unique_violation() => ApiError::Conflict(
        "award.exists",
        format!("This event already has the {} award.", input.kind.label()),
      ),
      e => e.into(),
    })?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "award.create",
    ("award", Some(award.id)),
    serde_json::json!({ "kind": award.kind, "name": award.name, "places": award.places }),
  )
  .await?;
  tx.commit().await?;
  publish_deliberation(&state, event_id).await?;
  Ok(Json(award))
}

pub async fn update(
  State(state): State<AppState>,
  auth: Auth,
  Path(id): Path<Uuid>,
  Json(patch): Json<AwardPatch>,
) -> ApiResult<Json<Award>> {
  auth.require(Role::Admin)?;
  let current = awards::get(&state.pool, id).await?.ok_or(ApiError::NotFound("award"))?;
  let name = match &patch.name {
    Some(name) => required(name, "Award name", 80)?,
    None => current.name.clone(),
  };
  let places = patch.places.unwrap_or(current.places);
  check_places(current.kind, places)?;
  let mut tx = state.pool.begin().await?;
  not_finalized(&awards::lock(&mut tx, current.event_id).await?)?;
  let highest = awards::highest_place(&mut *tx, id).await?;
  if places < highest {
    return Err(ApiError::Conflict(
      "award.places_in_use",
      format!("Place {highest} already has a winner. Remove it first."),
    ));
  }
  let award = awards::update(&mut *tx, id, &name, places)
    .await?
    .ok_or(ApiError::NotFound("award"))?;
  audit(
    &mut *tx,
    &auth,
    Some(award.event_id),
    "award.update",
    ("award", Some(id)),
    serde_json::json!({ "name": award.name, "places": award.places }),
  )
  .await?;
  tx.commit().await?;
  publish_deliberation(&state, award.event_id).await?;
  Ok(Json(award))
}

pub async fn delete(State(state): State<AppState>, auth: Auth, Path(id): Path<Uuid>) -> ApiResult<StatusCode> {
  auth.require(Role::Admin)?;
  let award = awards::get(&state.pool, id).await?.ok_or(ApiError::NotFound("award"))?;
  if award.kind.required() {
    return Err(ApiError::Conflict(
      "award.required",
      format!("Every event presents the {} award.", award.kind.label()),
    ));
  }
  let mut tx = state.pool.begin().await?;
  not_finalized(&awards::lock(&mut tx, award.event_id).await?)?;
  if awards::highest_place(&mut *tx, id).await? > 0 {
    return Err(ApiError::Conflict(
      "award.has_winners",
      "This award has winners. Remove them first.".into(),
    ));
  }
  awards::delete(&mut *tx, id).await?;
  audit(
    &mut *tx,
    &auth,
    Some(award.event_id),
    "award.delete",
    ("award", Some(id)),
    serde_json::json!({ "name": award.name }),
  )
  .await?;
  tx.commit().await?;
  publish_deliberation(&state, award.event_id).await?;
  Ok(StatusCode::NO_CONTENT)
}

/// Sets the ceremony order.
pub async fn reorder(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
  Json(input): Json<ReorderRequest>,
) -> ApiResult<Json<Vec<Award>>> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  awards::reorder(&mut tx, event_id, &input.ids).await?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "award.reorder",
    ("event", Some(event_id)),
    serde_json::json!({ "ids": input.ids }),
  )
  .await?;
  tx.commit().await?;
  publish_deliberation(&state, event_id).await?;
  Ok(Json(awards::list(&state.pool, event_id).await?))
}

pub async fn deliberation(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Deliberation>> {
  auth.require(Role::JudgeAdvisor)?;
  let mut conn = state.pool.acquire().await?;
  Ok(Json(load(&mut conn, event_id).await?))
}

/// Gives a place of an award to a team. The team must be eligible, and choosing anyone but the best-ranked
/// eligible team needs a note saying why.
pub async fn assign(
  State(state): State<AppState>,
  auth: Auth,
  Path(award_id): Path<Uuid>,
  Json(input): Json<AssignRequest>,
) -> ApiResult<Json<Deliberation>> {
  auth.require(Role::JudgeAdvisor)?;
  let award = awards::get(&state.pool, award_id)
    .await?
    .ok_or(ApiError::NotFound("award"))?;
  if input.place == 0 || input.place > award.places {
    return Err(ApiError::BadRequest(
      "award.places",
      format!("{} has {} place(s).", award.name, award.places),
    ));
  }
  let team = teams::get(&state.pool, input.team_id)
    .await?
    .filter(|t| t.event_id == award.event_id)
    .ok_or(ApiError::NotFound("team"))?;
  let mut tx = state.pool.begin().await?;
  not_finalized(&awards::lock(&mut tx, award.event_id).await?)?;
  let current = load(&mut tx, award.event_id).await?;
  let step = Step::Award {
    award_id,
    place: input.place,
  };
  if current.winner(award_id, input.place).is_some() {
    return Err(ApiError::Conflict(
      "award.place_taken",
      format!("{} already has a winner. Remove it first.", current.step_title(step)),
    ));
  }
  if let Some(reason) = current.ineligible(step, team.id) {
    return Err(ApiError::Conflict(
      "award.ineligible",
      format!(
        "Team {} can't take {}: {reason}.",
        team.number,
        current.step_title(step)
      ),
    ));
  }
  let note = input.note.trim().to_owned();
  if let Some(top) = current.top_candidate(step)
    && top != team.id
    && note.is_empty()
  {
    let top_number = teams::get(&mut *tx, top).await?.map(|t| t.number).unwrap_or_default();
    return Err(ApiError::BadRequest(
      "award.note_required",
      format!("Team {top_number} is the best-ranked eligible team. Say why this award goes to another team."),
    ));
  }
  awards::assign(
    &mut tx,
    award_id,
    &AwardWinner {
      award_id,
      team_id: team.id,
      place: input.place,
      note: note.clone(),
      assigned_by: auth.actor(),
    },
  )
  .await?;
  audit(
    &mut *tx,
    &auth,
    Some(award.event_id),
    "award.assign",
    ("award", Some(award_id)),
    serde_json::json!({ "team": team.number, "place": input.place, "note": note }),
  )
  .await?;
  let updated = load(&mut tx, award.event_id).await?;
  tx.commit().await?;
  publish_deliberation(&state, award.event_id).await?;
  Ok(Json(updated))
}

pub async fn unassign(
  State(state): State<AppState>,
  auth: Auth,
  Path((award_id, place)): Path<(Uuid, u8)>,
) -> ApiResult<Json<Deliberation>> {
  auth.require(Role::JudgeAdvisor)?;
  let award = awards::get(&state.pool, award_id)
    .await?
    .ok_or(ApiError::NotFound("award"))?;
  let mut tx = state.pool.begin().await?;
  not_finalized(&awards::lock(&mut tx, award.event_id).await?)?;
  let team_id = awards::unassign(&mut tx, award_id, place)
    .await?
    .ok_or(ApiError::NotFound("winner"))?;
  audit(
    &mut *tx,
    &auth,
    Some(award.event_id),
    "award.unassign",
    ("award", Some(award_id)),
    serde_json::json!({ "team_id": team_id, "place": place }),
  )
  .await?;
  let updated = load(&mut tx, award.event_id).await?;
  tx.commit().await?;
  publish_deliberation(&state, award.event_id).await?;
  Ok(Json(updated))
}

/// Replaces the list of advancing teams.
pub async fn advancement(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
  Json(input): Json<AdvancementRequest>,
) -> ApiResult<Json<Deliberation>> {
  auth.require(Role::JudgeAdvisor)?;
  let event = events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  if input.team_ids.len() > event.settings.advancement_slots as usize {
    return Err(ApiError::BadRequest(
      "advancement.too_many",
      format!("{} team(s) advance from this event.", event.settings.advancement_slots),
    ));
  }
  let mut ids = input.team_ids.clone();
  ids.sort_unstable();
  ids.dedup();
  if ids.len() != input.team_ids.len() {
    return Err(ApiError::BadRequest(
      "advancement.duplicate",
      "A team is listed twice.".into(),
    ));
  }
  let event_teams: Vec<Uuid> = teams::list(&state.pool, event_id)
    .await?
    .into_iter()
    .map(|t| t.id)
    .collect();
  if input.team_ids.iter().any(|id| !event_teams.contains(id)) {
    return Err(ApiError::NotFound("team"));
  }
  let mut tx = state.pool.begin().await?;
  not_finalized(&awards::lock(&mut tx, event_id).await?)?;
  awards::set_advancing(&mut tx, event_id, &input.team_ids).await?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "advancement.set",
    ("event", Some(event_id)),
    serde_json::json!({ "team_ids": input.team_ids }),
  )
  .await?;
  let updated = load(&mut tx, event_id).await?;
  tx.commit().await?;
  publish_deliberation(&state, event_id).await?;
  Ok(Json(updated))
}

/// Locks rubrics, awards and advancement, and lets the ceremony start.
pub async fn finalize(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Deliberation>> {
  auth.require(Role::JudgeAdvisor)?;
  let mut tx = state.pool.begin().await?;
  not_finalized(&awards::lock(&mut tx, event_id).await?)?;
  awards::set_finalized(&mut tx, event_id, Some(&auth.actor())).await?;
  let updated = load(&mut tx, event_id).await?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "deliberation.finalize",
    ("event", Some(event_id)),
    serde_json::json!({ "open_required": updated.open_required(), "teams_awarded": updated.teams_awarded() }),
  )
  .await?;
  tx.commit().await?;
  publish_deliberation(&state, event_id).await?;
  Ok(Json(updated))
}

pub async fn reopen(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Deliberation>> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  awards::lock(&mut tx, event_id).await?;
  awards::set_finalized(&mut tx, event_id, None).await?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "deliberation.reopen",
    ("event", Some(event_id)),
    serde_json::json!({}),
  )
  .await?;
  let updated = load(&mut tx, event_id).await?;
  tx.commit().await?;
  publish_deliberation(&state, event_id).await?;
  Ok(Json(updated))
}

fn require_ceremony(auth: &Auth) -> ApiResult<()> {
  auth.require(Role::Emcee).or_else(|_| auth.require(Role::JudgeAdvisor))
}

/// Every slide, for whoever runs the ceremony.
pub async fn script(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Vec<CeremonySlide>>> {
  require_ceremony(&auth)?;
  let mut conn = state.pool.acquire().await?;
  Ok(Json(slides(&mut conn, event_id).await?))
}

pub async fn ceremony_action(
  State(state): State<AppState>,
  auth: Auth,
  Path((event_id, action)): Path<(Uuid, CeremonyAction)>,
) -> ApiResult<Json<Ceremony>> {
  require_ceremony(&auth)?;
  let mut tx = state.pool.begin().await?;
  let current = awards::lock(&mut tx, event_id).await?;
  if current.finalized.is_none() {
    return Err(ApiError::Conflict(
      "ceremony.not_finalized",
      "The ceremony starts once the judge advisor finalizes deliberation.".into(),
    ));
  }
  let total = u32::try_from(slides(&mut tx, event_id).await?.len()).unwrap_or(0);
  let shown = match action {
    CeremonyAction::Next => (current.ceremony_shown + 1).min(total),
    CeremonyAction::Previous => current.ceremony_shown.saturating_sub(1),
    CeremonyAction::Restart => 0,
  };
  awards::set_ceremony_shown(&mut tx, event_id, shown).await?;
  let ceremony = ceremony(&mut tx, event_id).await?;
  tx.commit().await?;
  if is_active(&state, event_id).await? {
    state.bus.resnapshot(Topic::Ceremony);
  }
  Ok(Json(ceremony))
}
