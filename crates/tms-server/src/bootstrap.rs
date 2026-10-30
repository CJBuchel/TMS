//! Making sure someone can always log in as `admin`: on first start, and whenever the launcher (or
//! `--admin-password`) gives the admin a password.

use chrono::Utc;
use sqlx::PgPool;
use tms_core::Role;

use crate::auth::crypto;
use crate::repo::{audit, users};

/// The `admin` user's password on a first start that was given none.
pub const DEFAULT_PASSWORD: &str = "admin";

/// What `ensure_admin` did.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AdminAccount {
  /// Users exist and no password was given, or the given one is already `admin`'s.
  Unchanged,
  /// First start with no password given: `admin` now logs in with [`DEFAULT_PASSWORD`].
  CreatedWithDefault,
  /// `admin` was created with, or now has, the password given. It is enabled again if it was disabled.
  PasswordSet,
}

/// Creates or updates the user `admin`. With a password, `admin` ends up with exactly that password and enabled,
/// so the launcher is always a way back in. Without one, `admin` is created with [`DEFAULT_PASSWORD`] only when
/// there are no users at all. Neither asks for a change at first login.
pub async fn ensure_admin(pool: &PgPool, password: Option<String>) -> anyhow::Result<AdminAccount> {
  let password = password.filter(|p| !p.trim().is_empty());
  let existing = users::find_by_username(pool, "admin").await?;
  let Some(password) = password else {
    if users::count(pool).await? > 0 {
      return Ok(AdminAccount::Unchanged);
    }
    create(pool, DEFAULT_PASSWORD).await?;
    return Ok(AdminAccount::CreatedWithDefault);
  };
  let Some(user) = existing else {
    create(pool, &password).await?;
    return Ok(AdminAccount::PasswordSet);
  };
  if !user.disabled && crypto::verify_password_blocking(password.clone(), user.password_hash.clone()).await {
    return Ok(AdminAccount::Unchanged);
  }
  let hash = crypto::hash_password_blocking(password).await?;
  let mut tx = pool.begin().await?;
  users::set_password(&mut *tx, user.id, &hash, false, Utc::now()).await?;
  sqlx::query("update users set disabled = false where id = $1")
    .bind(user.id)
    .execute(&mut *tx)
    .await?;
  audit::insert(
    &mut *tx,
    audit::Entry {
      event_id: None,
      actor: "launcher",
      action: "user.set_password",
      entity_type: "user",
      entity_id: Some(user.id),
      data: serde_json::json!({ "username": "admin" }),
    },
  )
  .await?;
  tx.commit().await?;
  Ok(AdminAccount::PasswordSet)
}

async fn create(pool: &PgPool, password: &str) -> anyhow::Result<()> {
  let hash = crypto::hash_password_blocking(password.to_owned()).await?;
  users::insert(
    pool,
    users::NewUser {
      username: "admin",
      display_name: "Administrator",
      password_hash: &hash,
      roles: &[Role::Admin],
      must_change_password: false,
    },
  )
  .await?;
  Ok(())
}
