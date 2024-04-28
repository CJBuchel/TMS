use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::{DataSchemeExtensions, EchoTreeRole};


#[derive(Serialize, Deserialize, JsonSchema)]
pub struct RegisterRequest {
  pub username: Option<String>, // optionally log in with username/password
  pub password: Option<String>,
}

impl Default for RegisterRequest {
  fn default() -> Self {
    Self {
      username: None,
      password: None,
    }
  }
}

#[derive(Serialize, Deserialize, JsonSchema)]
pub struct RegisterResponse {
  pub auth_token: String,
  pub uuid: String,
  pub url: String,
  pub server_ip: String,
  pub roles: Vec<EchoTreeRole>,
}

impl Default for RegisterResponse {
  fn default() -> Self {
    Self {
      auth_token: "".to_string(),
      uuid: "".to_string(),
      url: "".to_string(),
      server_ip: "".to_string(),
      roles: Vec::new(),
    }
  }
}

impl DataSchemeExtensions for RegisterRequest {}
impl DataSchemeExtensions for RegisterResponse {}