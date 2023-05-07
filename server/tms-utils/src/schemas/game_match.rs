use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct OnTable {
  table: String,
  team_number: String,
  score_submitted: bool
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct GameMatch {
  match_number: String,
  start_time: String,
  end_time: String,
  on_table_first: OnTable,
  on_table_second: OnTable,
  complete: bool,
  deferred: bool,
  custom_match: bool
}