use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::{DataSchemeExtensions, GameMatch};

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct RobotGameMatchInsertRequest {
  pub match_id: Option<String>,
  pub game_match: GameMatch,
}

impl Default for RobotGameMatchInsertRequest {
  fn default() -> Self {
    Self {
      match_id: None,
      game_match: GameMatch::default(),
    }
  }
}

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct RobotGameMatchRemoveRequest {
  pub match_id: String,
}

impl Default for RobotGameMatchRemoveRequest {
  fn default() -> Self {
    Self { match_id: "".to_string() }
  }
}

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct RobotGameMatchLoadRequest {
  pub game_match_numbers: Vec<String>,
}

impl Default for RobotGameMatchLoadRequest {
  fn default() -> Self {
    Self { game_match_numbers: vec![] }
  }
}

impl DataSchemeExtensions for RobotGameMatchInsertRequest {}
impl DataSchemeExtensions for RobotGameMatchRemoveRequest {}
impl DataSchemeExtensions for RobotGameMatchLoadRequest {}