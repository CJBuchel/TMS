use anyhow::{Ok, Result};
use jsonwebtoken::{DecodingKey, EncodingKey};
use once_cell::sync::OnceCell;
use serde::{Deserialize, Serialize};

use crate::features::{Secret, SecretRepository};

use super::permissions::Role;

// lazy once cell
static JWT_SECRET: OnceCell<Vec<u8>> = OnceCell::new();

pub async fn initialize_jwt_secret() -> Result<()> {
  log::info!("Initializing JWT secret");

  // check if JWT_SECRET is already set
  if JWT_SECRET.get().is_some() {
    log::warn!("JWT_SECRET already initialized");
  } else {
    // check if JWT exists in the db
    let secret = Secret::get().await?;
    JWT_SECRET.set(secret).map_err(|_| {
      log::error!("Failed to set JWT_SECRET");
      anyhow::anyhow!("Failed to set JWT_SECRET")
    })?;
  }

  Ok(())
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
  pub sub: String,      // User ID
  pub exp: usize,       // Expiration time (as UTC timestamp)
  pub roles: Vec<Role>, // User roles
}

pub struct Auth;

impl Auth {
  fn encoding_key() -> Result<EncodingKey> {
    let secret = match JWT_SECRET.get() {
      Some(secret) => secret,
      None => return Err(anyhow::anyhow!("JWT_SECRET not initialized")),
    };

    Ok(EncodingKey::from_secret(&secret))
  }

  fn decoding_key() -> Result<DecodingKey> {
    let secret = match JWT_SECRET.get() {
      Some(secret) => secret,
      None => return Err(anyhow::anyhow!("JWT_SECRET not initialized")),
    };

    Ok(DecodingKey::from_secret(&secret))
  }

  pub fn generate_token(user_id: &str, roles: Vec<Role>) -> Result<String> {
    // Expiration time is set to 7 days from now
    let exp = match chrono::Utc::now().checked_add_signed(chrono::Duration::days(7)) {
      Some(dt) => dt.timestamp(),
      None => return Err(anyhow::anyhow!("Failed to get current time").into()),
    };

    let claims = Claims {
      sub: user_id.to_string(),
      exp: exp as usize,
      roles,
    };

    let token = jsonwebtoken::encode(&jsonwebtoken::Header::default(), &claims, &Self::encoding_key()?)?;

    Ok(token)
  }

  pub fn validate_token(token: &str) -> Result<Claims> {
    let token_data =
      jsonwebtoken::decode::<Claims>(token, &Self::decoding_key()?, &jsonwebtoken::Validation::default())?;

    // Check if the token is expired
    if token_data.claims.exp < chrono::Utc::now().timestamp() as usize {
      return Err(anyhow::anyhow!("Token expired").into());
    }

    Ok(token_data.claims)
  }
}
