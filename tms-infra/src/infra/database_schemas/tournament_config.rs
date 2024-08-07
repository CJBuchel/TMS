use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::{infra::DataSchemeExtensions, SeasonType};

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct TournamentConfig {
  pub name: String,
  pub backup_interval: u32, // in minutes
  pub retain_backups: u32, // number of backups retained
  pub end_game_timer_length: u32, // in seconds
  pub timer_length: u32, // in seconds
  pub season: Option<String>, // season year (none for no season/agnostic)
  pub season_type: SeasonType,
}

impl Default for TournamentConfig {
  fn default() -> Self {
    Self {
      name: "".to_string(),
      backup_interval: 10,
      retain_backups: 5,
      end_game_timer_length: 30,
      timer_length: 150,
      season_type: SeasonType::Agnostic,
      season: None,
    }
  }
}

impl DataSchemeExtensions for TournamentConfig {}