use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

use super::{Mission, Question};

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct FllBlueprint {
  pub robot_game_questions: Vec<Question>,
  pub robot_game_missions: Vec<Mission>,
}

impl Default for FllBlueprint {
  fn default() -> Self {
    Self {
      robot_game_questions: vec![],
      robot_game_missions: vec![],
    }
  }
}

impl DataSchemeExtensions for FllBlueprint {}
