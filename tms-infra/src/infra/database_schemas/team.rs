use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct Team {
  pub number: String,
  pub name: String,
  pub affiliation: String,
  pub ranking: u32,
}

impl Default for Team {
  fn default() -> Self {
    Self {
      number: "".to_string(),
      name: "".to_string(),
      affiliation: "".to_string(),
      ranking: 0,
    }
  }
}

impl DataSchemeExtensions for Team {}
