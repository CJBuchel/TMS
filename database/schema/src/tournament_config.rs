use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct TournamentConfig {
  pub name: String,
  pub backup_interval: u32, // in minutes
  pub backup_count: u32, // number of backups retained
  pub end_game_timer_length: u32, // in seconds
  pub timer_length: u32, // in seconds
  pub season: String,
}

impl Default for TournamentConfig {
  fn default() -> Self {
    Self {
      name: "".to_string(),
      backup_interval: 10,
      backup_count: 6,
      end_game_timer_length: 30,
      timer_length: 150,
      season: "".to_string(),
    }
  }
}

impl DataSchemeExtensions for TournamentConfig {
  fn get_schema() -> String {
    let schema = schemars::schema_for!(TournamentConfig);
    serde_json::to_string_pretty(&schema).unwrap_or_default()
  }
}