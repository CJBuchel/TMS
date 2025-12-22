use tonic::{Request, Status};

use crate::{
  auth::{auth_interceptors::AuthContext, jwt::Claims},
  generated::common::Role,
};

// ============================================================================
// METHOD-LEVEL HELPERS
// For use inside methods when service has no interceptor or needs granular checks
// ============================================================================

/// Require authentication - returns claims or error
/// Use this in methods that need auth but service has no interceptor
pub fn require_auth<T>(req: &Request<T>) -> Result<Claims, Status> {
  req
    .extensions()
    .get::<AuthContext>()
    .and_then(|ctx| ctx.claims.clone())
    .ok_or_else(|| Status::unauthenticated("Authentication required"))
}

/// Require a specific permission (checks role inheritance)
/// Use this when a method needs a specific permission level
pub fn require_permission<T>(req: &Request<T>, required: Role) -> Result<Claims, Status> {
  let claims = require_auth(req)?;

  if !claims.has_permission(&required) {
    return Err(Status::permission_denied(format!(
      "Permission '{}' required. User has roles: {:?}",
      required.as_str_name(),
      claims.roles
    )));
  }

  Ok(claims)
}

/// Require ALL of the specified permissions
/// Use this when a method needs multiple permissions simultaneously
pub fn require_all_permissions<T>(req: &Request<T>, required: &[Role]) -> Result<Claims, Status> {
  let claims = require_auth(req)?;

  if !claims.has_all_permissions(required) {
    let user_roles = claims.roles();
    let missing: Vec<_> = required.iter().filter(|role| !claims.has_permission(role)).map(Role::as_str_name).collect();

    return Err(Status::permission_denied(format!(
      "Missing required permissions: {}. User has roles: {:?}",
      missing.join(", "),
      user_roles
    )));
  }

  Ok(claims)
}

/// Require ANY of the specified permissions
/// Use this when a method accepts multiple different permission levels
pub fn require_any_permission<T>(req: &Request<T>, required: &[Role]) -> Result<Claims, Status> {
  let claims = require_auth(req)?;

  if required.iter().any(|role| claims.has_permission(role)) {
    Ok(claims)
  } else {
    Err(Status::permission_denied(format!(
      "One of these permissions required: {}. User has roles: {:?}",
      required.iter().map(Role::as_str_name).collect::<Vec<_>>().join(", "),
      claims.roles
    )))
  }
}

/// Require exact role match (no inheritance)
/// Use this when a method needs an exact role, not inherited permissions
pub fn require_exact_role<T>(req: &Request<T>, required: Role) -> Result<Claims, Status> {
  let claims = require_auth(req)?;

  if !claims.has_role(&required) {
    return Err(Status::permission_denied(format!(
      "Role '{}' required (exact match). User has roles: {:?}",
      required.as_str_name(),
      claims.roles
    )));
  }

  Ok(claims)
}

/// Get optional auth (for logging/analytics on public endpoints)
/// Use this in public methods to optionally log authenticated users
pub fn get_auth<T>(req: &Request<T>) -> Option<Claims> {
  req.extensions().get::<AuthContext>().and_then(|ctx| ctx.claims.clone())
}

/// Get claims from a request - assumes auth was already checked by interceptor
/// Use this in service-protected methods for logging/audit trails
/// Panics if claims not found (should only be used after service-level interceptor)
pub fn get_claims<T>(req: &Request<T>) -> Result<Claims, Status> {
  req
    .extensions()
    .get::<AuthContext>()
    .and_then(|ctx| ctx.claims.clone())
    .ok_or_else(|| Status::internal("Claims not found - auth interceptor missing?"))
}
