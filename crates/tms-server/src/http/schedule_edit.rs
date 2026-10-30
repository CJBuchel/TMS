//! Editing the schedule by hand: who plays in a slot, swapping two slots, moving a match or session. Each edit
//! runs the schedule checks for the teams it touches, before and after, and is refused if it adds an error unless
//! forced. Only matches that haven't started and slots without a scoresheet can change.

use std::collections::BTreeSet;

use axum::Json;
use axum::extract::{Path, State};
use chrono::{TimeZone, Utc};
use chrono_tz::Tz;
use tms_core::Role;
use tms_core::Topic;
use tms_core::dto::{MoveRequest, SlotAssignRequest, SlotSwapRequest, SwapOption};
use tms_core::model::{MatchState, QueueState};
use tms_core::validation::{IssueSeverity, Rules, ScheduleIssue, ScheduleView, new_errors, scoped_issues};
use uuid::Uuid;

use super::support::{audit, is_active};
use crate::AppState;
use crate::auth::Auth;
use crate::error::{ApiError, ApiResult};
use crate::issues::load_view;
use crate::repo::{events, judging, queue, schedule};

/// The checks for `teams` before and after; refuses new errors unless `force`. Returns the teams' issues after.
fn check(
  before: &ScheduleView,
  after: &ScheduleView,
  rules: &Rules,
  teams: &BTreeSet<Uuid>,
  force: bool,
) -> ApiResult<Vec<ScheduleIssue>> {
  let now = scoped_issues(after, rules, teams);
  let added = new_errors(&scoped_issues(before, rules, teams), &now);
  if !added.is_empty() && !force {
    return Err(ApiError::Invalid(
      "schedule.conflict",
      "This change makes the schedule unworkable.".into(),
      added.into_iter().map(|i| i.message).collect(),
    ));
  }
  Ok(
    now
      .into_iter()
      .filter(|i| i.team_id.is_some_and(|t| teams.contains(&t)) || involves(i, after, teams))
      .collect(),
  )
}

/// Event-wide issues involving the teams' matches or sessions.
fn involves(issue: &ScheduleIssue, view: &ScheduleView, teams: &BTreeSet<Uuid>) -> bool {
  issue.team_id.is_none() && !view.teams_in(&issue.refs).is_disjoint(teams)
}

/// Pushes the schedule again and re-checks the teams an edit touched.
async fn publish(state: &AppState, event_id: Uuid, teams: &BTreeSet<Uuid>) -> ApiResult<()> {
  let active = is_active(state, event_id).await?;
  if active {
    state.bus.resnapshot(Topic::Matches);
    state.bus.resnapshot(Topic::JudgingSessions);
  }
  state.issues.refresh_teams(&state.pool, event_id, teams, active).await?;
  Ok(())
}

fn not_started(view: &ScheduleView, match_id: Uuid) -> ApiResult<()> {
  match view.matches.iter().find(|m| m.id == match_id) {
    Some(m) if m.state == MatchState::Scheduled => Ok(()),
    Some(m) => Err(ApiError::Conflict(
      "match.invalid_state",
      format!("{} has already been staged or played, so it can't change.", m.label()),
    )),
    None => Err(ApiError::Conflict(
      "match.invalid_state",
      "A cancelled match can't change.".into(),
    )),
  }
}

/// The match slot's current team, refusing slots that have a scoresheet.
fn match_slot(view: &ScheduleView, slot_id: Uuid) -> ApiResult<(Uuid, Option<Uuid>)> {
  for m in &view.matches {
    if let Some(s) = m.slots.iter().find(|s| s.id == slot_id) {
      if s.sheet.is_some() {
        return Err(ApiError::Conflict(
          "slot.scored",
          format!("{} already has a scoresheet for this table.", m.label()),
        ));
      }
      return Ok((m.id, s.team_id));
    }
  }
  Err(ApiError::NotFound("slot"))
}

fn set_match_team(view: &mut ScheduleView, slot_id: Uuid, team: Option<Uuid>) {
  for s in view.matches.iter_mut().flat_map(|m| m.slots.iter_mut()) {
    if s.id == slot_id {
      s.team_id = team;
    }
  }
}

fn set_judging_team(view: &mut ScheduleView, slot_id: Uuid, team: Option<Uuid>) {
  for s in view.sessions.iter_mut().flat_map(|x| x.slots.iter_mut()) {
    if s.id == slot_id {
      s.team_id = team;
    }
  }
}

fn known_team(view: &ScheduleView, team: Option<Uuid>) -> ApiResult<()> {
  match team {
    Some(t) if !view.teams.iter().any(|(id, _)| *id == t) => Err(ApiError::NotFound("team")),
    _ => Ok(()),
  }
}

fn touched(teams: impl IntoIterator<Item = Option<Uuid>>) -> BTreeSet<Uuid> {
  teams.into_iter().flatten().collect()
}

pub async fn assign_match_slot(
  State(state): State<AppState>,
  auth: Auth,
  Path(slot_id): Path<Uuid>,
  Json(input): Json<SlotAssignRequest>,
) -> ApiResult<Json<Vec<ScheduleIssue>>> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  let slot = queue::lock_slot(&mut tx, slot_id)
    .await?
    .ok_or(ApiError::NotFound("slot"))?;
  let (view, rules) = load_view(&mut tx, slot.event_id).await?;
  let (match_id, old) = match_slot(&view, slot_id)?;
  not_started(&view, match_id)?;
  known_team(&view, input.team_id)?;
  let mut after = view.clone();
  set_match_team(&mut after, slot_id, input.team_id);
  let teams = touched([old, input.team_id]);
  let issues = check(&view, &after, &rules, &teams, input.force)?;
  schedule::set_match_slot_team(&mut tx, slot_id, input.team_id).await?;
  schedule::renumber_rounds(&mut tx, slot.event_id).await?;
  audit(
    &mut *tx,
    &auth,
    Some(slot.event_id),
    "schedule.slot_assign",
    ("match", Some(match_id)),
    serde_json::json!({ "slot_id": slot_id, "from": old, "to": input.team_id, "forced": input.force }),
  )
  .await?;
  tx.commit().await?;
  publish(&state, slot.event_id, &teams).await?;
  Ok(Json(issues))
}

pub async fn swap_match_slots(
  State(state): State<AppState>,
  auth: Auth,
  Json(input): Json<SlotSwapRequest>,
) -> ApiResult<Json<Vec<ScheduleIssue>>> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  let a = queue::lock_slot(&mut tx, input.a)
    .await?
    .ok_or(ApiError::NotFound("slot"))?;
  let b = queue::lock_slot(&mut tx, input.b)
    .await?
    .ok_or(ApiError::NotFound("slot"))?;
  if a.event_id != b.event_id {
    return Err(ApiError::NotFound("slot"));
  }
  let (view, rules) = load_view(&mut tx, a.event_id).await?;
  let (match_a, team_a) = match_slot(&view, input.a)?;
  let (match_b, team_b) = match_slot(&view, input.b)?;
  not_started(&view, match_a)?;
  not_started(&view, match_b)?;
  let mut after = view.clone();
  set_match_team(&mut after, input.a, team_b);
  set_match_team(&mut after, input.b, team_a);
  let teams = touched([team_a, team_b]);
  let issues = check(&view, &after, &rules, &teams, input.force)?;
  // A team appears once per match, so `b` is emptied first in case both slots are in one match.
  schedule::set_match_slot_team(&mut tx, input.b, None).await?;
  schedule::set_match_slot_team(&mut tx, input.a, team_b).await?;
  schedule::set_match_slot_team(&mut tx, input.b, team_a).await?;
  schedule::renumber_rounds(&mut tx, a.event_id).await?;
  audit(
    &mut *tx,
    &auth,
    Some(a.event_id),
    "schedule.slot_swap",
    ("match", Some(match_a)),
    serde_json::json!({ "a": input.a, "b": input.b, "forced": input.force }),
  )
  .await?;
  tx.commit().await?;
  publish(&state, a.event_id, &teams).await?;
  Ok(Json(issues))
}

/// Every slot this one could swap with, best first: the ones that add no errors, then by fewest warnings.
pub async fn swap_options(
  State(state): State<AppState>,
  auth: Auth,
  Path(slot_id): Path<Uuid>,
) -> ApiResult<Json<Vec<SwapOption>>> {
  auth.require(Role::Admin)?;
  let mut conn = state.pool.acquire().await?;
  let event_id = schedule::slot_event(&mut *conn, slot_id)
    .await?
    .ok_or(ApiError::NotFound("slot"))?;
  let (view, rules) = load_view(&mut conn, event_id).await?;
  let (match_id, team) = match_slot(&view, slot_id)?;
  not_started(&view, match_id)?;
  let kind = view.matches.iter().find(|m| m.id == match_id).map(|m| m.kind);
  let mut options = Vec::new();
  for m in view
    .matches
    .iter()
    .filter(|m| m.state == MatchState::Scheduled && Some(m.kind) == kind)
  {
    for other in m
      .slots
      .iter()
      .filter(|s| s.id != slot_id && s.sheet.is_none() && s.team_id != team)
    {
      let teams = touched([team, other.team_id]);
      let mut after = view.clone();
      set_match_team(&mut after, slot_id, other.team_id);
      set_match_team(&mut after, other.id, team);
      let before = scoped_issues(&view, &rules, &teams);
      let now = scoped_issues(&after, &rules, &teams);
      let warnings = |list: &[ScheduleIssue]| {
        i32::try_from(list.iter().filter(|i| i.severity == IssueSeverity::Warning).count()).unwrap_or(i32::MAX)
      };
      options.push(SwapOption {
        slot_id: other.id,
        match_id: m.id,
        label: m.label(),
        start: m.scheduled_start,
        team_id: other.team_id,
        new_errors: new_errors(&before, &now).into_iter().map(|i| i.message).collect(),
        warnings: warnings(&now) - warnings(&before),
      });
    }
  }
  options.sort_by_key(|o| (o.new_errors.len(), o.warnings, o.start));
  Ok(Json(options))
}

async fn timezone(state: &AppState, event_id: Uuid) -> ApiResult<Tz> {
  let event = events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  event
    .timezone
    .parse()
    .map_err(|_| ApiError::BadRequest("event.invalid_timezone", "the event's timezone is not valid".into()))
}

fn to_utc(tz: Tz, local: chrono::NaiveDateTime) -> ApiResult<chrono::DateTime<Utc>> {
  tz.from_local_datetime(&local)
    .earliest()
    .map(|t| t.with_timezone(&Utc))
    .ok_or_else(|| ApiError::BadRequest("schedule.invalid_time", format!("{local} does not exist in {tz}")))
}

pub async fn move_match(
  State(state): State<AppState>,
  auth: Auth,
  Path(match_id): Path<Uuid>,
  Json(input): Json<MoveRequest>,
) -> ApiResult<Json<Vec<ScheduleIssue>>> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  let current = crate::repo::game::lock_match(&mut tx, match_id)
    .await?
    .ok_or(ApiError::NotFound("match"))?;
  let tz = timezone(&state, current.event_id).await?;
  let (view, rules) = load_view(&mut tx, current.event_id).await?;
  not_started(&view, match_id)?;
  let m = view
    .matches
    .iter()
    .find(|m| m.id == match_id)
    .ok_or(ApiError::NotFound("match"))?;
  let start = to_utc(tz, input.start_local)?;
  let end = start + (m.scheduled_end - m.scheduled_start);
  let teams = touched(m.slots.iter().map(|s| s.team_id));
  let mut after = view.clone();
  if let Some(x) = after.matches.iter_mut().find(|x| x.id == match_id) {
    x.scheduled_start = start;
    x.scheduled_end = end;
  }
  let issues = check(&view, &after, &rules, &teams, input.force)?;
  schedule::move_match(&mut tx, match_id, start, end).await?;
  schedule::renumber_rounds(&mut tx, current.event_id).await?;
  audit(
    &mut *tx,
    &auth,
    Some(current.event_id),
    "schedule.match_move",
    ("match", Some(match_id)),
    serde_json::json!({ "from": m.scheduled_start, "to": start, "forced": input.force }),
  )
  .await?;
  tx.commit().await?;
  publish(&state, current.event_id, &teams).await?;
  Ok(Json(issues))
}

/// A judging slot's team, refusing slots whose session has started.
fn judging_slot_open(slot: &judging::SlotRow) -> ApiResult<()> {
  if matches!(slot.state, QueueState::Running | QueueState::Done) {
    return Err(ApiError::Conflict(
      "slot.started",
      "This judging session has already started, so it can't change.".into(),
    ));
  }
  Ok(())
}

pub async fn assign_judging_slot(
  State(state): State<AppState>,
  auth: Auth,
  Path(slot_id): Path<Uuid>,
  Json(input): Json<SlotAssignRequest>,
) -> ApiResult<Json<Vec<ScheduleIssue>>> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  let slot = judging::lock_slot(&mut tx, slot_id)
    .await?
    .ok_or(ApiError::NotFound("slot"))?;
  judging_slot_open(&slot)?;
  let (view, rules) = load_view(&mut tx, slot.event_id).await?;
  known_team(&view, input.team_id)?;
  let mut after = view.clone();
  set_judging_team(&mut after, slot_id, input.team_id);
  let teams = touched([slot.team_id, input.team_id]);
  let issues = check(&view, &after, &rules, &teams, input.force)?;
  schedule::set_judging_slot_team(&mut tx, slot_id, input.team_id).await?;
  audit(
    &mut *tx,
    &auth,
    Some(slot.event_id),
    "schedule.judging_assign",
    ("judging_session", Some(slot.session_id)),
    serde_json::json!({ "slot_id": slot_id, "from": slot.team_id, "to": input.team_id, "forced": input.force }),
  )
  .await?;
  tx.commit().await?;
  publish(&state, slot.event_id, &teams).await?;
  Ok(Json(issues))
}

pub async fn swap_judging_slots(
  State(state): State<AppState>,
  auth: Auth,
  Json(input): Json<SlotSwapRequest>,
) -> ApiResult<Json<Vec<ScheduleIssue>>> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  let a = judging::lock_slot(&mut tx, input.a)
    .await?
    .ok_or(ApiError::NotFound("slot"))?;
  let b = judging::lock_slot(&mut tx, input.b)
    .await?
    .ok_or(ApiError::NotFound("slot"))?;
  if a.event_id != b.event_id {
    return Err(ApiError::NotFound("slot"));
  }
  judging_slot_open(&a)?;
  judging_slot_open(&b)?;
  let (view, rules) = load_view(&mut tx, a.event_id).await?;
  let mut after = view.clone();
  set_judging_team(&mut after, input.a, b.team_id);
  set_judging_team(&mut after, input.b, a.team_id);
  let teams = touched([a.team_id, b.team_id]);
  let issues = check(&view, &after, &rules, &teams, input.force)?;
  schedule::set_judging_slot_team(&mut tx, input.b, None).await?;
  schedule::set_judging_slot_team(&mut tx, input.a, b.team_id).await?;
  schedule::set_judging_slot_team(&mut tx, input.b, a.team_id).await?;
  audit(
    &mut *tx,
    &auth,
    Some(a.event_id),
    "schedule.judging_swap",
    ("judging_session", Some(a.session_id)),
    serde_json::json!({ "a": input.a, "b": input.b, "forced": input.force }),
  )
  .await?;
  tx.commit().await?;
  publish(&state, a.event_id, &teams).await?;
  Ok(Json(issues))
}

pub async fn move_session(
  State(state): State<AppState>,
  auth: Auth,
  Path(session_id): Path<Uuid>,
  Json(input): Json<MoveRequest>,
) -> ApiResult<Json<Vec<ScheduleIssue>>> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  let event_id = schedule::lock_session(&mut tx, session_id)
    .await?
    .ok_or(ApiError::NotFound("session"))?;
  let tz = timezone(&state, event_id).await?;
  let (view, rules) = load_view(&mut tx, event_id).await?;
  let s = view
    .sessions
    .iter()
    .find(|s| s.id == session_id)
    .ok_or(ApiError::NotFound("session"))?;
  if s
    .slots
    .iter()
    .any(|x| matches!(x.queue, QueueState::Running | QueueState::Done))
  {
    return Err(ApiError::Conflict(
      "slot.started",
      "This judging session has already started, so it can't move.".into(),
    ));
  }
  let start = to_utc(tz, input.start_local)?;
  let end = start + (s.scheduled_end - s.scheduled_start);
  let teams = touched(s.slots.iter().map(|x| x.team_id));
  let mut after = view.clone();
  if let Some(x) = after.sessions.iter_mut().find(|x| x.id == session_id) {
    x.scheduled_start = start;
    x.scheduled_end = end;
  }
  let issues = check(&view, &after, &rules, &teams, input.force)?;
  schedule::move_session(&mut tx, session_id, start, end).await?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "schedule.session_move",
    ("judging_session", Some(session_id)),
    serde_json::json!({ "from": s.scheduled_start, "to": start, "forced": input.force }),
  )
  .await?;
  tx.commit().await?;
  publish(&state, event_id, &teams).await?;
  Ok(Json(issues))
}
