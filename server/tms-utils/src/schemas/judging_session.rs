use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct JudgingSession {
  session: String,
  start_time: String,
  end_time: String,
  room: String,
  team_number: String,
  complete: bool,
  deferred: bool,
  custom_session: bool
}