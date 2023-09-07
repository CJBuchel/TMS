use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct JudgingSession {
  pub session: String,
  pub start_time: String,
  pub end_time: String,
  pub pod: String,
  pub team_number: String,
  pub complete: bool,
  pub deferred: bool,
  pub custom_session: bool
}