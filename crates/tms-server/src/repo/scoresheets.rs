//! Scoresheets.

use chrono::{DateTime, Utc};
use sqlx::types::Json;
use sqlx::{PgConnection, PgExecutor};
use tms_core::game::{RoundResult, Scoresheet, ScoresheetFlag, ScoresheetStatus};
use tms_core::model::MatchKind;
use tms_seasons::{Answers, Issue};
use uuid::Uuid;

struct Row {
  id: Uuid,
  event_id: Uuid,
  team_id: Uuid,
  team_number: String,
  kind: MatchKind,
  round: i32,
  match_id: Option<Uuid>,
  slot_id: Option<Uuid>,
  table_id: Option<Uuid>,
  submitted_by: String,
  referee_name: String,
  status: ScoresheetStatus,
  flags: Vec<String>,
  no_show: bool,
  score: i32,
  gp: Option<i16>,
  gp_comment: String,
  answers: Json<Answers>,
  issues: Json<Vec<Issue>>,
  team_agreed: bool,
  team_initials: String,
  private_comment: String,
  review_note: String,
  created_at: DateTime<Utc>,
  received_at: DateTime<Utc>,
  reviewed_by: Option<String>,
  reviewed_at: Option<DateTime<Utc>>,
}

impl From<Row> for Scoresheet {
  fn from(r: Row) -> Self {
    Scoresheet {
      id: r.id,
      event_id: r.event_id,
      team_id: r.team_id,
      team_number: r.team_number,
      kind: r.kind,
      round: r.round,
      match_id: r.match_id,
      slot_id: r.slot_id,
      table_id: r.table_id,
      submitted_by: r.submitted_by,
      referee_name: r.referee_name,
      status: r.status,
      flags: r.flags.iter().filter_map(|f| ScoresheetFlag::from_key(f)).collect(),
      no_show: r.no_show,
      score: u16::try_from(r.score).unwrap_or(0),
      gp: r.gp.and_then(|g| u8::try_from(g).ok()),
      gp_comment: r.gp_comment,
      answers: r.answers.0,
      issues: r.issues.0,
      team_agreed: r.team_agreed,
      team_initials: r.team_initials,
      private_comment: r.private_comment,
      review_note: r.review_note,
      created_at: r.created_at,
      received_at: r.received_at,
      reviewed_by: r.reviewed_by,
      reviewed_at: r.reviewed_at,
    }
  }
}

pub async fn list(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Vec<Scoresheet>> {
  let rows = sqlx::query_as!(
    Row,
    r#"select c.id, c.event_id, c.team_id, t.number as team_number, c.kind as "kind: MatchKind", c.round, c.match_id,
              c.slot_id, c.table_id, c.submitted_by, c.referee_name, c.status as "status: ScoresheetStatus", c.flags,
              c.no_show, c.score, c.gp, c.gp_comment, c.answers as "answers: Json<Answers>",
              c.issues as "issues: Json<Vec<Issue>>", c.team_agreed, c.team_initials, c.private_comment,
              c.review_note, c.created_at, c.received_at, c.reviewed_by, c.reviewed_at
       from scoresheets c join teams t on t.id = c.team_id
       where c.event_id = $1 order by c.received_at"#,
    event_id
  )
  .fetch_all(db)
  .await?;
  Ok(rows.into_iter().map(Into::into).collect())
}

pub async fn get(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<Scoresheet>> {
  let row = sqlx::query_as!(
    Row,
    r#"select c.id, c.event_id, c.team_id, t.number as team_number, c.kind as "kind: MatchKind", c.round, c.match_id,
              c.slot_id, c.table_id, c.submitted_by, c.referee_name, c.status as "status: ScoresheetStatus", c.flags,
              c.no_show, c.score, c.gp, c.gp_comment, c.answers as "answers: Json<Answers>",
              c.issues as "issues: Json<Vec<Issue>>", c.team_agreed, c.team_initials, c.private_comment,
              c.review_note, c.created_at, c.received_at, c.reviewed_by, c.reviewed_at
       from scoresheets c join teams t on t.id = c.team_id
       where c.id = $1"#,
    id
  )
  .fetch_optional(db)
  .await?;
  Ok(row.map(Into::into))
}

/// Locks a sheet for review and returns its status.
pub async fn lock(tx: &mut PgConnection, id: Uuid) -> sqlx::Result<Option<ScoresheetStatus>> {
  sqlx::query_scalar!(
    r#"select status as "status: ScoresheetStatus" from scoresheets where id = $1 for update"#,
    id
  )
  .fetch_optional(&mut *tx)
  .await
}

pub async fn status_of(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<ScoresheetStatus>> {
  sqlx::query_scalar!(
    r#"select status as "status: ScoresheetStatus" from scoresheets where id = $1"#,
    id
  )
  .fetch_optional(db)
  .await
}

/// The published sheet for a team's round, other than `except`.
pub async fn published_for_round(
  tx: &mut PgConnection,
  team_id: Uuid,
  kind: MatchKind,
  round: i32,
  except: Uuid,
) -> sqlx::Result<Option<Uuid>> {
  sqlx::query_scalar!(
    "select id from scoresheets where team_id = $1 and kind = $2 and round = $3 and status = 'published' and id <> $4",
    team_id,
    kind as MatchKind,
    round,
    except,
  )
  .fetch_optional(&mut *tx)
  .await
}

pub struct NewSheet<'a> {
  pub id: Uuid,
  pub event_id: Uuid,
  pub event_code: &'a str,
  pub season_id: &'a str,
  pub schema_version: i32,
  pub team_id: Uuid,
  pub kind: MatchKind,
  pub round: i32,
  pub match_id: Option<Uuid>,
  pub slot_id: Option<Uuid>,
  pub table_id: Option<Uuid>,
  pub submitted_by_user: Option<Uuid>,
  pub submitted_by_key: Option<Uuid>,
  pub submitted_by: &'a str,
  pub referee_name: &'a str,
  pub status: ScoresheetStatus,
  pub flags: Vec<String>,
  pub no_show: bool,
  pub score: i32,
  pub gp: Option<i16>,
  pub gp_comment: &'a str,
  pub answers: &'a Answers,
  pub issues: &'a [Issue],
  pub team_agreed: bool,
  pub team_initials: &'a str,
  pub private_comment: &'a str,
  pub created_at: DateTime<Utc>,
}

/// Stores a sheet. Returns false if a sheet with that id already exists.
pub async fn insert(tx: &mut PgConnection, s: NewSheet<'_>) -> sqlx::Result<bool> {
  let done = sqlx::query!(
    r#"insert into scoresheets (id, event_id, event_code, season_id, schema_version, team_id, kind, round, match_id,
         slot_id, table_id, submitted_by_user, submitted_by_key, submitted_by, referee_name, status, flags, no_show,
         score, gp, gp_comment, answers, issues, team_agreed, team_initials, private_comment, created_at)
       values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22,
         $23, $24, $25, $26, $27)
       on conflict (id) do nothing"#,
    s.id,
    s.event_id,
    s.event_code,
    s.season_id,
    s.schema_version,
    s.team_id,
    s.kind as MatchKind,
    s.round,
    s.match_id,
    s.slot_id,
    s.table_id,
    s.submitted_by_user,
    s.submitted_by_key,
    s.submitted_by,
    s.referee_name,
    s.status as ScoresheetStatus,
    &s.flags,
    s.no_show,
    s.score,
    s.gp,
    s.gp_comment,
    Json(s.answers) as _,
    Json(s.issues) as _,
    s.team_agreed,
    s.team_initials,
    s.private_comment,
    s.created_at,
  )
  .execute(&mut *tx)
  .await?;
  Ok(done.rows_affected() == 1)
}

pub async fn set_status(
  tx: &mut PgConnection,
  id: Uuid,
  status: ScoresheetStatus,
  review_note: Option<&str>,
  reviewed_by: Option<&str>,
) -> sqlx::Result<()> {
  sqlx::query!(
    "update scoresheets set status = $2, review_note = coalesce($3, review_note),
            reviewed_by = coalesce($4, reviewed_by), reviewed_at = case when $4::text is null then reviewed_at else now() end
     where id = $1",
    id,
    status as ScoresheetStatus,
    review_note,
    reviewed_by,
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

/// Published ranking-round results of an event. A no-show has no score.
pub async fn ranking_results(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Vec<RoundResult>> {
  let rows = sqlx::query!(
    "select team_id, round, score, no_show from scoresheets
     where event_id = $1 and kind = 'ranking' and status = 'published'",
    event_id
  )
  .fetch_all(db)
  .await?;
  Ok(
    rows
      .into_iter()
      .map(|r| RoundResult {
        team_id: r.team_id,
        round: r.round,
        score: (!r.no_show).then(|| u16::try_from(r.score).unwrap_or(0)),
      })
      .collect(),
  )
}

pub struct SlotBinding {
  pub event_id: Uuid,
  pub match_id: Uuid,
  pub table_id: Uuid,
  pub team_id: Option<Uuid>,
  pub kind: MatchKind,
  pub round: Option<i32>,
}

pub async fn slot_binding(db: impl PgExecutor<'_>, slot_id: Uuid) -> sqlx::Result<Option<SlotBinding>> {
  sqlx::query_as!(
    SlotBinding,
    r#"select m.event_id, s.match_id, s.table_id, s.team_id, m.kind as "kind: MatchKind", s.round
       from match_slots s join game_matches m on m.id = s.match_id where s.id = $1"#,
    slot_id
  )
  .fetch_optional(db)
  .await
}

/// Serialises scoresheet changes for one team until the transaction ends.
pub async fn lock_team(tx: &mut PgConnection, team_id: Uuid) -> sqlx::Result<()> {
  sqlx::query!("select id from teams where id = $1 for update", team_id)
    .fetch_optional(&mut *tx)
    .await?;
  Ok(())
}

pub async fn team_by_number(db: impl PgExecutor<'_>, event_id: Uuid, number: &str) -> sqlx::Result<Option<Uuid>> {
  sqlx::query_scalar!(
    "select id from teams where event_id = $1 and number = $2",
    event_id,
    number
  )
  .fetch_optional(db)
  .await
}
