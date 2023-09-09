use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::schemas::GameMatch;

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct MatchesResponse {
  pub matches: Vec<GameMatch>,
}