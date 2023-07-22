use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::schemas::Permissions;


#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct LoginRequest {
  pub username: String,
  pub password: String
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct LoginResponse {
  pub auth_token: String,
  pub permissions: Permissions
}