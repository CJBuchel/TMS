use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::{infra::DataSchemeExtensions, Team};

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct TeamInsertRequest {
  pub team_id: Option<String>,
  pub team: Team,
}

impl Default for TeamInsertRequest {
  fn default() -> Self {
    Self {
      team_id: None,
      team: Team::default(),
    }
  }
}

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct TeamRemoveRequest {
  pub team_id: String,
}

impl Default for TeamRemoveRequest {
  fn default() -> Self {
    Self {
      team_id: "".to_string(),
    }
  }
}

impl DataSchemeExtensions for TeamInsertRequest {}
impl DataSchemeExtensions for TeamRemoveRequest {}