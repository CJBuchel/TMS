// use schemars::JsonSchema;
// use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Clone)]
pub struct OnlineLink {
  tournament_id: String,
  tournament_token: String,
  linked: bool
}

#[derive(JsonSchema, Clone)]
pub struct Event {
  name: String,
  tables: Vec<String>,
  pods: Vec<String>,
  event_rounds: u8,
  season: String,
  online_link: OnlineLink
}