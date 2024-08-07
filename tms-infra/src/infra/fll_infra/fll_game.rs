use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

use super::{Mission, Question};

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct FllGame {
  pub questions: Vec<Question>,
  pub missions: Vec<Mission>,
}

impl Default for FllGame {
  fn default() -> Self {
    Self {
      questions: vec![],
      missions: vec![],
    }
  }
}

impl DataSchemeExtensions for FllGame {}