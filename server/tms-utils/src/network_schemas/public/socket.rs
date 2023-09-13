use schemars::JsonSchema;
use serde::{Deserialize, Serialize};


#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct SocketMessage {
  pub from_id: Option<String>,
  pub topic: String, // clock, team, event, etc
  pub sub_topic: String, // time, start, update i.e (clock:time, event:update)
  pub message: Option<String>
}

// Sent over the SocketMessage::message in serialized form
#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct SocketMatchLoadedMessage{
  pub match_numbers: Vec<String>,
}