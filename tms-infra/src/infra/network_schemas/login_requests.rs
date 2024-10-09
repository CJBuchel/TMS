use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::{DataSchemeExtensions, TmsTreeRole};

#[derive(Serialize, Deserialize, JsonSchema)]
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

#[derive(Serialize, Deserialize, JsonSchema)]
pub struct LoginResponse {
  pub roles: Vec<TmsTreeRole>, // role id, password
}

impl Default for LoginResponse {
  fn default() -> Self {
    Self { roles: Vec::new() }
  }
}

impl DataSchemeExtensions for LoginRequest {}
impl DataSchemeExtensions for LoginResponse {}
