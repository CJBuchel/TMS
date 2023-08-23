use schemars::JsonSchema;
use serde::{Deserialize, Serialize};


#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct SocketMessage {
  pub from_id: Option<String>,
  pub topic: String, // clock, team, event, etc
  pub sub_topic: Option<String>, // time, start, update i.e (clock:time, event:update)
  pub message: Option<String>
}