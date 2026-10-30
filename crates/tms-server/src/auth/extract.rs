use axum::extract::FromRequestParts;
use axum::http::header::AUTHORIZATION;
use axum::http::request::Parts;
use tms_core::Role;
use tms_core::dto::{Identity, Principal};
use tms_core::role::has_role;
use uuid::Uuid;

use crate::AppState;
use crate::auth::Claims;
use crate::error::{ApiError, ApiResult};

/// The authenticated caller, from a verified `Authorization: Bearer <jwt>`.
#[derive(Debug, Clone)]
pub struct Auth {
  pub claims: Claims,
  pub identity: Identity,
}

impl Auth {
  /// Fails unless the caller holds `role` (directly or through inheritance) and has no pending password change.
  pub fn require(&self, role: Role) -> ApiResult<()> {
    if self.identity.must_change_password {
      return Err(ApiError::PasswordChangeRequired);
    }
    if has_role(&self.identity.roles, role) {
      Ok(())
    } else {
      Err(ApiError::Forbidden)
    }
  }

  pub fn user_id(&self) -> Option<Uuid> {
    match &self.identity.principal {
      Principal::User { user_id, .. } => Some(*user_id),
      Principal::Key { .. } => None,
    }
  }

  /// Name recorded in the audit log.
  pub fn actor(&self) -> String {
    match &self.identity.principal {
      Principal::User { username, .. } => format!("user:{username}"),
      Principal::Key { label, .. } => format!("key:{label}"),
    }
  }
}

pub fn bearer_token(parts: &Parts) -> Option<&str> {
  parts.headers.get(AUTHORIZATION)?.to_str().ok()?.strip_prefix("Bearer ")
}

impl FromRequestParts<AppState> for Auth {
  type Rejection = ApiError;

  /// Verification is in memory, so the future is ready immediately.
  fn from_request_parts(
    parts: &mut Parts,
    state: &AppState,
  ) -> impl Future<Output = Result<Self, Self::Rejection>> + Send {
    let result = bearer_token(parts)
      .and_then(|token| state.auth.verify(token))
      .map(|claims| Auth {
        identity: claims.identity(),
        claims,
      })
      .ok_or(ApiError::Unauthenticated);
    std::future::ready(result)
  }
}
