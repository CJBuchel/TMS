use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;

use super::TmsDateTime;

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct GameMatchTable {
  pub table: String,
  pub team_number: String,
  pub score_submitted: bool,
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct GameMatch {
  pub match_number: String,
  pub start_time: TmsDateTime,
  pub end_time: TmsDateTime,
  pub game_match_tables: Vec<GameMatchTable>,
  pub completed: bool,
}

impl Default for GameMatch {
  fn default() -> Self {
    Self {
      match_number: "".to_string(),
      start_time: TmsDateTime::default(),
      end_time: TmsDateTime::default(),
      game_match_tables: Vec::new(),
      completed: false,
    }
  }
}

impl DataSchemeExtensions for GameMatch {}