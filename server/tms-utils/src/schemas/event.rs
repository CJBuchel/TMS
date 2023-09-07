use schemars::JsonSchema;
use serde::{Serialize, Deserialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct OnlineLink {
  tournament_id: String,
  tournament_token: String,
  linked: bool
}

impl OnlineLink {
  pub fn new() -> Self {
    Self {
      tournament_id: String::from(""),
      tournament_token: String::from(""),
      linked: false
    }
  }
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct Event {
  pub name: String,
  pub timer_length: u32, // time in seconds the match takes i.e 150 is default
  pub tables: Vec<String>,
  pub pods: Vec<String>,
  pub event_rounds: u8,
  pub season: String,
}

impl Event {
  pub fn new() -> Self {
    Self {
      name: String::from(""),
      timer_length: 150,
      tables: Vec::new(),
      pods: Vec::new(),
      event_rounds: 3,
      season: String::from(""),
    }
  }
}