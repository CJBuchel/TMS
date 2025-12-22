use tonic::{Request, Status};

use crate::{
  auth::jwt::{Auth, AuthError, Claims},
  generated::common::Role,
};

/// Extension to store the authenticated user claims in request
#[derive(Clone, Debug)]
pub struct AuthContext {
  pub claims: Option<Claims>,
}

// ============================================================================
// GENERAL INTERCEPTOR (for mixed services)
// Validates token but doesn't enforce permissions - methods check themselves
// ============================================================================

/// Interceptor that validates JWT tokens from metadata but doesn't enforce permissions
/// Use this for services with mixed public/private endpoints
pub fn auth_interceptor(mut req: Request<()>) -> Result<Request<()>, Status> {
  // Try to get token from metadata
  let token = req.metadata().get("authorization").and_then(|v| v.to_str().ok()).and_then(|s| s.strip_prefix("Bearer "));

  // Validate token if present
  let claims = if let Some(token) = token {
    match Auth::validate_token(token) {
      Ok(claims) => Some(claims),
      Err(e) => {
        log::warn!("Invalid token: {}", e);
        None
      }
    }
  } else {
    None
  };

  // Store auth context in request extensions
  req.extensions_mut().insert(AuthContext { claims });

  Ok(req)
}

// ============================================================================
// SERVICE-LEVEL PERMISSION INTERCEPTORS
// Enforces permissions at service boundary - all methods protected
// ============================================================================

/// Create an interceptor that requires specific permission (any of the roles)
/// Use this for services where ALL methods require the same permission level
pub fn require_permission_interceptor(
  required: Vec<Role>,
) -> impl Fn(Request<()>) -> Result<Request<()>, Status> + Clone {
  move |mut req: Request<()>| {
    // Extract token
    let token = req
      .metadata()
      .get("authorization")
      .and_then(|v| v.to_str().ok())
      .and_then(|s| s.strip_prefix("Bearer "))
      .ok_or_else(|| Status::unauthenticated("Authentication required"))?;

    // Verify token
    let claims = Auth::validate_token(token).map_err(|e| match e {
      AuthError::Expired => Status::unauthenticated("Token expired"),
      AuthError::Invalid => Status::unauthenticated("Invalid token"),
      AuthError::DecodingError(_) => Status::unauthenticated("Token decoding failed"),
    })?;

    // Check permissions (ANY of the required roles)
    let has_permission = required.iter().any(|role| claims.has_permission(role));

    if !has_permission {
      return Err(Status::permission_denied(format!(
        "One of these permissions required: {}",
        required.iter().map(Role::as_str_name).collect::<Vec<_>>().join(", ")
      )));
    }

    // Store claims for use in methods (for logging, etc)
    req.extensions_mut().insert(AuthContext { claims: Some(claims) });

    Ok(req)
  }
}

/// Convenience function for single role requirement
/// Use this when a service requires exactly one role
pub fn require_role_interceptor(required: Role) -> impl Fn(Request<()>) -> Result<Request<()>, Status> + Clone {
  require_permission_interceptor(vec![required])
}
