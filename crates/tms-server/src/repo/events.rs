use chrono::NaiveDate;
use sqlx::types::Json;
use sqlx::{PgConnection, PgExecutor};
use tms_core::dto::{CreateEventRequest, EventStatus, EventSummary, UpdateEventRequest};
use tms_core::model::EventSettings;
use uuid::Uuid;

struct EventRow {
  id: Uuid,
  code: String,
  name: String,
  season_id: String,
  timezone: String,
  starts_on: NaiveDate,
  ends_on: NaiveDate,
  status: EventStatus,
  settings: Json<EventSettings>,
}

impl From<EventRow> for EventSummary {
  fn from(r: EventRow) -> Self {
    EventSummary {
      id: r.id,
      code: r.code,
      name: r.name,
      season_id: r.season_id,
      timezone: r.timezone,
      starts_on: r.starts_on,
      ends_on: r.ends_on,
      status: r.status,
      settings: r.settings.0,
    }
  }
}

pub async fn list(db: impl PgExecutor<'_>) -> sqlx::Result<Vec<EventSummary>> {
  let rows = sqlx::query_as!(
    EventRow,
    r#"select id, code, name, season_id, timezone, starts_on, ends_on, status as "status: EventStatus",
              settings as "settings: Json<EventSettings>"
       from events order by starts_on desc, name"#
  )
  .fetch_all(db)
  .await?;
  Ok(rows.into_iter().map(Into::into).collect())
}

pub async fn get(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<EventSummary>> {
  let row = sqlx::query_as!(
    EventRow,
    r#"select id, code, name, season_id, timezone, starts_on, ends_on, status as "status: EventStatus",
              settings as "settings: Json<EventSettings>"
       from events where id = $1"#,
    id
  )
  .fetch_optional(db)
  .await?;
  Ok(row.map(Into::into))
}

pub async fn active(db: impl PgExecutor<'_>) -> sqlx::Result<Option<EventSummary>> {
  let row = sqlx::query_as!(
    EventRow,
    r#"select id, code, name, season_id, timezone, starts_on, ends_on, status as "status: EventStatus",
              settings as "settings: Json<EventSettings>"
       from events where status = 'active'"#
  )
  .fetch_optional(db)
  .await?;
  Ok(row.map(Into::into))
}

pub async fn active_id(db: impl PgExecutor<'_>) -> sqlx::Result<Option<Uuid>> {
  sqlx::query_scalar!("select id from events where status = 'active'")
    .fetch_optional(db)
    .await
}

pub async fn insert(db: impl PgExecutor<'_>, e: &CreateEventRequest) -> sqlx::Result<EventSummary> {
  let row = sqlx::query_as!(
    EventRow,
    r#"insert into events (id, code, name, season_id, timezone, starts_on, ends_on, settings)
       values ($1, $2, $3, $4, $5, $6, $7, $8)
       returning id, code, name, season_id, timezone, starts_on, ends_on, status as "status: EventStatus",
                 settings as "settings: Json<EventSettings>""#,
    Uuid::now_v7(),
    e.code,
    e.name,
    e.season_id,
    e.timezone,
    e.starts_on,
    e.ends_on,
    Json(EventSettings::default()) as _,
  )
  .fetch_one(db)
  .await?;
  Ok(row.into())
}

pub async fn update(db: impl PgExecutor<'_>, id: Uuid, e: &UpdateEventRequest) -> sqlx::Result<Option<EventSummary>> {
  let row = sqlx::query_as!(
    EventRow,
    r#"update events set name = $2, season_id = $3, timezone = $4, starts_on = $5, ends_on = $6, settings = $7
       where id = $1
       returning id, code, name, season_id, timezone, starts_on, ends_on, status as "status: EventStatus",
                 settings as "settings: Json<EventSettings>""#,
    id,
    e.name,
    e.season_id,
    e.timezone,
    e.starts_on,
    e.ends_on,
    Json(&e.settings) as _,
  )
  .fetch_optional(db)
  .await?;
  Ok(row.map(Into::into))
}

/// Makes `id` the only active event; the previously active one goes back to draft. Call inside a transaction.
pub async fn activate(tx: &mut PgConnection, id: Uuid) -> sqlx::Result<Option<EventSummary>> {
  sqlx::query!(
    "update events set status = 'draft' where status = 'active' and id <> $1",
    id
  )
  .execute(&mut *tx)
  .await?;
  let row = sqlx::query_as!(
    EventRow,
    r#"update events set status = 'active' where id = $1 and status <> 'archived'
       returning id, code, name, season_id, timezone, starts_on, ends_on, status as "status: EventStatus",
                 settings as "settings: Json<EventSettings>""#,
    id
  )
  .fetch_optional(&mut *tx)
  .await?;
  Ok(row.map(Into::into))
}

pub async fn archive(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<EventSummary>> {
  let row = sqlx::query_as!(
    EventRow,
    r#"update events set status = 'archived' where id = $1
       returning id, code, name, season_id, timezone, starts_on, ends_on, status as "status: EventStatus",
                 settings as "settings: Json<EventSettings>""#,
    id
  )
  .fetch_optional(db)
  .await?;
  Ok(row.map(Into::into))
}
