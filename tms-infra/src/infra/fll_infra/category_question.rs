use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct CategoricalOption {
  pub label: String, // label for this option e.g "Yes"
  pub score: i32, // score for this option e.g 1
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct CategoricalQuestion {
  pub options: Vec<CategoricalOption>,
  pub default_option: String,
}

impl Default for CategoricalQuestion {
  fn default() -> Self {
    Self {
      options: vec![],
      default_option: "".to_string(),
    }
  }
}

impl DataSchemeExtensions for CategoricalQuestion {}