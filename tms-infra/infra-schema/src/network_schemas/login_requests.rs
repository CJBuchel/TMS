use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct LoginRequest {
  pub username: String, // optionally log in with username/password
  pub password: String,
}

impl Default for LoginRequest {
  fn default() -> Self {
    Self {
      username: "".to_string(),
      password: "".to_string(),
    }
  }
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct LoginResponse {
  pub roles: Vec<String>, // list of roles the user has 
}

impl Default for LoginResponse {
  fn default() -> Self {
    Self {
      roles: vec![],
    }
  }
}

impl DataSchemeExtensions for LoginRequest {}
impl DataSchemeExtensions for LoginResponse {}