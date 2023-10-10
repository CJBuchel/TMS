
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::schemas::GameMatch;

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct MatchLoadRequest {
  pub auth_token: String,
  pub match_numbers: Vec<String>,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct MatchUpdateRequest {
  pub auth_token: String,
  pub match_number: String,
  pub match_data: GameMatch,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct MatchDeleteRequest {
  pub auth_token: String,
  pub match_number: String,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct MatchAddRequest {
  pub auth_token: String,
  pub match_data: GameMatch,
}