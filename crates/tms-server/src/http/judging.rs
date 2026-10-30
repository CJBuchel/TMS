//! Judging: the judging queue, pod timers, rubrics and their review, and the judge advisor's scores.

use axum::Json;
use axum::extract::{Path, State};
use chrono::Utc;
use tms_core::deliberation::{TeamScores, team_scores};
use tms_core::dto::{EventStatus, Principal};
use tms_core::game::{ReviewRequest, SyncOutcome, SyncResult};
use tms_core::judging::{
  self as rules, PodTimer, PodTimerAction, PodTimerRequest, Rubric, RubricDoc, RubricStatus, SyncRubricsRequest,
  SyncRubricsResponse,
};
use tms_core::model::{JudgingSession, QueueState, RubricReview};
use tms_core::queue::{QueueError, QueueRequest};
use tms_core::ws::TopicItem;
use tms_core::{Role, Topic};
use tms_seasons::rubric;
use uuid::Uuid;

use super::awards::publish_deliberation;
use super::support::{audit, publish_upsert};
use crate::AppState;
use crate::auth::Auth;
use crate::error::{ApiError, ApiResult};
use crate::repo::{awards, events, judging, schedule, scoresheets};

async fn publish_sessions(state: &AppState, event_id: Uuid, ids: &[Uuid]) -> ApiResult<()> {
  let mut conn = state.pool.acquire().await?;
  for session in schedule::sessions_by_id(&mut conn, event_id, ids).await? {
    publish_upsert(
      state,
      event_id,
      Topic::JudgingSessions,
      TopicItem::JudgingSession(session),
    )
    .await?;
  }
  Ok(())
}

/// A judging queue action; returns the slot's session.
pub async fn queue(
  State(state): State<AppState>,
  auth: Auth,
  Path(id): Path<Uuid>,
  Json(request): Json<QueueRequest>,
) -> ApiResult<Json<JudgingSession>> {
  if auth.identity.must_change_password {
    return Err(ApiError::PasswordChangeRequired);
  }
  let mut tx = state.pool.begin().await?;
  let slot = judging::lock_slot(&mut tx, id)
    .await?
    .ok_or(ApiError::NotFound("slot"))?;
  if slot.team_id.is_none() {
    return Err(ApiError::Conflict(
      "queue.no_team",
      "no team is scheduled in this slot".into(),
    ));
  }
  let next = rules::judging_queue_allowed(request.action, &auth.identity.roles, slot.state)
    .and_then(|()| slot.state.apply(request.action, slot.previous))
    .map_err(|e| match e {
      QueueError::Forbidden { .. } => ApiError::Forbidden,
      QueueError::NotAllowed { .. } => ApiError::Conflict("queue.invalid_state", e.to_string()),
    })?;
  judging::change_queue(&mut tx, id, slot.state, next, &auth.actor()).await?;
  audit(
    &mut *tx,
    &auth,
    Some(slot.event_id),
    &format!("judging_slot.{}", request.action.key()),
    ("judging_slot", Some(id)),
    serde_json::json!({ "team": slot.team_id, "pod": slot.pod_id, "from": slot.state, "to": next }),
  )
  .await?;
  tx.commit().await?;
  publish_sessions(&state, slot.event_id, &[slot.session_id]).await?;
  let mut conn = state.pool.acquire().await?;
  let session = schedule::sessions_by_id(&mut conn, slot.event_id, &[slot.session_id])
    .await?
    .into_iter()
    .next()
    .ok_or(ApiError::NotFound("session"))?;
  Ok(Json(session))
}

pub async fn pod_timers(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Vec<PodTimer>>> {
  auth.require(Role::Display)?;
  Ok(Json(judging::timers(&state.pool, event_id).await?))
}

/// Start a session, move between phases, add a minute, or finish.
pub async fn pod_timer(
  State(state): State<AppState>,
  auth: Auth,
  Path((pod_id, action)): Path<(Uuid, PodTimerAction)>,
  body: Option<Json<Option<PodTimerRequest>>>,
) -> ApiResult<Json<PodTimer>> {
  auth.require(Role::Judge)?;
  let request = body.and_then(|Json(b)| b).unwrap_or_default();
  let event_id = judging::pod_event(&state.pool, pod_id)
    .await?
    .ok_or(ApiError::NotFound("pod"))?;
  if let Some(session_id) = request.session_id
    && judging::session_event(&state.pool, session_id).await? != Some(event_id)
  {
    return Err(ApiError::NotFound("session"));
  }
  let mut tx = state.pool.begin().await?;
  let current = judging::lock_timer(&mut tx, pod_id).await?;
  let next = rules::apply_pod_action(&current, action, request.session_id, Utc::now()).ok_or_else(|| {
    ApiError::Conflict(
      "pod_timer.invalid",
      match (action, current.phase) {
        (PodTimerAction::Start, Some(_)) => "this pod is already in a session".into(),
        (PodTimerAction::Start, None) => "choose the session to start".into(),
        _ => "no session is running in this pod".into(),
      },
    )
  })?;
  judging::save_timer(&mut tx, &next).await?;
  let mut touched = Vec::new();
  if action == PodTimerAction::Start
    && let Some(session_id) = next.session_id
  {
    judging::timer_moves_slot(
      &mut tx,
      session_id,
      pod_id,
      &QueueState::BEFORE_MATCH,
      QueueState::Running,
    )
    .await?;
    touched.push(session_id);
  }
  if next.phase.is_none()
    && let Some(session_id) = current.session_id
  {
    judging::timer_moves_slot(&mut tx, session_id, pod_id, &[QueueState::Running], QueueState::Done).await?;
    touched.push(session_id);
  }
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    &format!(
      "pod_timer.{}",
      serde_json::to_value(action)
        .ok()
        .and_then(|v| v.as_str().map(str::to_owned))
        .unwrap_or_default()
    ),
    ("pod", Some(pod_id)),
    serde_json::json!({ "session": next.session_id.or(current.session_id), "phase": next.phase }),
  )
  .await?;
  tx.commit().await?;
  publish_upsert(&state, event_id, Topic::PodTimers, TopicItem::PodTimer(next.clone())).await?;
  publish_sessions(&state, event_id, &touched).await?;
  Ok(Json(next))
}

pub async fn sync(
  State(state): State<AppState>,
  auth: Auth,
  Json(request): Json<SyncRubricsRequest>,
) -> ApiResult<Json<SyncRubricsResponse>> {
  auth.require(Role::Judge)?;
  if request.documents.len() > 50 {
    return Err(ApiError::BadRequest(
      "sync.too_many",
      "send at most 50 rubrics at a time".into(),
    ));
  }
  let mut results = Vec::new();
  for doc in &request.documents {
    results.push(SyncResult {
      id: doc.id,
      outcome: receive(&state, &auth, doc).await?,
    });
  }
  Ok(Json(SyncRubricsResponse { results }))
}

fn rejected(code: &str, message: impl Into<String>) -> SyncOutcome<RubricStatus> {
  SyncOutcome::Rejected {
    code: code.to_owned(),
    message: message.into(),
    issues: Vec::new(),
  }
}

async fn receive(state: &AppState, auth: &Auth, doc: &RubricDoc) -> ApiResult<SyncOutcome<RubricStatus>> {
  if let Some(status) = judging::status_of(&state.pool, doc.id).await? {
    return Ok(SyncOutcome::Duplicate { status });
  }
  let event = match events::get(&state.pool, doc.event_id).await? {
    Some(e) if e.status == EventStatus::Active => e,
    _ => {
      return Ok(rejected(
        "rubric.wrong_event",
        format!(
          "These rubrics are for event {}, which is not running on this server.",
          doc.event_code
        ),
      ));
    }
  };
  if let Principal::Key { event_id, .. } = &auth.identity.principal
    && *event_id != event.id
  {
    return Ok(rejected(
      "rubric.wrong_event",
      "This device's access key belongs to another event.",
    ));
  }
  if awards::is_finalized(&state.pool, event.id).await? {
    return Ok(rejected(
      "rubric.finalized",
      "Deliberation is finalized, so rubrics can no longer change. Talk to the judge advisor.",
    ));
  }
  let Some(season) = tms_seasons::by_id(&event.season_id).filter(|s| s.id == doc.season_id) else {
    return Ok(rejected("rubric.wrong_season", "These rubrics are for another season."));
  };
  if doc.schema_version != season.schema_version {
    return Ok(rejected(
      "rubric.old_form",
      "These rubrics were made with a different version of the form. Reload the page and fill them in again.",
    ));
  }
  let number = doc.team_number.trim();
  let Some(team_id) = scoresheets::team_by_number(&state.pool, event.id, number).await? else {
    return Ok(SyncOutcome::NeedsBinding {
      reason: format!("There is no team {number} at this event."),
    });
  };
  let mut session_id = None;
  if let Some(slot_id) = doc.slot_id {
    let mut tx = state.pool.begin().await?;
    let slot = judging::lock_slot(&mut tx, slot_id).await?;
    tx.rollback().await?;
    match slot {
      Some(slot) if slot.event_id == event.id && slot.team_id == Some(team_id) => session_id = Some(slot.session_id),
      _ => {
        return Ok(SyncOutcome::NeedsBinding {
          reason: format!("Team {number} is not scheduled in this judging slot."),
        });
      }
    }
  }
  let issues = doc.check(season);
  if !issues.is_empty() {
    return Ok(SyncOutcome::Rejected {
      code: "rubric.invalid".into(),
      message: "The rubrics have errors.".into(),
      issues,
    });
  }
  let totals = rubric::totals(season.rubrics, &doc.scores);

  let mut tx = state.pool.begin().await?;
  scoresheets::lock_team(&mut tx, team_id).await?;
  let duplicate = judging::accepted_for_team(&mut tx, team_id, doc.id).await?.is_some();
  let status = if event.settings.rubric_review == RubricReview::Auto && !duplicate {
    RubricStatus::Accepted
  } else {
    RubricStatus::Submitted
  };
  let (user, key) = match &auth.identity.principal {
    Principal::User { user_id, .. } => (Some(*user_id), None),
    Principal::Key { key_id, .. } => (None, Some(*key_id)),
  };
  let stored = judging::insert(
    &mut tx,
    judging::NewRubric {
      id: doc.id,
      event_id: event.id,
      event_code: &doc.event_code,
      season_id: &doc.season_id,
      schema_version: doc.schema_version.into(),
      team_id,
      slot_id: doc.slot_id,
      pod_id: doc.pod_id,
      judge_names: doc.judge_names.trim(),
      submitted_by_user: user,
      submitted_by_key: key,
      submitted_by: &auth.actor(),
      status,
      duplicate,
      scores: &doc.scores,
      exceeds_comments: &doc.exceeds_comments,
      feedback: &doc.feedback,
      nominations: &doc.nominations,
      totals,
      created_at: doc.created_at,
    },
  )
  .await?;
  if !stored {
    return Ok(SyncOutcome::Duplicate {
      status: judging::status_of(&mut *tx, doc.id)
        .await?
        .unwrap_or(RubricStatus::Submitted),
    });
  }
  audit(
    &mut *tx,
    auth,
    Some(event.id),
    "rubric.submit",
    ("rubric", Some(doc.id)),
    serde_json::json!({ "team": number, "status": status, "ip": totals.innovation_project, "rd": totals.robot_design }),
  )
  .await?;
  tx.commit().await?;
  publish_rubric(state, event.id, doc.id).await?;
  if let Some(session_id) = session_id {
    publish_sessions(state, event.id, &[session_id]).await?;
  }
  Ok(SyncOutcome::Accepted { status })
}

async fn publish_rubric(state: &AppState, event_id: Uuid, id: Uuid) -> ApiResult<()> {
  if let Some(rubric) = judging::get(&state.pool, id).await? {
    publish_upsert(state, event_id, Topic::Rubrics, TopicItem::Rubric(Box::new(rubric))).await?;
  }
  publish_deliberation(state, event_id).await
}

pub async fn list(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Vec<Rubric>>> {
  auth.require(Role::Judge)?;
  Ok(Json(judging::list(&state.pool, event_id).await?))
}

pub async fn get(State(state): State<AppState>, auth: Auth, Path(id): Path<Uuid>) -> ApiResult<Json<Rubric>> {
  auth.require(Role::Judge)?;
  Ok(Json(
    judging::get(&state.pool, id)
      .await?
      .ok_or(ApiError::NotFound("rubric"))?,
  ))
}

pub async fn accept(State(state): State<AppState>, auth: Auth, Path(id): Path<Uuid>) -> ApiResult<Json<Rubric>> {
  review(&state, &auth, id, true, String::new()).await
}

pub async fn reject(
  State(state): State<AppState>,
  auth: Auth,
  Path(id): Path<Uuid>,
  Json(request): Json<ReviewRequest>,
) -> ApiResult<Json<Rubric>> {
  let note = request.note.trim().to_owned();
  if note.is_empty() {
    return Err(ApiError::BadRequest(
      "rubric.note_required",
      "say why the rubrics are rejected, so the judges can fix them".into(),
    ));
  }
  review(&state, &auth, id, false, note).await
}

async fn review(state: &AppState, auth: &Auth, id: Uuid, accept: bool, note: String) -> ApiResult<Json<Rubric>> {
  auth.require(Role::JudgeAdvisor)?;
  let rubric = judging::get(&state.pool, id)
    .await?
    .ok_or(ApiError::NotFound("rubric"))?;
  let mut tx = state.pool.begin().await?;
  if awards::lock(&mut tx, rubric.event_id).await?.finalized.is_some() {
    return Err(ApiError::Conflict(
      "deliberation.finalized",
      "Deliberation is finalized. An admin can reopen it.".into(),
    ));
  }
  scoresheets::lock_team(&mut tx, rubric.team_id).await?;
  let current = judging::lock(&mut tx, id).await?.ok_or(ApiError::NotFound("rubric"))?;
  let allowed = if accept {
    current == RubricStatus::Submitted
  } else {
    matches!(current, RubricStatus::Submitted | RubricStatus::Accepted)
  };
  if !allowed {
    return Err(ApiError::Conflict(
      "rubric.invalid_state",
      format!(
        "rubrics that are {} can't be {}",
        current.label().to_lowercase(),
        if accept { "accepted" } else { "rejected" }
      ),
    ));
  }
  let mut changed = vec![id];
  if accept && let Some(previous) = judging::accepted_for_team(&mut tx, rubric.team_id, id).await? {
    judging::set_status(&mut tx, previous, RubricStatus::Superseded, None, &auth.actor()).await?;
    changed.push(previous);
  }
  let (status, note) = if accept {
    (RubricStatus::Accepted, None)
  } else {
    (RubricStatus::Rejected, Some(note.as_str()))
  };
  judging::set_status(&mut tx, id, status, note, &auth.actor()).await?;
  audit(
    &mut *tx,
    auth,
    Some(rubric.event_id),
    if accept { "rubric.accepted" } else { "rubric.rejected" },
    ("rubric", Some(id)),
    serde_json::json!({ "team": rubric.team_number, "note": note }),
  )
  .await?;
  tx.commit().await?;
  for changed_id in changed {
    publish_rubric(state, rubric.event_id, changed_id).await?;
  }
  let sessions: Vec<Uuid> = schedule::sessions(&mut *state.pool.acquire().await?, rubric.event_id)
    .await?
    .into_iter()
    .filter(|s| s.slots.iter().any(|slot| slot.team_id == Some(rubric.team_id)))
    .map(|s| s.id)
    .collect();
  publish_sessions(state, rubric.event_id, &sessions).await?;
  Ok(Json(
    judging::get(&state.pool, id)
      .await?
      .ok_or(ApiError::NotFound("rubric"))?,
  ))
}

/// Area scores, ranks and Champion's score for every team.
pub async fn scores(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Vec<TeamScores>>> {
  auth.require(Role::JudgeAdvisor)?;
  let mut conn = state.pool.acquire().await?;
  let inputs = judging::team_inputs(&mut conn, event_id).await?;
  Ok(Json(team_scores(&inputs)))
}
