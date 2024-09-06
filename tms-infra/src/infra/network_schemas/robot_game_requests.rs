use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct RobotGamesLoadMatchRequest {
  pub game_match_numbers: Vec<String>,
}

impl Default for RobotGamesLoadMatchRequest {
  fn default() -> Self {
    Self { game_match_numbers: vec![] }
  }
}

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct RobotGameTableSignalRequest {
  pub table: String,
  pub team_number: String,
}

impl Default for RobotGameTableSignalRequest {
  fn default() -> Self {
    Self {
      table: "".to_string(),
      team_number: "".to_string(),
    }
  }
}

impl DataSchemeExtensions for RobotGamesLoadMatchRequest {}
impl DataSchemeExtensions for RobotGameTableSignalRequest {}
