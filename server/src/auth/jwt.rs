use anyhow::Result;
use jsonwebtoken::{DecodingKey, EncodingKey};
use once_cell::sync::OnceCell;
use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::{
  auth::permissions::RolePermissions,
  generated::{common::Role, db::Secret},
  modules::secret::SecretRepository,
};

static JWT_SECRET: OnceCell<Vec<u8>> = OnceCell::new();

pub fn init_jwt_secret() -> Result<()> {
  log::info!("Initializing JWT secret");

  // check if JWT_SECRET is already set
  if JWT_SECRET.get().is_some() {
    log::warn!("JWT_SECRET already initialized");
  } else {
    // check if JWT exists in the db
    let secret = Secret::get()?;
    JWT_SECRET.set(secret.secret_bytes).map_err(|_| {
      log::error!("Failed to set JWT_SECRET");
      anyhow::anyhow!("Failed to set JWT_SECRET")
    })?;
  }

  Ok(())
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Claims {
  pub sub: String,        // User ID
  pub roles: Vec<String>, // Roles
  pub exp: i64,           // Expiration timestamp
  pub iat: i64,           // Issued at
}

impl Claims {
  pub fn roles(&self) -> Vec<Role> {
    // Convert role str to Role type, skipping invalid roles
    self.roles.iter().filter_map(|role| Role::from_str_name(role)).collect()
  }

  /// Check if user has a specific permission in any of their roles
  pub fn has_permission(&self, required: &Role) -> bool {
    self.roles().iter().any(|role| role.has_permission(required))
  }

  /// Check if user has ALL required permissions
  pub fn has_all_permissions(&self, required: &[Role]) -> bool {
    required.iter().all(|req| self.has_permission(req))
  }

  /// Check if user has a specific role (exact match, not inheritance)
  pub fn has_role(&self, role: &Role) -> bool {
    self.roles().contains(role)
  }

  /// Check if user is an admin
  pub fn is_admin(&self) -> bool {
    self.has_role(&Role::Admin)
  }
}

#[derive(Debug, Error)]
pub enum AuthError {
  #[error("Token expired")]
  Expired,
  #[error("Invalid token")]
  Invalid,
  #[error("Token decoding error: {0}")]
  DecodingError(#[from] jsonwebtoken::errors::Error),
}

pub struct Auth;

impl Auth {
  fn encoding_key() -> Result<EncodingKey> {
    let Some(secret) = JWT_SECRET.get() else {
      return Err(anyhow::anyhow!("JWT_SECRET not initialized"));
    };
    Ok(EncodingKey::from_secret(secret))
  }

  fn decoding_key() -> Result<DecodingKey> {
    let Some(secret) = JWT_SECRET.get() else {
      return Err(anyhow::anyhow!("JWT_SECRET not initialized"));
    };
    Ok(DecodingKey::from_secret(secret))
  }

  pub fn generate_token(user_id: &str, roles: &[Role]) -> Result<String> {
    // Expiration time is set to 7 days from now
    let exp = match chrono::Utc::now().checked_add_signed(chrono::Duration::days(7)) {
      Some(exp) => exp.timestamp(),
      None => return Err(anyhow::anyhow!("Failed to calculate expiration time")),
    };

    let roles: Vec<String> = roles.iter().map(|r| r.as_str_name().to_string()).collect();

    let claims = Claims { sub: user_id.to_string(), roles, exp, iat: chrono::Utc::now().timestamp() };

    let encoding_key = Self::encoding_key()?;
    let header = jsonwebtoken::Header::default();
    let token = jsonwebtoken::encode(&header, &claims, &encoding_key)?;
    Ok(token)
  }

  pub fn validate_token(token: &str) -> Result<Claims, AuthError> {
    let token_data = jsonwebtoken::decode::<Claims>(
      token,
      &Self::decoding_key().map_err(|_| AuthError::Invalid)?,
      &jsonwebtoken::Validation::default(),
    )?;

    // Check if the token is expired
    if token_data.claims.exp < chrono::Utc::now().timestamp() {
      return Err(AuthError::Expired);
    }

    Ok(token_data.claims)
  }
}
