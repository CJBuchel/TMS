use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::{DataSchemeExtensions, FllBlueprint};

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct TournamentBlueprint {
  pub title: String,
  pub blueprint: FllBlueprint,
}

impl Default for TournamentBlueprint {
  fn default() -> Self {
    Self {
      title: "".to_string(),
      blueprint: FllBlueprint::default(),
    }
  }
}

impl DataSchemeExtensions for TournamentBlueprint {}