use schemars::JsonSchema;
use serde::{Deserialize, Serialize};


#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct RegisterRequest {
  pub username: Option<String>, // optionally log in with username/password
  pub password: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct RegisterResponse {
  pub auth_token: String,
  pub uuid: String,
  pub url: String,
}