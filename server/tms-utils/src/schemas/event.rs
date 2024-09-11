use schemars::JsonSchema;
use serde::{Serialize, Deserialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct APILink {
  pub tournament_id: String,
  pub tournament_token: String,
  pub linked: bool
}

impl APILink {
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
  pub backup_interval: u32, // time in minutes between backups
  pub backup_count: usize, // number of backups to keep
  pub end_game_timer_length: u32, // 30 seconds is the default
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
      backup_interval: 10,
      backup_count: 6,
      end_game_timer_length: 30,
      timer_length: 150,
      tables: Vec::new(),
      pods: Vec::new(),
      event_rounds: 3,
      season: String::from(""),
    }
  }
}