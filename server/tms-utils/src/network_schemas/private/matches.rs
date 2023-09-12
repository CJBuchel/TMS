
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct MatchLoadRequest {
  pub auth_token: String,
  pub match_numbers: Vec<String>,
}