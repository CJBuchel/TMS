use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub enum Season {
  FllAgnostic,
  Fll2023,
}


impl Default for Season {
  fn default() -> Self {
    Self::FllAgnostic
  }
}

impl DataSchemeExtensions for Season {}