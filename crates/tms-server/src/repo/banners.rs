use sqlx::PgExecutor;
use tms_core::dto::{Banner, BannerSeverity};
use uuid::Uuid;

pub async fn list_active(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Vec<Banner>> {
  sqlx::query_as!(
    Banner,
    r#"select id, event_id, severity as "severity: BannerSeverity", message, created_at
       from banners where event_id = $1 and active order by created_at"#,
    event_id
  )
  .fetch_all(db)
  .await
}

pub async fn insert(
  db: impl PgExecutor<'_>,
  event_id: Uuid,
  severity: BannerSeverity,
  message: &str,
  created_by: Option<Uuid>,
) -> sqlx::Result<Banner> {
  sqlx::query_as!(
    Banner,
    r#"insert into banners (id, event_id, severity, message, created_by) values ($1, $2, $3, $4, $5)
       returning id, event_id, severity as "severity: BannerSeverity", message, created_at"#,
    Uuid::now_v7(),
    event_id,
    severity as BannerSeverity,
    message,
    created_by,
  )
  .fetch_one(db)
  .await
}

/// Returns the banner's event id when an active banner was cleared.
pub async fn clear(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<Uuid>> {
  sqlx::query_scalar!(
    "update banners set active = false where id = $1 and active returning event_id",
    id
  )
  .fetch_optional(db)
  .await
}
