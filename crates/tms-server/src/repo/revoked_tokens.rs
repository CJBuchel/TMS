use chrono::{DateTime, Utc};
use sqlx::PgExecutor;
use uuid::Uuid;

/// Remembers a logged-out token until it would have expired anyway.
pub async fn insert(db: impl PgExecutor<'_>, jti: Uuid, expires_at: DateTime<Utc>) -> sqlx::Result<()> {
  sqlx::query!(
    "insert into revoked_tokens (jti, expires_at) values ($1, $2) on conflict (jti) do nothing",
    jti,
    expires_at
  )
  .execute(db)
  .await?;
  Ok(())
}
