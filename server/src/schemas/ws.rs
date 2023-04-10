use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct RegisterRequest {
  pub user_id: String,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct RegisterResponse {
  pub url: String
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct SocketEvent {
  pub topic: String,
  pub user_id: Option<String>,
  pub message: String
}