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

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct IntegrityMessage {
  pub message: String,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct SocketMessage {
  pub from_id: Option<String>,
  pub topic: String, // Timer, Teams, Event, JudgingSessions
  pub message: String
}