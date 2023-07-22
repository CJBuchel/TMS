use schemars::JsonSchema;
use serde::{Deserialize, Serialize};


#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct RegisterRequest {
  pub user_id: String,
  pub key: String
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct RegisterResponse {
  pub key: String,
  pub url: String,
}