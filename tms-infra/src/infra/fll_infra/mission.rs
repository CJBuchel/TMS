use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct Mission {
  pub id: String,
  pub label: String,
  pub image_url: Option<String>,
}

impl Default for Mission {
  fn default() -> Self {
    Self {
      id: "".to_string(),
      label: "".to_string(),
      image_url: None,
    }
  }
}

impl DataSchemeExtensions for Mission {}
