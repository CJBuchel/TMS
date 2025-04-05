use async_graphql::InputObject;
use database::Record;
use serde::{Deserialize, Serialize};

#[derive(Clone, Serialize, Deserialize, InputObject)]
pub struct TournamentConfig {
  pub event_name: String,
  pub backup_interval: u32,        // In minutes
  pub backup_retention: u32,       // In days
  pub end_game_timer_trigger: u32, // In seconds
  pub timer_length: u32,           // In seconds
  pub season: Option<String>,      // Season ear (non for agnostic)
}

impl Default for TournamentConfig {
  fn default() -> Self {
    Self {
      event_name: "".to_string(),
      backup_interval: 10,
      backup_retention: 5,
      end_game_timer_trigger: 30,
      timer_length: 150,
      season: None,
    }
  }
}

impl Record for TournamentConfig {
  fn table_name() -> &'static str {
    "tournament_config"
  }

  fn secondary_indexes(&self) -> Vec<String> {
    vec![
      self.event_name.clone(),
      self.backup_interval.to_string(),
      self.backup_retention.to_string(),
      self.end_game_timer_trigger.to_string(),
      self.timer_length.to_string(),
      self.season.clone().unwrap_or("".to_string()),
    ]
  }
}
