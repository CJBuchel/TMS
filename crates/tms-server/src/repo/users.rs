use chrono::{DateTime, Utc};
use sqlx::PgExecutor;
use tms_core::Role;
use tms_core::dto::UserSummary;
use uuid::Uuid;

pub struct UserRow {
  pub id: Uuid,
  pub username: String,
  pub display_name: String,
  pub password_hash: String,
  pub roles: Vec<Role>,
  pub disabled: bool,
  pub must_change_password: bool,
}

pub async fn count(db: impl PgExecutor<'_>) -> sqlx::Result<i64> {
  sqlx::query_scalar!(r#"select count(*) as "count!" from users"#)
    .fetch_one(db)
    .await
}

pub async fn find_by_username(db: impl PgExecutor<'_>, username: &str) -> sqlx::Result<Option<UserRow>> {
  sqlx::query_as!(
    UserRow,
    r#"select id, username, display_name, password_hash, roles as "roles: Vec<Role>", disabled, must_change_password
       from users where username = $1"#,
    username
  )
  .fetch_optional(db)
  .await
}

pub async fn find_by_id(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<UserRow>> {
  sqlx::query_as!(
    UserRow,
    r#"select id, username, display_name, password_hash, roles as "roles: Vec<Role>", disabled, must_change_password
       from users where id = $1"#,
    id
  )
  .fetch_optional(db)
  .await
}

pub struct NewUser<'a> {
  pub username: &'a str,
  pub display_name: &'a str,
  pub password_hash: &'a str,
  pub roles: &'a [Role],
  pub must_change_password: bool,
}

pub async fn insert(db: impl PgExecutor<'_>, u: NewUser<'_>) -> sqlx::Result<Uuid> {
  sqlx::query_scalar!(
    r#"insert into users (id, username, display_name, password_hash, roles, must_change_password)
       values ($1, $2, $3, $4, $5, $6) returning id"#,
    Uuid::now_v7(),
    u.username,
    u.display_name,
    u.password_hash,
    u.roles as &[Role],
    u.must_change_password,
  )
  .fetch_one(db)
  .await
}

/// Sets a new password and invalidates every login token issued before `tokens_valid_after`.
/// `must_change` is true for a one-time password an admin hands out.
pub async fn set_password(
  db: impl PgExecutor<'_>,
  id: Uuid,
  password_hash: &str,
  must_change: bool,
  tokens_valid_after: DateTime<Utc>,
) -> sqlx::Result<()> {
  sqlx::query!(
    "update users set password_hash = $2, must_change_password = $3, tokens_valid_after = $4 where id = $1",
    id,
    password_hash,
    must_change,
    tokens_valid_after,
  )
  .execute(db)
  .await?;
  Ok(())
}

pub async fn list(db: impl PgExecutor<'_>) -> sqlx::Result<Vec<UserSummary>> {
  sqlx::query_as!(
    UserSummary,
    r#"select id, username, display_name, roles as "roles: Vec<Role>", disabled, must_change_password, created_at
       from users order by username"#
  )
  .fetch_all(db)
  .await
}

pub async fn summary(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<UserSummary>> {
  sqlx::query_as!(
    UserSummary,
    r#"select id, username, display_name, roles as "roles: Vec<Role>", disabled, must_change_password, created_at
       from users where id = $1"#,
    id
  )
  .fetch_optional(db)
  .await
}

/// Changes profile fields. `tokens_valid_after` is set when the change must end existing logins (roles changed,
/// account disabled) so the next token carries the new roles.
pub async fn update(
  db: impl PgExecutor<'_>,
  id: Uuid,
  display_name: &str,
  roles: &[Role],
  disabled: bool,
  tokens_valid_after: Option<DateTime<Utc>>,
) -> sqlx::Result<Option<UserSummary>> {
  sqlx::query_as!(
    UserSummary,
    r#"update users set display_name = $2, roles = $3, disabled = $4,
              tokens_valid_after = coalesce($5, tokens_valid_after)
       where id = $1
       returning id, username, display_name, roles as "roles: Vec<Role>", disabled, must_change_password, created_at"#,
    id,
    display_name,
    roles as &[Role],
    disabled,
    tokens_valid_after,
  )
  .fetch_optional(db)
  .await
}

/// Enabled users holding the admin role, other than `except`.
pub async fn other_enabled_admins(db: impl PgExecutor<'_>, except: Uuid) -> sqlx::Result<i64> {
  sqlx::query_scalar!(
    r#"select count(*) as "count!" from users where id <> $1 and not disabled and 'admin' = any(roles)"#,
    except
  )
  .fetch_one(db)
  .await
}
