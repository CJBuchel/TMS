use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct TmsCategory {
  pub category: String,
  pub sub_categories: Vec<String>,
}

impl Default for TmsCategory {
  fn default() -> Self {
    Self {
      category: "".to_string(),
      sub_categories: vec![],
    }
  }
}


impl DataSchemeExtensions for TmsCategory {}