use chrono::{DateTime, Utc};
use sqlx::PgExecutor;
use tms_core::Role;
use tms_core::dto::AccessKeySummary;
use uuid::Uuid;

pub async fn list(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Vec<AccessKeySummary>> {
  sqlx::query_as!(
    AccessKeySummary,
    r#"select id, event_id, prefix, label, roles as "roles: Vec<Role>", table_id, pod_id, expires_at, revoked_at,
              last_used_at, created_at
       from access_keys where event_id = $1 order by created_at"#,
    event_id
  )
  .fetch_all(db)
  .await
}

pub struct NewKey<'a> {
  pub event_id: Uuid,
  pub key_hash: Vec<u8>,
  pub prefix: &'a str,
  pub label: &'a str,
  pub roles: &'a [Role],
  pub table_id: Option<Uuid>,
  pub pod_id: Option<Uuid>,
  pub expires_at: Option<DateTime<Utc>>,
  pub created_by: Option<Uuid>,
}

pub async fn insert(db: impl PgExecutor<'_>, k: NewKey<'_>) -> sqlx::Result<AccessKeySummary> {
  sqlx::query_as!(
    AccessKeySummary,
    r#"insert into access_keys (id, event_id, key_hash, prefix, label, roles, table_id, pod_id, expires_at, created_by)
       values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       returning id, event_id, prefix, label, roles as "roles: Vec<Role>", table_id, pod_id, expires_at, revoked_at,
                 last_used_at, created_at"#,
    Uuid::now_v7(),
    k.event_id,
    k.key_hash,
    k.prefix,
    k.label,
    k.roles as &[Role],
    k.table_id,
    k.pod_id,
    k.expires_at,
    k.created_by,
  )
  .fetch_one(db)
  .await
}

pub async fn revoke(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<AccessKeySummary>> {
  sqlx::query_as!(
    AccessKeySummary,
    r#"update access_keys set revoked_at = coalesce(revoked_at, now()) where id = $1
       returning id, event_id, prefix, label, roles as "roles: Vec<Role>", table_id, pod_id, expires_at, revoked_at,
                 last_used_at, created_at"#,
    id
  )
  .fetch_optional(db)
  .await
}

/// Revokes every key of an event (when it is archived). Returns the ids that were still live.
pub async fn revoke_all(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Vec<Uuid>> {
  sqlx::query_scalar!(
    "update access_keys set revoked_at = now() where event_id = $1 and revoked_at is null returning id",
    event_id
  )
  .fetch_all(db)
  .await
}

pub struct UsableKey {
  pub id: Uuid,
  pub event_id: Uuid,
  pub label: String,
  pub roles: Vec<Role>,
  pub table_id: Option<Uuid>,
  pub pod_id: Option<Uuid>,
  pub expires_at: Option<DateTime<Utc>>,
}

/// A key can log in while it is not revoked, not expired, and its event is not archived.
pub async fn find_usable(db: impl PgExecutor<'_>, key_hash: &[u8]) -> sqlx::Result<Option<UsableKey>> {
  sqlx::query_as!(
    UsableKey,
    r#"update access_keys k set last_used_at = now()
       from events e
       where k.key_hash = $1 and e.id = k.event_id and e.status <> 'archived'
         and k.revoked_at is null and (k.expires_at is null or k.expires_at > now())
       returning k.id, k.event_id, k.label, k.roles as "roles: Vec<Role>", k.table_id, k.pod_id, k.expires_at"#,
    key_hash
  )
  .fetch_optional(db)
  .await
}

/// Same rules as `find_usable`, by id. Used to refresh a key's login token.
pub async fn find_usable_by_id(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<UsableKey>> {
  sqlx::query_as!(
    UsableKey,
    r#"update access_keys k set last_used_at = now()
       from events e
       where k.id = $1 and e.id = k.event_id and e.status <> 'archived'
         and k.revoked_at is null and (k.expires_at is null or k.expires_at > now())
       returning k.id, k.event_id, k.label, k.roles as "roles: Vec<Role>", k.table_id, k.pod_id, k.expires_at"#,
    id
  )
  .fetch_optional(db)
  .await
}
