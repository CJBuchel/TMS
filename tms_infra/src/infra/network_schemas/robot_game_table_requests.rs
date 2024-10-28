use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct RobotGameTableSignalRequest {
  pub table: String,
  pub team_number: String,
}

impl Default for RobotGameTableSignalRequest {
  fn default() -> Self {
    Self {
      table: "".to_string(),
      team_number: "".to_string(),
    }
  }
}

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct RobotGameTableInsertRequest {
  pub table_id: Option<String>,
  pub table: String,
}

impl Default for RobotGameTableInsertRequest {
  fn default() -> Self {
    Self {
      table_id: None,
      table: "".to_string(),
    }
  }
}

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct RobotGameTableRemoveRequest {
  pub table_id: String,
}

impl Default for RobotGameTableRemoveRequest {
  fn default() -> Self {
    Self {
      table_id: "".to_string(),
    }
  }
}

impl DataSchemeExtensions for RobotGameTableSignalRequest {}
impl DataSchemeExtensions for RobotGameTableInsertRequest {}
impl DataSchemeExtensions for RobotGameTableRemoveRequest {}