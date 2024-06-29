use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;


#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct GameTable {
  pub table_name: String,
}

impl Default for GameTable {
  fn default() -> Self {
    Self {
      table_name: "".to_string(),
    }
  }
}

impl DataSchemeExtensions for GameTable {}