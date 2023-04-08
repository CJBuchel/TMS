#[derive(JsonSchema, Clone)]
pub struct OnTable {
  table: String,
  team_number: String,
  score_submitted: bool
}

#[derive(JsonSchema, Clone)]
pub struct Match {
  match_number: String,
  start_time: String,
  end_time: String,
  on_table_first: OnTable,
  on_table_second: OnTable,
  complete: bool,
  deferred: bool,
  custom_match: bool
}