//! The schedule: matches, judging sessions, timetable blocks, and the Tournament-in-a-Box import.

use std::collections::{HashMap, HashSet};

use axum::Json;
use axum::extract::{Path, Query, State};
use axum::http::StatusCode;
use chrono::{TimeDelta, TimeZone};
use chrono_tz::Tz;
use serde::Deserialize;
use tms_core::dto::{BlockInput, GeneratePreview, GenerateRequest, ImportPreview, ProposedEntry};
use tms_core::model::{BlockKind, GameMatch, JudgingSession, ScheduleBlock};
use tms_core::validation::{Rules, ScheduleIssue, all_issues};
use tms_core::ws::TopicItem;
use tms_core::{Role, Topic};
use tms_schedule::ResolvedSchedule;
use uuid::Uuid;

use super::support::{audit, is_active, publish_delete, publish_upsert, required};
use crate::AppState;
use crate::auth::Auth;
use crate::error::{ApiError, ApiResult};
use crate::repo::{blocks, events, schedule, teams, venue};

pub async fn matches(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Vec<GameMatch>>> {
  auth.require(Role::Display)?;
  let mut conn = state.pool.acquire().await?;
  Ok(Json(schedule::matches(&mut conn, event_id).await?))
}

pub async fn sessions(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Vec<JudgingSession>>> {
  auth.require(Role::Display)?;
  let mut conn = state.pool.acquire().await?;
  Ok(Json(schedule::sessions(&mut conn, event_id).await?))
}

#[derive(Debug, Deserialize)]
pub struct ImportQuery {
  #[serde(default)]
  commit: bool,
}

/// Body: the CSV text. Without `?commit=true` nothing changes; the preview says what would.
/// A commit replaces every match and judging session, adds or updates teams by number, and adds missing
/// tables and pods. Teams, tables and pods the file does not mention are kept.
pub async fn import_tiab(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
  Query(query): Query<ImportQuery>,
  body: String,
) -> ApiResult<Json<ImportPreview>> {
  auth.require(Role::Admin)?;
  let event = events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  let timezone: Tz = event
    .timezone
    .parse()
    .map_err(|_| ApiError::BadRequest("event.invalid_timezone", "the event's timezone is not valid".into()))?;

  let file = tms_schedule::parse(&body).map_err(|errors| {
    ApiError::Invalid(
      "import.invalid",
      "The schedule file has problems.".into(),
      errors.iter().map(ToString::to_string).collect(),
    )
  })?;
  let resolved = tms_schedule::resolve(file, event.starts_on, event.ends_on, timezone)
    .map_err(|errors| ApiError::Invalid("import.invalid", "The schedule does not fit this event.".into(), errors))?;
  Ok(Json(
    replace(&state, &auth, event_id, &resolved, query.commit, "schedule.import").await?,
  ))
}

/// Builds a schedule from the event's teams, tables, pods, settings and timetable breaks. Without `?commit=true`
/// nothing changes; committing the same request (same seed) saves exactly the schedule previewed.
pub async fn generate(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
  Query(query): Query<ImportQuery>,
  Json(request): Json<GenerateRequest>,
) -> ApiResult<Json<GeneratePreview>> {
  auth.require(Role::Admin)?;
  let event = events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  let timezone: Tz = event
    .timezone
    .parse()
    .map_err(|_| ApiError::BadRequest("event.invalid_timezone", "the event's timezone is not valid".into()))?;
  let to_utc = |local: chrono::NaiveDateTime| {
    timezone
      .from_local_datetime(&local)
      .earliest()
      .map(|t| t.with_timezone(&chrono::Utc))
      .ok_or_else(|| {
        ApiError::BadRequest(
          "generate.invalid_times",
          format!("{local} does not exist in {timezone} (clock change)"),
        )
      })
  };
  if !(5..=60).contains(&request.match_cycle_minutes) {
    return Err(ApiError::BadRequest(
      "generate.invalid_cycle",
      "The match cycle must be between 5 and 60 minutes.".into(),
    ));
  }
  let s = &event.settings;
  let mut conn = state.pool.acquire().await?;
  let team_list = teams::list(&mut *conn, event_id).await?;
  let input = tms_schedule::GenerateInput {
    teams: team_list
      .iter()
      .map(|t| tms_schedule::TiabTeam {
        number: t.number.clone(),
        name: t.name.clone(),
        affiliation: t.affiliation.clone(),
      })
      .collect(),
    tables: venue::tables(&mut *conn, event_id)
      .await?
      .into_iter()
      .map(|t| t.name)
      .collect(),
    pods: venue::pods(&mut *conn, event_id)
      .await?
      .into_iter()
      .map(|p| p.name)
      .collect(),
    match_start: to_utc(request.match_start_local)?,
    match_cycle: TimeDelta::minutes(i64::from(request.match_cycle_minutes)),
    match_length: TimeDelta::seconds(i64::from(s.match_seconds)),
    practice_rounds: s.practice_rounds,
    ranking_rounds: s.ranking_rounds,
    judging_start: to_utc(request.judging_start_local)?,
    session_length: TimeDelta::minutes(i64::from(s.judging_session_minutes)),
    session_cycle: TimeDelta::minutes(i64::from(s.judging_session_minutes + s.judging_buffer_minutes)),
    judging_gap: TimeDelta::minutes(i64::from(s.judging_match_gap_minutes)),
    breaks: blocks::list(&mut *conn, event_id)
      .await?
      .into_iter()
      .filter(|b| b.kind != BlockKind::Other)
      .map(|b| (b.starts_at, b.ends_at))
      .collect(),
    seed: request.seed,
  };
  drop(conn);
  let generated =
    tms_schedule::generate(&input).map_err(|e| ApiError::BadRequest("generate.invalid", e.to_string()))?;
  let resolved = generated.schedule;
  let preview = replace(&state, &auth, event_id, &resolved, query.commit, "schedule.generate").await?;
  let entry = |kind, number, start, end, slots: &[tms_schedule::resolve::ResolvedSlot]| ProposedEntry {
    kind,
    number,
    start,
    end,
    teams: slots
      .iter()
      .map(|s| (s.column.clone(), s.team_number.clone()))
      .collect(),
  };
  Ok(Json(GeneratePreview {
    preview,
    matches: resolved
      .matches
      .iter()
      .map(|m| entry(Some(m.kind), m.number, m.start, m.end, &m.slots))
      .collect(),
    sessions: resolved
      .sessions
      .iter()
      .map(|s| entry(None, s.number, s.start, s.end, &s.slots))
      .collect(),
  }))
}

/// Previews replacing the event's schedule with `resolved`, and with `commit` replaces it: every match and judging
/// session goes, teams are added or updated by number, and missing tables and pods are added. Teams, tables and
/// pods it does not mention are kept.
async fn replace(
  state: &AppState,
  auth: &Auth,
  event_id: Uuid,
  resolved: &ResolvedSchedule,
  commit: bool,
  action: &str,
) -> ApiResult<ImportPreview> {
  let event = events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  let mut tx = state.pool.begin().await?;
  let existing_teams = teams::list(&mut *tx, event_id).await?;
  let existing_tables = venue::tables(&mut *tx, event_id).await?;
  let existing_pods = venue::pods(&mut *tx, event_id).await?;
  let counts = schedule::counts(&mut *tx, event_id).await?;
  let mut preview = preview(resolved, &existing_teams, &existing_tables, &existing_pods, &counts);
  let team_names: Vec<(Uuid, String)> = existing_teams.iter().map(|t| (t.id, t.number.clone())).collect();
  let table_names: Vec<(Uuid, String)> = existing_tables.iter().map(|t| (t.id, t.name.clone())).collect();
  let pod_names: Vec<(Uuid, String)> = existing_pods.iter().map(|p| (p.id, p.name.clone())).collect();
  let timetable = blocks::list(&mut *tx, event_id).await?;
  let known = tms_schedule::view::Known {
    teams: &team_names,
    tables: &table_names,
    pods: &pod_names,
    blocks: &timetable,
  };
  preview.issues = all_issues(
    &tms_schedule::view::view(resolved, &known),
    &Rules::from_settings(&event.settings),
  );

  if !commit {
    return Ok(preview);
  }

  let mut team_ids: HashMap<String, Uuid> = HashMap::new();
  for team in &resolved.teams {
    let saved = teams::upsert_by_number(&mut *tx, event_id, &team.number, &team.name, &team.affiliation).await?;
    team_ids.insert(saved.number, saved.id);
  }
  let mut table_ids: HashMap<String, Uuid> = existing_tables.iter().map(|t| (t.name.clone(), t.id)).collect();
  for name in &resolved.tables {
    if !table_ids.contains_key(name) {
      let table = venue::insert_table(&mut *tx, event_id, name).await?;
      table_ids.insert(table.name, table.id);
    }
  }
  let mut pod_ids: HashMap<String, Uuid> = existing_pods.iter().map(|p| (p.name.clone(), p.id)).collect();
  for name in &resolved.rooms {
    if !pod_ids.contains_key(name) {
      let pod = venue::insert_pod(&mut *tx, event_id, name, None).await?;
      pod_ids.insert(pod.name, pod.id);
    }
  }

  schedule::clear(&mut tx, event_id).await?;
  for m in &resolved.matches {
    let match_id = schedule::insert_match(&mut tx, event_id, m.kind, m.number, m.start, m.end).await?;
    for slot in &m.slots {
      schedule::insert_match_slot(
        &mut tx,
        match_id,
        table_ids[&slot.column],
        Some(team_ids[&slot.team_number]),
        slot.round,
      )
      .await?;
    }
  }
  for s in &resolved.sessions {
    let session_id = schedule::insert_session(&mut tx, event_id, s.number, s.start, s.end).await?;
    for slot in &s.slots {
      schedule::insert_judging_slot(
        &mut tx,
        session_id,
        pod_ids[&slot.column],
        Some(team_ids[&slot.team_number]),
      )
      .await?;
    }
  }
  audit(
    &mut *tx,
    auth,
    Some(event_id),
    action,
    ("event", Some(event_id)),
    serde_json::json!({
      "ranking_matches": preview.ranking_matches,
      "practice_matches": preview.practice_matches,
      "judging_sessions": preview.judging_sessions,
      "teams_added": preview.teams_added,
      "issues": preview.issues.len(),
    }),
  )
  .await?;
  tx.commit().await?;

  let active = is_active(state, event_id).await?;
  if active {
    for topic in [
      Topic::Teams,
      Topic::Tables,
      Topic::Pods,
      Topic::Matches,
      Topic::JudgingSessions,
    ] {
      state.bus.resnapshot(topic);
    }
  }
  state.issues.refresh_all(&state.pool, event_id, active).await?;
  Ok(preview)
}

fn preview(
  resolved: &ResolvedSchedule,
  existing_teams: &[tms_core::model::Team],
  existing_tables: &[tms_core::model::GameTable],
  existing_pods: &[tms_core::model::Pod],
  counts: &schedule::Counts,
) -> ImportPreview {
  let by_number: HashMap<&str, &tms_core::model::Team> =
    existing_teams.iter().map(|t| (t.number.as_str(), t)).collect();
  let in_file: HashSet<&str> = resolved.teams.iter().map(|t| t.number.as_str()).collect();
  let table_names: HashSet<&str> = existing_tables.iter().map(|t| t.name.as_str()).collect();
  let pod_names: HashSet<&str> = existing_pods.iter().map(|p| p.name.as_str()).collect();
  let mut preview = ImportPreview {
    tables_added: resolved
      .tables
      .iter()
      .filter(|n| !table_names.contains(n.as_str()))
      .cloned()
      .collect(),
    pods_added: resolved
      .rooms
      .iter()
      .filter(|n| !pod_names.contains(n.as_str()))
      .cloned()
      .collect(),
    practice_matches: resolved
      .matches
      .iter()
      .filter(|m| m.kind == tms_core::model::MatchKind::Practice)
      .count(),
    ranking_matches: resolved
      .matches
      .iter()
      .filter(|m| m.kind == tms_core::model::MatchKind::Ranking)
      .count(),
    judging_sessions: resolved.sessions.len(),
    replaces_matches: counts.matches,
    replaces_sessions: counts.sessions,
    days: resolved.days.clone(),
    warnings: resolved.warnings.clone(),
    teams_not_in_file: existing_teams
      .iter()
      .filter(|t| !in_file.contains(t.number.as_str()))
      .map(|t| t.number.clone())
      .collect(),
    ..ImportPreview::default()
  };
  for team in &resolved.teams {
    match by_number.get(team.number.as_str()) {
      None => preview.teams_added.push(team.number.clone()),
      Some(existing) if existing.name != team.name || existing.affiliation != team.affiliation => {
        preview.teams_updated.push(team.number.clone());
      }
      Some(_) => {}
    }
  }
  preview
}

/// What the schedule checks find in the event's schedule now.
pub async fn issues(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Vec<ScheduleIssue>>> {
  if auth.require(Role::HeadReferee).is_err() {
    auth.require(Role::JudgeAdvisor)?;
  }
  Ok(Json(state.issues.list(&state.pool, event_id).await?))
}

/// Re-checks the event-wide issues after the timetable changed.
async fn timetable_changed(state: &AppState, event_id: Uuid) -> ApiResult<()> {
  let active = is_active(state, event_id).await?;
  state
    .issues
    .refresh_teams(&state.pool, event_id, &std::collections::BTreeSet::new(), active)
    .await?;
  Ok(())
}

pub async fn blocks(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<Json<Vec<ScheduleBlock>>> {
  auth.require(Role::Display)?;
  Ok(Json(blocks::list(&state.pool, event_id).await?))
}

/// Validates the block and converts its event-local times to UTC with the event's timezone.
async fn clean_block(state: &AppState, event_id: Uuid, input: &BlockInput) -> ApiResult<blocks::BlockRow> {
  let event = events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  let timezone: Tz = event
    .timezone
    .parse()
    .map_err(|_| ApiError::BadRequest("event.invalid_timezone", "the event's timezone is not valid".into()))?;
  let to_utc = |local: chrono::NaiveDateTime| {
    timezone
      .from_local_datetime(&local)
      .earliest()
      .map(|t| t.with_timezone(&chrono::Utc))
      .ok_or_else(|| {
        ApiError::BadRequest(
          "block.invalid_times",
          format!("{local} does not exist in {timezone} (clock change)"),
        )
      })
  };
  let (starts_at, ends_at) = (to_utc(input.starts_local)?, to_utc(input.ends_local)?);
  if ends_at <= starts_at {
    return Err(ApiError::BadRequest(
      "block.invalid_times",
      "a block must end after it starts".into(),
    ));
  }
  Ok(blocks::BlockRow {
    kind: input.kind,
    name: required(&input.name, "Name", 120)?,
    starts_at,
    ends_at,
  })
}

pub async fn create_block(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
  Json(input): Json<BlockInput>,
) -> ApiResult<Json<ScheduleBlock>> {
  auth.require(Role::Admin)?;
  let row = clean_block(&state, event_id, &input).await?;
  let mut tx = state.pool.begin().await?;
  let block = blocks::insert(&mut *tx, event_id, &row).await?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "block.create",
    ("block", Some(block.id)),
    serde_json::to_value(&input).unwrap_or_default(),
  )
  .await?;
  tx.commit().await?;
  publish_upsert(&state, event_id, Topic::Blocks, TopicItem::Block(block.clone())).await?;
  timetable_changed(&state, event_id).await?;
  Ok(Json(block))
}

pub async fn update_block(
  State(state): State<AppState>,
  auth: Auth,
  Path(id): Path<Uuid>,
  Json(input): Json<BlockInput>,
) -> ApiResult<Json<ScheduleBlock>> {
  auth.require(Role::Admin)?;
  let event_id = blocks::event_of(&state.pool, id)
    .await?
    .ok_or(ApiError::NotFound("block"))?;
  let row = clean_block(&state, event_id, &input).await?;
  let mut tx = state.pool.begin().await?;
  let block = blocks::update(&mut *tx, id, &row)
    .await?
    .ok_or(ApiError::NotFound("block"))?;
  audit(
    &mut *tx,
    &auth,
    Some(block.event_id),
    "block.update",
    ("block", Some(id)),
    serde_json::to_value(&input).unwrap_or_default(),
  )
  .await?;
  tx.commit().await?;
  publish_upsert(&state, block.event_id, Topic::Blocks, TopicItem::Block(block.clone())).await?;
  timetable_changed(&state, block.event_id).await?;
  Ok(Json(block))
}

pub async fn delete_block(State(state): State<AppState>, auth: Auth, Path(id): Path<Uuid>) -> ApiResult<StatusCode> {
  auth.require(Role::Admin)?;
  let mut tx = state.pool.begin().await?;
  let event_id = blocks::delete(&mut *tx, id).await?.ok_or(ApiError::NotFound("block"))?;
  audit(
    &mut *tx,
    &auth,
    Some(event_id),
    "block.delete",
    ("block", Some(id)),
    serde_json::json!({}),
  )
  .await?;
  tx.commit().await?;
  publish_delete(&state, event_id, Topic::Blocks, id).await?;
  timetable_changed(&state, event_id).await?;
  Ok(StatusCode::NO_CONTENT)
}

/// The schedule as a Tournament-in-a-Box CSV, for other FIRST Australia tools. Cancelled matches are left out.
pub async fn export_tiab(
  State(state): State<AppState>,
  auth: Auth,
  Path(event_id): Path<Uuid>,
) -> ApiResult<axum::response::Response> {
  use axum::response::IntoResponse;
  use tms_schedule::resolve::ResolvedSlot;
  auth.require(Role::Admin)?;
  let event = events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  let timezone: Tz = event
    .timezone
    .parse()
    .map_err(|_| ApiError::BadRequest("event.invalid_timezone", "the event's timezone is not valid".into()))?;
  let mut conn = state.pool.acquire().await?;
  let team_list = teams::list(&mut *conn, event_id).await?;
  let tables = venue::tables(&mut *conn, event_id).await?;
  let pods = venue::pods(&mut *conn, event_id).await?;
  let number: HashMap<Uuid, String> = team_list.iter().map(|t| (t.id, t.number.clone())).collect();
  let slot = |column: Option<String>, team: Option<Uuid>, round: Option<i32>| {
    Some(ResolvedSlot {
      column: column?,
      team_number: number.get(&team?)?.clone(),
      round,
    })
  };
  let resolved = ResolvedSchedule {
    teams: team_list
      .iter()
      .map(|t| tms_schedule::TiabTeam {
        number: t.number.clone(),
        name: t.name.clone(),
        affiliation: t.affiliation.clone(),
      })
      .collect(),
    tables: tables.iter().map(|t| t.name.clone()).collect(),
    rooms: pods.iter().map(|p| p.name.clone()).collect(),
    matches: schedule::matches(&mut conn, event_id)
      .await?
      .into_iter()
      .filter(|m| m.state != tms_core::model::MatchState::Cancelled)
      .map(|m| tms_schedule::ResolvedMatch {
        kind: m.kind,
        number: m.number,
        start: m.scheduled_start,
        end: m.scheduled_end,
        slots: m
          .slots
          .iter()
          .filter_map(|s| {
            let column = tables.iter().find(|t| t.id == s.table_id).map(|t| t.name.clone());
            slot(column, s.team_id, s.round)
          })
          .collect(),
      })
      .collect(),
    sessions: schedule::sessions(&mut conn, event_id)
      .await?
      .into_iter()
      .map(|s| tms_schedule::ResolvedSession {
        number: s.number,
        start: s.scheduled_start,
        end: s.scheduled_end,
        slots: s
          .slots
          .iter()
          .filter_map(|x| {
            let column = pods.iter().find(|p| p.id == x.pod_id).map(|p| p.name.clone());
            slot(column, x.team_id, None)
          })
          .collect(),
      })
      .collect(),
    days: Vec::new(),
    warnings: Vec::new(),
  };
  let csv = tms_schedule::write::write(&resolved, timezone, event.starts_on);
  Ok(
    (
      [
        (axum::http::header::CONTENT_TYPE, "text/csv; charset=utf-8".to_owned()),
        (
          axum::http::header::CONTENT_DISPOSITION,
          format!("attachment; filename=\"{}-schedule.csv\"", event.code),
        ),
      ],
      csv,
    )
      .into_response(),
  )
}
