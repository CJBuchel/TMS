use anyhow::{Ok, Result};
use jsonwebtoken::{DecodingKey, EncodingKey};
use once_cell::sync::Lazy;
use serde::{Deserialize, Serialize};

// lazy once cell
pub static JWT_SECRET: Lazy<Vec<u8>> = Lazy::new(|| {
  log::info!("Initializing JWT secret");
  rand::random::<[u8; 32]>().to_vec()
});

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
  pub sub: String, // User ID
                   // pub exp: usize,
}

pub struct Auth;

impl Auth {
  fn encoding_key() -> EncodingKey {
    EncodingKey::from_secret(&JWT_SECRET)
  }

  fn decoding_key() -> DecodingKey {
    DecodingKey::from_secret(&JWT_SECRET)
  }

  pub fn generate_token(user_id: &str) -> Result<String> {
    let claims = Claims {
      sub: user_id.to_string(),
    };

    let token = jsonwebtoken::encode(&jsonwebtoken::Header::default(), &claims, &Self::encoding_key())?;

    Ok(token)
  }

  pub fn validate_token(token: &str) -> Result<Claims> {
    let token_data =
      jsonwebtoken::decode::<Claims>(token, &Self::decoding_key(), &jsonwebtoken::Validation::default())?;
    Ok(token_data.claims)
  }
}
