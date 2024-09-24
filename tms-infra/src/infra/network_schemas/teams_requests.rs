use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::{infra::DataSchemeExtensions, Team};

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct TeamsAddTeamRequest {
  pub team: Team,
}

impl Default for TeamsAddTeamRequest {
  fn default() -> Self {
    Self {
      team: Team::default(),
    }
  }
}

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

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct TeamsRemoveTeamRequest {
  pub team_id: String,
}

impl Default for TeamsRemoveTeamRequest {
  fn default() -> Self {
    Self {
      team_id: "".to_string(),
    }
  }
}

impl DataSchemeExtensions for TeamsAddTeamRequest {}
impl DataSchemeExtensions for TeamsUpdateTeamRequest {}
impl DataSchemeExtensions for TeamsRemoveTeamRequest {}