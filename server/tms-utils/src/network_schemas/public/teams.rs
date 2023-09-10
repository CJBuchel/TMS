use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::schemas::Team;

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct TeamsResponse {
  pub teams: Vec<Team>,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct TeamRequest {
  pub team_number: String,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct TeamResponse {
  pub team: Team,
}