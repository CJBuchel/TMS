use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct RobotGamesLoadMatchRequest {
  pub game_match_numbers: Vec<String>,
}

impl Default for RobotGamesLoadMatchRequest {
  fn default() -> Self {
    Self {
      game_match_numbers: vec![],
    }
  }
}

impl DataSchemeExtensions for RobotGamesLoadMatchRequest {}