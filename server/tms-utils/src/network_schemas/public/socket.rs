use schemars::JsonSchema;
use serde::{Deserialize, Serialize};


#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct SocketMessage {
  pub from_id: Option<String>,
  pub topic: String, // Timer, Teams, Event, JudgingSessions
  pub message: String
}