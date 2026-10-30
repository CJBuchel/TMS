use std::net::SocketAddr;

use axum::Json;
use axum::extract::{ConnectInfo, State};
use axum::http::StatusCode;
use chrono::Utc;
use tms_core::access_key;
use tms_core::dto::{AuthResponse, ChangePasswordRequest, Identity, KeyLoginRequest, LoginRequest, Principal};

use crate::AppState;
use crate::auth::crypto::{self, DUMMY_HASH};
use crate::auth::jwt::{KEY_TOKEN_TTL, USER_TOKEN_TTL};
use crate::auth::{Auth, Revocation};
use crate::error::{ApiError, ApiResult};
use crate::repo::audit::{self, Entry};
use crate::repo::{keys, revoked_tokens, users};

pub const MIN_PASSWORD_LEN: usize = 8;

fn user_token(state: &AppState, user: users::UserRow) -> ApiResult<AuthResponse> {
  let principal = Principal::User {
    user_id: user.id,
    username: user.username,
    display_name: user.display_name,
  };
  let (token, claims) = state
    .auth
    .issue(principal, user.roles, user.must_change_password, USER_TOKEN_TTL, None)?;
  Ok(AuthResponse {
    token,
    expires_at: claims.expires_at(),
    identity: claims.identity(),
  })
}

fn key_token(state: &AppState, key: keys::UsableKey) -> ApiResult<AuthResponse> {
  let principal = Principal::Key {
    key_id: key.id,
    event_id: key.event_id,
    label: key.label,
    table_id: key.table_id,
    pod_id: key.pod_id,
  };
  let (token, claims) = state
    .auth
    .issue(principal, key.roles, false, KEY_TOKEN_TTL, key.expires_at)?;
  Ok(AuthResponse {
    token,
    expires_at: claims.expires_at(),
    identity: claims.identity(),
  })
}

pub async fn login(
  State(state): State<AppState>,
  ConnectInfo(addr): ConnectInfo<SocketAddr>,
  Json(req): Json<LoginRequest>,
) -> ApiResult<Json<AuthResponse>> {
  state.login_limiter.check(addr.ip())?;
  let user = users::find_by_username(&state.pool, req.username.trim()).await?;
  let hash = user
    .as_ref()
    .map_or_else(|| DUMMY_HASH.clone(), |u| u.password_hash.clone());
  let valid = crypto::verify_password_blocking(req.password, hash).await;
  let user = match user {
    Some(u) if valid && !u.disabled => u,
    _ => {
      state.login_limiter.failed(addr.ip());
      return Err(ApiError::InvalidCredentials);
    }
  };
  state.login_limiter.succeeded(addr.ip());
  Ok(Json(user_token(&state, user)?))
}

pub async fn key_login(
  State(state): State<AppState>,
  ConnectInfo(addr): ConnectInfo<SocketAddr>,
  Json(req): Json<KeyLoginRequest>,
) -> ApiResult<Json<AuthResponse>> {
  state.login_limiter.check(addr.ip())?;
  let key = match access_key::parse(&req.key) {
    Some(parsed) => keys::find_usable(&state.pool, &crypto::sha256(&parsed.normalized)).await?,
    None => None,
  };
  let Some(key) = key else {
    state.login_limiter.failed(addr.ip());
    return Err(ApiError::InvalidCredentials);
  };
  state.login_limiter.succeeded(addr.ip());
  Ok(Json(key_token(&state, key)?))
}

/// A new token for the same user or key, re-read from the database so role changes and expiry apply.
pub async fn refresh(State(state): State<AppState>, auth: Auth) -> ApiResult<Json<AuthResponse>> {
  let response = match auth.identity.principal {
    Principal::User { user_id, .. } => {
      let user = users::find_by_id(&state.pool, user_id).await?.filter(|u| !u.disabled);
      user_token(&state, user.ok_or(ApiError::Unauthenticated)?)?
    }
    Principal::Key { key_id, .. } => {
      let key = keys::find_usable_by_id(&state.pool, key_id).await?;
      key_token(&state, key.ok_or(ApiError::Unauthenticated)?)?
    }
  };
  Ok(Json(response))
}

pub async fn logout(State(state): State<AppState>, auth: Auth) -> ApiResult<StatusCode> {
  let expires_at = auth.claims.expires_at();
  revoked_tokens::insert(&state.pool, auth.claims.jti, expires_at).await?;
  state.auth.apply(Revocation::Token {
    jti: auth.claims.jti,
    expires_at,
  });
  Ok(StatusCode::NO_CONTENT)
}

pub async fn me(auth: Auth) -> Json<Identity> {
  Json(auth.identity)
}

/// Changes the caller's password, logs out every other device using this account, and returns a fresh token.
pub async fn change_password(
  State(state): State<AppState>,
  auth: Auth,
  Json(req): Json<ChangePasswordRequest>,
) -> ApiResult<Json<AuthResponse>> {
  let user_id = auth.user_id().ok_or(ApiError::Forbidden)?;
  if req.new_password.chars().count() < MIN_PASSWORD_LEN {
    return Err(ApiError::BadRequest(
      "auth.password_too_short",
      format!("use at least {MIN_PASSWORD_LEN} characters"),
    ));
  }
  let user = users::find_by_id(&state.pool, user_id)
    .await?
    .ok_or(ApiError::Unauthenticated)?;
  if !crypto::verify_password_blocking(req.current_password, user.password_hash).await {
    return Err(ApiError::InvalidCredentials);
  }
  let hash = crypto::hash_password_blocking(req.new_password).await?;
  let cutoff = Utc::now();

  let mut tx = state.pool.begin().await?;
  users::set_password(&mut *tx, user_id, &hash, false, cutoff).await?;
  audit::insert(
    &mut *tx,
    Entry {
      event_id: None,
      actor: &auth.actor(),
      action: "user.change_password",
      entity_type: "user",
      entity_id: Some(user_id),
      data: serde_json::json!({}),
    },
  )
  .await?;
  tx.commit().await?;

  state.auth.apply(Revocation::UserBefore {
    user_id,
    before: cutoff,
  });
  let user = users::find_by_id(&state.pool, user_id)
    .await?
    .ok_or(ApiError::Unauthenticated)?;
  Ok(Json(user_token(&state, user)?))
}
