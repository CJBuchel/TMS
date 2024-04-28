use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;


#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct TournamentConfigSetNameRequest {
  pub name: String,
}

impl Default for TournamentConfigSetNameRequest {
  fn default() -> Self {
    Self {
      name: "".to_string(),
    }
  }
}

impl DataSchemeExtensions for TournamentConfigSetNameRequest {}