use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct Mission {
  pub id: String,
  pub label: String,
  pub image_url: String,
}

impl Default for Mission {
  fn default() -> Self {
    Self {
      id: "".to_string(),
      label: "".to_string(),
      image_url: "".to_string(),
    }
  }
}

impl DataSchemeExtensions for Mission {}