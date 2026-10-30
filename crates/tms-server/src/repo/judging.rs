//! Judging slots' queue state, pod timers and rubrics.

use std::collections::BTreeMap;

use chrono::{DateTime, Utc};
use sqlx::types::Json;
use sqlx::{PgConnection, PgExecutor};
use tms_core::deliberation::TeamInputs;
use tms_core::judging::{Feedback, Nomination, PodTimer, Rubric, RubricStatus};
use tms_core::model::QueueState;
use tms_seasons::rubric::RubricTotals;
use uuid::Uuid;

pub struct SlotRow {
  pub event_id: Uuid,
  pub session_id: Uuid,
  pub pod_id: Uuid,
  pub team_id: Option<Uuid>,
  pub state: QueueState,
  pub previous: Option<QueueState>,
}

pub async fn lock_slot(tx: &mut PgConnection, id: Uuid) -> sqlx::Result<Option<SlotRow>> {
  sqlx::query_as!(
    SlotRow,
    r#"select j.event_id, s.session_id, s.pod_id, s.team_id, s.queue_state as "state: QueueState",
              s.queue_previous as "previous: QueueState"
       from judging_slots s join judging_sessions j on j.id = s.session_id
       where s.id = $1 for update of s"#,
    id
  )
  .fetch_optional(&mut *tx)
  .await
}

pub async fn change_queue(
  tx: &mut PgConnection,
  id: Uuid,
  from: QueueState,
  to: QueueState,
  actor: &str,
) -> sqlx::Result<()> {
  let previous = if to == QueueState::NotCalled { None } else { Some(from) };
  sqlx::query!(
    "update judging_slots set queue_state = $2, queue_previous = $3, queue_changed_at = now(), queue_changed_by = $4
     where id = $1",
    id,
    to as QueueState,
    previous as Option<QueueState>,
    actor,
  )
  .execute(&mut *tx)
  .await?;
  sqlx::query!(
    "insert into judging_queue_events (slot_id, from_state, to_state, actor) values ($1, $2, $3, $4)",
    id,
    from as QueueState,
    to as QueueState,
    actor,
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

/// The pod timer moves the pod's slot in a session: into session when it starts, done when it finishes.
pub async fn timer_moves_slot(
  tx: &mut PgConnection,
  session_id: Uuid,
  pod_id: Uuid,
  from: &[QueueState],
  to: QueueState,
) -> sqlx::Result<()> {
  sqlx::query!(
    "update judging_slots set queue_state = $4, queue_previous = null, queue_changed_at = now(), queue_changed_by = 'pod timer'
     where session_id = $1 and pod_id = $2 and team_id is not null and queue_state = any($3)",
    session_id,
    pod_id,
    from as &[QueueState],
    to as QueueState,
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

pub async fn pod_event(db: impl PgExecutor<'_>, pod_id: Uuid) -> sqlx::Result<Option<Uuid>> {
  sqlx::query_scalar!("select event_id from pods where id = $1", pod_id)
    .fetch_optional(db)
    .await
}

pub async fn session_event(db: impl PgExecutor<'_>, session_id: Uuid) -> sqlx::Result<Option<Uuid>> {
  sqlx::query_scalar!("select event_id from judging_sessions where id = $1", session_id)
    .fetch_optional(db)
    .await
}

fn timer_from(
  pod_id: Uuid,
  session_id: Option<Uuid>,
  phase: Option<i32>,
  started: Option<DateTime<Utc>>,
  ms: i32,
) -> PodTimer {
  PodTimer {
    pod_id,
    session_id,
    phase: phase.and_then(|p| usize::try_from(p).ok()),
    phase_started_at: started,
    phase_ms: u32::try_from(ms).unwrap_or(0),
  }
}

/// Locks the pod's timer row, creating an idle one if needed.
pub async fn lock_timer(tx: &mut PgConnection, pod_id: Uuid) -> sqlx::Result<PodTimer> {
  sqlx::query!(
    "insert into pod_timers (pod_id) values ($1) on conflict (pod_id) do nothing",
    pod_id
  )
  .execute(&mut *tx)
  .await?;
  let row = sqlx::query!(
    "select session_id, phase, phase_started_at, phase_ms from pod_timers where pod_id = $1 for update",
    pod_id
  )
  .fetch_one(&mut *tx)
  .await?;
  Ok(timer_from(
    pod_id,
    row.session_id,
    row.phase,
    row.phase_started_at,
    row.phase_ms,
  ))
}

pub async fn save_timer(tx: &mut PgConnection, t: &PodTimer) -> sqlx::Result<()> {
  sqlx::query!(
    "update pod_timers set session_id = $2, phase = $3, phase_started_at = $4, phase_ms = $5 where pod_id = $1",
    t.pod_id,
    t.session_id,
    t.phase.and_then(|p| i32::try_from(p).ok()),
    t.phase_started_at,
    i32::try_from(t.phase_ms).unwrap_or(i32::MAX),
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

/// Every pod's timer for an event, idle for pods that never started one.
pub async fn timers(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Vec<PodTimer>> {
  let rows = sqlx::query!(
    r#"select p.id as pod_id, t.session_id as "session_id?", t.phase as "phase?",
              t.phase_started_at as "phase_started_at?", t.phase_ms as "phase_ms?"
       from pods p left join pod_timers t on t.pod_id = p.id
       where p.event_id = $1 order by p.sort_order"#,
    event_id
  )
  .fetch_all(db)
  .await?;
  Ok(
    rows
      .into_iter()
      .map(|r| {
        timer_from(
          r.pod_id,
          r.session_id,
          r.phase,
          r.phase_started_at,
          r.phase_ms.unwrap_or(0),
        )
      })
      .collect(),
  )
}

struct RubricRow {
  id: Uuid,
  event_id: Uuid,
  team_id: Uuid,
  team_number: String,
  slot_id: Option<Uuid>,
  pod_id: Option<Uuid>,
  judge_names: String,
  submitted_by: String,
  status: RubricStatus,
  duplicate: bool,
  scores: Json<BTreeMap<String, u8>>,
  exceeds_comments: Json<BTreeMap<String, String>>,
  feedback: Json<Feedback>,
  nominations: Vec<String>,
  innovation_project: i32,
  robot_design: i32,
  core_values_rows: i32,
  review_note: String,
  created_at: DateTime<Utc>,
  received_at: DateTime<Utc>,
  reviewed_by: Option<String>,
}

fn nomination_key(n: Nomination) -> &'static str {
  match n {
    Nomination::Breakthrough => "breakthrough",
    Nomination::RisingAllStar => "rising_all_star",
    Nomination::Motivate => "motivate",
  }
}

pub fn nominations_from(keys: &[String]) -> Vec<Nomination> {
  keys
    .iter()
    .filter_map(|n| Nomination::ALL.into_iter().find(|x| nomination_key(*x) == n))
    .collect()
}

fn small(v: i32) -> u16 {
  u16::try_from(v).unwrap_or(0)
}

impl From<RubricRow> for Rubric {
  fn from(r: RubricRow) -> Self {
    Rubric {
      id: r.id,
      event_id: r.event_id,
      team_id: r.team_id,
      team_number: r.team_number,
      slot_id: r.slot_id,
      pod_id: r.pod_id,
      judge_names: r.judge_names,
      submitted_by: r.submitted_by,
      status: r.status,
      duplicate: r.duplicate,
      scores: r.scores.0,
      exceeds_comments: r.exceeds_comments.0,
      feedback: r.feedback.0,
      nominations: nominations_from(&r.nominations),
      innovation_project: small(r.innovation_project),
      robot_design: small(r.robot_design),
      core_values_rows: small(r.core_values_rows),
      review_note: r.review_note,
      created_at: r.created_at,
      received_at: r.received_at,
      reviewed_by: r.reviewed_by,
    }
  }
}

pub async fn list(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Vec<Rubric>> {
  let rows = sqlx::query_as!(
    RubricRow,
    r#"select r.id, r.event_id, r.team_id, t.number as team_number, r.slot_id, r.pod_id, r.judge_names, r.submitted_by,
              r.status as "status: RubricStatus", r.duplicate, r.scores as "scores: Json<BTreeMap<String, u8>>",
              r.exceeds_comments as "exceeds_comments: Json<BTreeMap<String, String>>",
              r.feedback as "feedback: Json<Feedback>", r.nominations, r.innovation_project, r.robot_design,
              r.core_values_rows, r.review_note, r.created_at, r.received_at, r.reviewed_by
       from rubrics r join teams t on t.id = r.team_id
       where r.event_id = $1 order by r.received_at"#,
    event_id
  )
  .fetch_all(db)
  .await?;
  Ok(rows.into_iter().map(Into::into).collect())
}

pub async fn get(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<Rubric>> {
  let row = sqlx::query_as!(
    RubricRow,
    r#"select r.id, r.event_id, r.team_id, t.number as team_number, r.slot_id, r.pod_id, r.judge_names, r.submitted_by,
              r.status as "status: RubricStatus", r.duplicate, r.scores as "scores: Json<BTreeMap<String, u8>>",
              r.exceeds_comments as "exceeds_comments: Json<BTreeMap<String, String>>",
              r.feedback as "feedback: Json<Feedback>", r.nominations, r.innovation_project, r.robot_design,
              r.core_values_rows, r.review_note, r.created_at, r.received_at, r.reviewed_by
       from rubrics r join teams t on t.id = r.team_id
       where r.id = $1"#,
    id
  )
  .fetch_optional(db)
  .await?;
  Ok(row.map(Into::into))
}

pub async fn status_of(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<RubricStatus>> {
  sqlx::query_scalar!(
    r#"select status as "status: RubricStatus" from rubrics where id = $1"#,
    id
  )
  .fetch_optional(db)
  .await
}

pub async fn lock(tx: &mut PgConnection, id: Uuid) -> sqlx::Result<Option<RubricStatus>> {
  sqlx::query_scalar!(
    r#"select status as "status: RubricStatus" from rubrics where id = $1 for update"#,
    id
  )
  .fetch_optional(&mut *tx)
  .await
}

pub async fn accepted_for_team(tx: &mut PgConnection, team_id: Uuid, except: Uuid) -> sqlx::Result<Option<Uuid>> {
  sqlx::query_scalar!(
    "select id from rubrics where team_id = $1 and status = 'accepted' and id <> $2",
    team_id,
    except
  )
  .fetch_optional(&mut *tx)
  .await
}

pub struct NewRubric<'a> {
  pub id: Uuid,
  pub event_id: Uuid,
  pub event_code: &'a str,
  pub season_id: &'a str,
  pub schema_version: i32,
  pub team_id: Uuid,
  pub slot_id: Option<Uuid>,
  pub pod_id: Option<Uuid>,
  pub judge_names: &'a str,
  pub submitted_by_user: Option<Uuid>,
  pub submitted_by_key: Option<Uuid>,
  pub submitted_by: &'a str,
  pub status: RubricStatus,
  pub duplicate: bool,
  pub scores: &'a BTreeMap<String, u8>,
  pub exceeds_comments: &'a BTreeMap<String, String>,
  pub feedback: &'a Feedback,
  pub nominations: &'a [Nomination],
  pub totals: RubricTotals,
  pub created_at: DateTime<Utc>,
}

pub async fn insert(tx: &mut PgConnection, r: NewRubric<'_>) -> sqlx::Result<bool> {
  let nominations: Vec<String> = r.nominations.iter().map(|n| nomination_key(*n).to_owned()).collect();
  let done = sqlx::query!(
    r#"insert into rubrics (id, event_id, event_code, season_id, schema_version, team_id, slot_id, pod_id, judge_names,
         submitted_by_user, submitted_by_key, submitted_by, status, duplicate, scores, exceeds_comments, feedback,
         nominations, innovation_project, robot_design, core_values_rows, created_at)
       values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22)
       on conflict (id) do nothing"#,
    r.id,
    r.event_id,
    r.event_code,
    r.season_id,
    r.schema_version,
    r.team_id,
    r.slot_id,
    r.pod_id,
    r.judge_names,
    r.submitted_by_user,
    r.submitted_by_key,
    r.submitted_by,
    r.status as RubricStatus,
    r.duplicate,
    Json(r.scores) as _,
    Json(r.exceeds_comments) as _,
    Json(r.feedback) as _,
    &nominations,
    i32::from(r.totals.innovation_project),
    i32::from(r.totals.robot_design),
    i32::from(r.totals.core_values_rows),
    r.created_at,
  )
  .execute(&mut *tx)
  .await?;
  Ok(done.rows_affected() == 1)
}

pub async fn set_status(
  tx: &mut PgConnection,
  id: Uuid,
  status: RubricStatus,
  note: Option<&str>,
  reviewed_by: &str,
) -> sqlx::Result<()> {
  sqlx::query!(
    "update rubrics set status = $2, review_note = coalesce($3, review_note), reviewed_by = $4, reviewed_at = now()
     where id = $1",
    id,
    status as RubricStatus,
    note,
    reviewed_by,
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

/// Everything deliberation needs per team: the accepted rubric's totals, and Gracious Professionalism and score
/// from each published ranking sheet in round order.
pub async fn team_inputs(db: &mut PgConnection, event_id: Uuid) -> sqlx::Result<Vec<TeamInputs>> {
  let rows = sqlx::query!(
    r#"select t.id,
              r.innovation_project as "ip?", r.robot_design as "rd?", r.core_values_rows as "cv?",
              coalesce((select array_agg(c.gp order by c.round) from scoresheets c
                        where c.team_id = t.id and c.kind = 'ranking' and c.status = 'published' and c.gp is not null),
                       '{}') as "gp!: Vec<i16>",
              coalesce((select array_agg(c.score order by c.round) from scoresheets c
                        where c.team_id = t.id and c.kind = 'ranking' and c.status = 'published' and not c.no_show),
                       '{}') as "scores!: Vec<i32>"
       from teams t
       left join rubrics r on r.team_id = t.id and r.status = 'accepted'
       where t.event_id = $1
       order by length(t.number), t.number"#,
    event_id
  )
  .fetch_all(&mut *db)
  .await?;
  Ok(
    rows
      .into_iter()
      .map(|r| TeamInputs {
        team_id: r.id,
        rubric: match (r.ip, r.rd, r.cv) {
          (Some(ip), Some(rd), Some(cv)) => Some(RubricTotals {
            innovation_project: small(ip),
            robot_design: small(rd),
            core_values_rows: small(cv),
          }),
          _ => None,
        },
        gp: r.gp.into_iter().filter_map(|g| u8::try_from(g).ok()).collect(),
        robot_game: r.scores.into_iter().map(small).collect(),
      })
      .collect(),
  )
}
