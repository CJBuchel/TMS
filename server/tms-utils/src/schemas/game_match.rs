use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct OnTable {
  pub table: String,
  pub team_number: String,
  pub score_submitted: bool
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct GameMatch {
  pub match_number: String,
  pub round_number: u32,
  pub start_time: String,
  pub end_time: String,
  pub match_tables: Vec<OnTable>,
  pub complete: bool,
  pub deferred: bool,
  pub custom_match: bool
}