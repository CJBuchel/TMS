//! User accounts. A new or reset account gets the password the admin chooses, or else a one-time password that
//! must be changed at first login.

use axum::Json;
use axum::extract::{Path, State};
use chrono::Utc;
use tms_core::Role;
use tms_core::dto::{CreateUserRequest, OneTimePassword, SetPasswordRequest, UpdateUserRequest, UserSummary};
use uuid::Uuid;

use super::auth::MIN_PASSWORD_LEN;
use super::support::{audit, required};
use crate::AppState;
use crate::auth::{Auth, Revocation, crypto};
use crate::error::{ApiError, ApiResult};
use crate::repo::users;

const USERNAME_RULE: &str = "Usernames are 2-64 characters: lower-case letters, digits, '.', '_' or '-'.";

fn one_time_password() -> String {
  crypto::new_token()[..12].to_owned()
}

/// The admin's chosen password, checked, or a one-time password; and whether it must be changed at first login.
fn chosen_or_one_time(chosen: Option<String>) -> ApiResult<(String, bool)> {
  match chosen.filter(|p| !p.is_empty()) {
    Some(p) if p.chars().count() < MIN_PASSWORD_LEN => Err(ApiError::BadRequest(
      "auth.password_too_short",
      format!("use at least {MIN_PASSWORD_LEN} characters"),
    )),
    Some(p) => Ok((p, false)),
    None => Ok((one_time_password(), true)),
  }
}

fn check_roles(roles: &[Role]) -> ApiResult<()> {
  if roles.is_empty() {
    return Err(ApiError::BadRequest(
      "user.no_roles",
      "a user needs at least one role".into(),
    ));
  }
  Ok(())
}

pub async fn list(State(state): State<AppState>, auth: Auth) -> ApiResult<Json<Vec<UserSummary>>> {
  auth.require(Role::Admin)?;
  Ok(Json(users::list(&state.pool).await?))
}

pub async fn create(
  State(state): State<AppState>,
  auth: Auth,
  Json(input): Json<CreateUserRequest>,
) -> ApiResult<Json<OneTimePassword>> {
  auth.require(Role::Admin)?;
  let username = input.username.trim().to_lowercase();
  let valid = (2..=64).contains(&username.len())
    && username
      .chars()
      .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || "._-".contains(c));
  if !valid {
    return Err(ApiError::BadRequest("user.invalid_username", USERNAME_RULE.into()));
  }
  let display_name = required(&input.display_name, "Display name", 80)?;
  check_roles(&input.roles)?;

  let (password, must_change) = chosen_or_one_time(input.password.clone())?;
  let hash = crypto::hash_password_blocking(password.clone()).await?;
  let mut tx = state.pool.begin().await?;
  let id = users::insert(
    &mut *tx,
    users::NewUser {
      username: &username,
      display_name: &display_name,
      password_hash: &hash,
      roles: &input.roles,
      must_change_password: must_change,
    },
  )
  .await
  .map_err(|e| match ApiError::from(e) {
    ApiError::Conflict("conflict.duplicate", _) => {
      ApiError::Conflict("user.duplicate", format!("the username `{username}` is taken"))
    }
    other => other,
  })?;
  audit(
    &mut *tx,
    &auth,
    None,
    "user.create",
    ("user", Some(id)),
    serde_json::json!({ "username": username, "roles": input.roles }),
  )
  .await?;
  let user = users::summary(&mut *tx, id).await?.ok_or(ApiError::NotFound("user"))?;
  tx.commit().await?;
  Ok(Json(OneTimePassword { user, password }))
}

/// Changing roles or disabling ends the user's existing logins, so their next token carries the change.
pub async fn update(
  State(state): State<AppState>,
  auth: Auth,
  Path(id): Path<Uuid>,
  Json(input): Json<UpdateUserRequest>,
) -> ApiResult<Json<UserSummary>> {
  auth.require(Role::Admin)?;
  let current = users::summary(&state.pool, id)
    .await?
    .ok_or(ApiError::NotFound("user"))?;
  let display_name = match &input.display_name {
    Some(name) => required(name, "Display name", 80)?,
    None => current.display_name.clone(),
  };
  let roles = input.roles.clone().unwrap_or_else(|| current.roles.clone());
  check_roles(&roles)?;
  let disabled = input.disabled.unwrap_or(current.disabled);

  let loses_admin =
    (disabled || !roles.contains(&Role::Admin)) && current.roles.contains(&Role::Admin) && !current.disabled;
  if loses_admin && auth.user_id() == Some(id) {
    return Err(ApiError::Conflict(
      "user.self_lockout",
      "you cannot remove your own admin access".into(),
    ));
  }
  if loses_admin && users::other_enabled_admins(&state.pool, id).await? == 0 {
    return Err(ApiError::Conflict(
      "user.last_admin",
      "at least one enabled admin must remain".into(),
    ));
  }

  let ends_logins = roles != current.roles || (disabled && !current.disabled);
  let cutoff = ends_logins.then(Utc::now);
  let mut tx = state.pool.begin().await?;
  let user = users::update(&mut *tx, id, &display_name, &roles, disabled, cutoff)
    .await?
    .ok_or(ApiError::NotFound("user"))?;
  audit(
    &mut *tx,
    &auth,
    None,
    "user.update",
    ("user", Some(id)),
    serde_json::to_value(&input).unwrap_or_default(),
  )
  .await?;
  tx.commit().await?;
  if let Some(before) = cutoff {
    state.auth.apply(Revocation::UserBefore { user_id: id, before });
  }
  Ok(Json(user))
}

/// The chosen password, or a new one-time password; the user's existing logins end.
pub async fn reset_password(
  State(state): State<AppState>,
  auth: Auth,
  Path(id): Path<Uuid>,
  body: Option<Json<Option<SetPasswordRequest>>>,
) -> ApiResult<Json<OneTimePassword>> {
  auth.require(Role::Admin)?;
  let (password, must_change) = chosen_or_one_time(body.and_then(|Json(b)| b).and_then(|b| b.password))?;
  let hash = crypto::hash_password_blocking(password.clone()).await?;
  let cutoff = Utc::now();
  let mut tx = state.pool.begin().await?;
  users::set_password(&mut *tx, id, &hash, must_change, cutoff).await?;
  let user = users::summary(&mut *tx, id).await?.ok_or(ApiError::NotFound("user"))?;
  audit(
    &mut *tx,
    &auth,
    None,
    "user.reset_password",
    ("user", Some(id)),
    serde_json::json!({ "chosen": !must_change }),
  )
  .await?;
  tx.commit().await?;
  state.auth.apply(Revocation::UserBefore {
    user_id: id,
    before: cutoff,
  });
  Ok(Json(OneTimePassword { user, password }))
}
