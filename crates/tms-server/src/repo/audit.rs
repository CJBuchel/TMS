use sqlx::PgExecutor;
use tms_core::dto::AuditEntry;
use uuid::Uuid;

pub struct Entry<'a> {
  pub event_id: Option<Uuid>,
  pub actor: &'a str,
  pub action: &'a str,
  pub entity_type: &'a str,
  pub entity_id: Option<Uuid>,
  pub data: serde_json::Value,
}

pub async fn insert(db: impl PgExecutor<'_>, e: Entry<'_>) -> sqlx::Result<()> {
  sqlx::query!(
    "insert into audit_log (event_id, actor, action, entity_type, entity_id, data) values ($1, $2, $3, $4, $5, $6)",
    e.event_id,
    e.actor,
    e.action,
    e.entity_type,
    e.entity_id,
    e.data,
  )
  .execute(db)
  .await?;
  Ok(())
}

/// Newest first. `before` pages backwards: pass the smallest id of the previous page.
pub async fn list(
  db: impl PgExecutor<'_>,
  event_id: Option<Uuid>,
  entity_type: Option<&str>,
  before: Option<i64>,
  limit: i64,
) -> sqlx::Result<Vec<AuditEntry>> {
  sqlx::query_as!(
    AuditEntry,
    r#"select id, event_id, actor, action, entity_type, entity_id, data, at from audit_log
       where ($1::uuid is null or event_id = $1) and ($2::text is null or entity_type = $2)
         and ($3::bigint is null or id < $3)
       order by id desc limit $4"#,
    event_id,
    entity_type,
    before,
    limit,
  )
  .fetch_all(db)
  .await
}
