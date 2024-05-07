use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct GameMatchTable {
  pub table: String,
  pub team_number: String,
  pub score_submitted: bool,
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct GameMatch {
  pub match_number: String,
  pub start_time: String,
  pub end_time: String,
  pub game_match_tables: Vec<GameMatchTable>,
}

impl Default for GameMatch {
  fn default() -> Self {
    Self {
      match_number: "".to_string(),
      start_time: "".to_string(),
      end_time: "".to_string(),
      game_match_tables: Vec::new(),
    }
  }
}

impl DataSchemeExtensions for GameMatch {}