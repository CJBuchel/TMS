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
  pub update_match: bool, // only exists for table scoring
  pub match_number: Option<String>, // only exists for table scoring
  pub table: Option<String>, // only exists for table scoring
  pub scoresheet: TeamGameScore,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct TeamDeleteRequest {
  pub auth_token: String,
  pub team_number: String,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct TeamAddRequest {
  pub auth_token: String,
  pub team_number: String,
  pub team_name: String,
  pub team_affiliation: String,
}