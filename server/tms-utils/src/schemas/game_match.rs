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
  pub start_time: String,
  pub end_time: String,
  pub on_table_first: OnTable,
  pub on_table_second: OnTable,
  pub complete: bool,
  pub deferred: bool,
  pub custom_match: bool
}