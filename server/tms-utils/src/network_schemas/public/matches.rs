use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::schemas::GameMatch;

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct MatchesResponse {
  pub matches: Vec<GameMatch>,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct MatchRequest {
  pub match_number: String,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct MatchResponse {
  pub game_match: GameMatch,
}