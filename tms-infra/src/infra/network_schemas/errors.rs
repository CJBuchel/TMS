use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;


#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct ErrorMessage {
  pub code: u16,
  pub message: String,
}

impl Default for ErrorMessage {
  fn default() -> Self {
    Self {
      code: 500,
      message: "".to_string(),
    }
  }
}

impl DataSchemeExtensions for ErrorMessage {}