use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::{infra::DataSchemeExtensions, Team};

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct TeamsUpdateTeamRequest {
  pub team_id: String,
  pub team: Team,
}

impl Default for TeamsUpdateTeamRequest {
  fn default() -> Self {
    Self {
      team_id: "".to_string(),
      team: Team::default(),
    }
  }
}

impl DataSchemeExtensions for TeamsUpdateTeamRequest {}