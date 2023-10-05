use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::schemas::{Team, TeamGameScore};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct TeamUpdateRequest {
  pub auth_token: String,
  pub team_number: String,
  pub team_data: Team,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct TeamPostGameScoresheetRequest {
  pub auth_token: String,
  pub team_number: String,
  pub scoresheet: TeamGameScore,
}