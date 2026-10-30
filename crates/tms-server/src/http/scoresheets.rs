//! Scoresheets: referees' devices send them in batches; head referees review them.

use axum::Json;
use axum::extract::{Path, State};
use tms_core::dto::{EventStatus, Principal};
use tms_core::game::{
  ReviewRequest, Scoresheet, ScoresheetDoc, ScoresheetFlag, ScoresheetStatus, SyncOutcome, SyncResult,
  SyncScoresheetsRequest, SyncScoresheetsResponse,
};
use tms_core::model::{MatchKind, ScoresheetReview};
use tms_core::ws::TopicItem;
use tms_core::{Role, Topic};
use tms_seasons::Severity;
use uuid::Uuid;

use super::game::{load_match, publish_rankings};
use super::support::{audit, publish_upsert};
use crate::AppState;
use crate::auth::Auth;
use crate::error::{ApiError, ApiResult};
use crate::repo::{events, scoresheets};

const MAX_BATCH: usize = 50;

pub async fn sync(
  State(state): State<AppState>,
  auth: Auth,
  Json(request): Json<SyncScoresheetsRequest>,
) -> ApiResult<Json<SyncScoresheetsResponse>> {
  auth.require(Role::Referee)?;
  if request.documents.len() > MAX_BATCH {
    return Err(ApiError::BadRequest(
      "sync.too_many",
      format!("send at most {MAX_BATCH} scoresheets at a time"),
    ));
  }
  let mut results = Vec::with_capacity(request.documents.len());
  for doc in &request.documents {
    let outcome = receive(&state, &auth, doc).await?;
    results.push(SyncResult { id: doc.id, outcome });
  }
  Ok(Json(SyncScoresheetsResponse { results }))
}

fn rejected(code: &str, message: impl Into<String>) -> SyncOutcome {
  SyncOutcome::Rejected {
    code: code.to_owned(),
    message: message.into(),
    issues: Vec::new(),
  }
}

/// Checks one sheet against the event, season and schedule, scores it, and stores it.
async fn receive(state: &AppState, auth: &Auth, doc: &ScoresheetDoc) -> ApiResult<SyncOutcome> {
  if let Some(status) = scoresheets::status_of(&state.pool, doc.id).await? {
    return Ok(SyncOutcome::Duplicate { status });
  }
  let event = match events::get(&state.pool, doc.event_id).await? {
    Some(e) if e.status == EventStatus::Active => e,
    _ => {
      return Ok(rejected(
        "scoresheet.wrong_event",
        format!(
          "This sheet is for event {}, which is not running on this server.",
          doc.event_code
        ),
      ));
    }
  };
  if let Principal::Key { event_id, .. } = &auth.identity.principal
    && *event_id != event.id
  {
    return Ok(rejected(
      "scoresheet.wrong_event",
      "This device's access key belongs to another event.",
    ));
  }
  let Some(season) = tms_seasons::by_id(&event.season_id).filter(|s| s.id == doc.season_id) else {
    return Ok(rejected(
      "scoresheet.wrong_season",
      format!(
        "This sheet is for season {}, but the event plays {}.",
        doc.season_id, event.season_id
      ),
    ));
  };
  if doc.schema_version != season.schema_version {
    return Ok(rejected(
      "scoresheet.old_form",
      "This sheet was made with a different version of the scoresheet. Reload the page and score it again.",
    ));
  }

  let number = doc.team_number.trim();
  let Some(team_id) = scoresheets::team_by_number(&state.pool, event.id, number).await? else {
    return Ok(SyncOutcome::NeedsBinding {
      reason: format!("There is no team {number} at this event."),
    });
  };
  let (kind, round, match_id, table_id) = if let Some(slot_id) = doc.slot_id {
    let Some(slot) = scoresheets::slot_binding(&state.pool, slot_id)
      .await?
      .filter(|s| s.event_id == event.id)
    else {
      return Ok(SyncOutcome::NeedsBinding {
        reason: "The match this sheet was for is no longer in the schedule.".into(),
      });
    };
    if slot.team_id != Some(team_id) {
      return Ok(SyncOutcome::NeedsBinding {
        reason: format!("Team {number} is not scheduled in this match slot."),
      });
    }
    let Some(round) = slot.round.or(doc.round) else {
      return Ok(SyncOutcome::NeedsBinding {
        reason: "Choose which round this sheet is for.".into(),
      });
    };
    (slot.kind, round, Some(slot.match_id), Some(slot.table_id))
  } else {
    let Some(round) = doc.round.filter(|r| *r > 0) else {
      return Ok(SyncOutcome::NeedsBinding {
        reason: "Choose which round this sheet is for.".into(),
      });
    };
    (doc.kind, round, None, doc.table_id)
  };

  let checked = doc.check(season, &event.settings);
  if checked.has_errors() {
    return Ok(SyncOutcome::Rejected {
      code: "scoresheet.invalid".into(),
      message: "The scoresheet has errors.".into(),
      issues: checked.issues,
    });
  }
  let warnings: Vec<_> = checked
    .issues
    .into_iter()
    .filter(|i| i.severity == Severity::Warning)
    .collect();

  let mut tx = state.pool.begin().await?;
  // One sheet per team at a time, so two sheets for the same round can't both be published.
  scoresheets::lock_team(&mut tx, team_id).await?;
  let mut flags = Vec::new();
  if !warnings.is_empty() {
    flags.push(ScoresheetFlag::Warnings);
  }
  if doc.score != checked.total {
    flags.push(ScoresheetFlag::ScoreRecomputed);
  }
  if scoresheets::published_for_round(&mut tx, team_id, kind, round, doc.id)
    .await?
    .is_some()
  {
    flags.push(ScoresheetFlag::DuplicateRound);
  }
  let status = if event.settings.scoresheet_review == ScoresheetReview::AutoPublish && flags.is_empty() {
    ScoresheetStatus::Published
  } else {
    ScoresheetStatus::Submitted
  };
  let (user, key) = match &auth.identity.principal {
    Principal::User { user_id, .. } => (Some(*user_id), None),
    Principal::Key { key_id, .. } => (None, Some(*key_id)),
  };
  let stored = scoresheets::insert(
    &mut tx,
    scoresheets::NewSheet {
      id: doc.id,
      event_id: event.id,
      event_code: &doc.event_code,
      season_id: &doc.season_id,
      schema_version: doc.schema_version.into(),
      team_id,
      kind,
      round,
      match_id,
      slot_id: doc.slot_id,
      table_id,
      submitted_by_user: user,
      submitted_by_key: key,
      submitted_by: &auth.actor(),
      referee_name: doc.referee_name.trim(),
      status,
      flags: flags.iter().map(|f| f.key().to_owned()).collect(),
      no_show: doc.no_show,
      score: checked.total.into(),
      gp: if doc.no_show { None } else { doc.gp.map(i16::from) },
      gp_comment: doc.gp_comment.trim(),
      answers: &doc.answers,
      issues: &warnings,
      team_agreed: doc.team_agreed,
      team_initials: doc.team_initials.trim(),
      private_comment: doc.private_comment.trim(),
      created_at: doc.created_at,
    },
  )
  .await?;
  if !stored {
    return Ok(SyncOutcome::Duplicate {
      status: scoresheets::status_of(&mut *tx, doc.id)
        .await?
        .unwrap_or(ScoresheetStatus::Submitted),
    });
  }
  audit(
    &mut *tx,
    auth,
    Some(event.id),
    "scoresheet.submit",
    ("scoresheet", Some(doc.id)),
    serde_json::json!({ "team": number, "kind": kind, "round": round, "score": checked.total, "status": status }),
  )
  .await?;
  tx.commit().await?;
  publish_changes(state, event.id, &[doc.id], kind).await?;
  Ok(SyncOutcome::Accepted { status })
}

/// Pushes changed sheets, the matches whose slots show them, and the ranking.
async fn publish_changes(state: &AppState, event_id: Uuid, sheet_ids: &[Uuid], kind: MatchKind) -> ApiResult<()> {
  let mut match_ids = Vec::new();
  for id in sheet_ids {
    if let Some(sheet) = scoresheets::get(&state.pool, *id).await? {
      match_ids.extend(sheet.match_id);
      publish_upsert(
        state,
        event_id,
        Topic::Scoresheets,
        TopicItem::Scoresheet(Box::new(sheet)),
      )
      .await?;
    }
  }
  match_ids.dedup();
  for match_id in match_ids {
    let m = load_match(state, event_id, match_id).await?;
    publish_upsert(state, event_id, Topic::Matches, TopicItem::Match(m)).await?;
  }
  if kind == MatchKind::Ranking {
    publish_rankings(state, event_id).await?;
  }
  Ok(())
}

pub async fn list(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Vec<Scoresheet>>> {
  auth.require(Role::Referee)?;
  Ok(Json(scoresheets::list(&state.pool, event_id).await?))
}

pub async fn get(State(state): State<AppState>, auth: Auth, Path(id): Path<Uuid>) -> ApiResult<Json<Scoresheet>> {
  auth.require(Role::Referee)?;
  Ok(Json(
    scoresheets::get(&state.pool, id)
      .await?
      .ok_or(ApiError::NotFound("scoresheet"))?,
  ))
}

/// Publishes a sheet. A sheet already published for the same round is superseded.
pub async fn accept(State(state): State<AppState>, auth: Auth, Path(id): Path<Uuid>) -> ApiResult<Json<Scoresheet>> {
  review(&state, &auth, id, Review::Accept, String::new()).await
}

/// Takes a sheet out of the ranking. The note is shown to the referee.
pub async fn reject(
  State(state): State<AppState>,
  auth: Auth,
  Path(id): Path<Uuid>,
  Json(request): Json<ReviewRequest>,
) -> ApiResult<Json<Scoresheet>> {
  let note = request.note.trim().to_owned();
  if note.is_empty() {
    return Err(ApiError::BadRequest(
      "scoresheet.note_required",
      "say why the sheet is rejected, so the referee can fix it".into(),
    ));
  }
  review(&state, &auth, id, Review::Reject, note).await
}

/// Takes a published sheet back to waiting for review.
pub async fn unpublish(State(state): State<AppState>, auth: Auth, Path(id): Path<Uuid>) -> ApiResult<Json<Scoresheet>> {
  review(&state, &auth, id, Review::Unpublish, String::new()).await
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum Review {
  Accept,
  Reject,
  Unpublish,
}

async fn review(state: &AppState, auth: &Auth, id: Uuid, action: Review, note: String) -> ApiResult<Json<Scoresheet>> {
  auth.require(Role::HeadReferee)?;
  let sheet = scoresheets::get(&state.pool, id)
    .await?
    .ok_or(ApiError::NotFound("scoresheet"))?;
  let mut tx = state.pool.begin().await?;
  scoresheets::lock_team(&mut tx, sheet.team_id).await?;
  let current = scoresheets::lock(&mut tx, id)
    .await?
    .ok_or(ApiError::NotFound("scoresheet"))?;
  let (allowed, next, verb) = match action {
    Review::Accept => (
      current == ScoresheetStatus::Submitted,
      ScoresheetStatus::Published,
      "accepted",
    ),
    Review::Reject => (
      matches!(current, ScoresheetStatus::Submitted | ScoresheetStatus::Published),
      ScoresheetStatus::Rejected,
      "rejected",
    ),
    Review::Unpublish => (
      current == ScoresheetStatus::Published,
      ScoresheetStatus::Submitted,
      "unpublished",
    ),
  };
  if !allowed {
    return Err(ApiError::Conflict(
      "scoresheet.invalid_state",
      format!("a sheet that is {} can't be {verb}", current.label().to_lowercase()),
    ));
  }
  let mut changed = vec![id];
  if action == Review::Accept
    && let Some(previous) =
      scoresheets::published_for_round(&mut tx, sheet.team_id, sheet.kind, sheet.round, id).await?
  {
    scoresheets::set_status(
      &mut tx,
      previous,
      ScoresheetStatus::Superseded,
      None,
      Some(&auth.actor()),
    )
    .await?;
    changed.push(previous);
  }
  let note = (action == Review::Reject).then_some(note.as_str());
  scoresheets::set_status(&mut tx, id, next, note, Some(&auth.actor())).await?;
  audit(
    &mut *tx,
    auth,
    Some(sheet.event_id),
    &format!("scoresheet.{verb}"),
    ("scoresheet", Some(id)),
    serde_json::json!({ "team": sheet.team_number, "round": sheet.round, "note": note, "superseded": changed.get(1) }),
  )
  .await?;
  tx.commit().await?;
  publish_changes(state, sheet.event_id, &changed, sheet.kind).await?;
  Ok(Json(
    scoresheets::get(&state.pool, id)
      .await?
      .ok_or(ApiError::NotFound("scoresheet"))?,
  ))
}
