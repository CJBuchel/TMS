use chrono::{DateTime, Utc};
use sqlx::PgExecutor;
use tms_core::model::{BlockKind, ScheduleBlock};
use uuid::Uuid;

pub struct BlockRow {
  pub kind: BlockKind,
  pub name: String,
  pub starts_at: DateTime<Utc>,
  pub ends_at: DateTime<Utc>,
}

pub async fn event_of(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<Uuid>> {
  sqlx::query_scalar!("select event_id from schedule_blocks where id = $1", id)
    .fetch_optional(db)
    .await
}

pub async fn list(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Vec<ScheduleBlock>> {
  sqlx::query_as!(
    ScheduleBlock,
    r#"select id, event_id, kind as "kind: BlockKind", name, starts_at, ends_at from schedule_blocks
       where event_id = $1 order by starts_at"#,
    event_id
  )
  .fetch_all(db)
  .await
}

pub async fn insert(db: impl PgExecutor<'_>, event_id: Uuid, b: &BlockRow) -> sqlx::Result<ScheduleBlock> {
  sqlx::query_as!(
    ScheduleBlock,
    r#"insert into schedule_blocks (id, event_id, kind, name, starts_at, ends_at) values ($1, $2, $3, $4, $5, $6)
       returning id, event_id, kind as "kind: BlockKind", name, starts_at, ends_at"#,
    Uuid::now_v7(),
    event_id,
    b.kind as BlockKind,
    b.name,
    b.starts_at,
    b.ends_at,
  )
  .fetch_one(db)
  .await
}

pub async fn update(db: impl PgExecutor<'_>, id: Uuid, b: &BlockRow) -> sqlx::Result<Option<ScheduleBlock>> {
  sqlx::query_as!(
    ScheduleBlock,
    r#"update schedule_blocks set kind = $2, name = $3, starts_at = $4, ends_at = $5 where id = $1
       returning id, event_id, kind as "kind: BlockKind", name, starts_at, ends_at"#,
    id,
    b.kind as BlockKind,
    b.name,
    b.starts_at,
    b.ends_at,
  )
  .fetch_optional(db)
  .await
}

pub async fn delete(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<Uuid>> {
  sqlx::query_scalar!("delete from schedule_blocks where id = $1 returning event_id", id)
    .fetch_optional(db)
    .await
}
