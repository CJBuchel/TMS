use schemars::JsonSchema;

use crate::DataSchemeExtensions;

#[derive(serde::Deserialize, serde::Serialize, Clone, JsonSchema)]
pub struct TmsServerTableStateEvent {
  pub table: String,
  pub team_number: String,
}

impl Default for TmsServerTableStateEvent {
  fn default() -> Self {
    Self {
      table: "".to_string(),
      team_number: "".to_string(),
    }
  }
}

impl DataSchemeExtensions for TmsServerTableStateEvent {}