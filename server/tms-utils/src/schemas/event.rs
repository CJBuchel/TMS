use schemars::JsonSchema;
use serde::{Serialize, Deserialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct OnlineLink {
  tournament_id: String,
  tournament_token: String,
  linked: bool
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct Event {
  pub name: String,
  pub tables: Vec<String>,
  pub pods: Vec<String>,
  pub event_rounds: u8,
  pub season: String,
  pub online_link: OnlineLink
}