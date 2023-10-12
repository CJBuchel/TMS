use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct JudgingPod {
  pub pod: String,
  pub team_number: String,
  pub score_submitted: bool,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct JudgingSession {
  pub session_number: String,
  pub start_time: String,
  pub end_time: String,
  pub judging_pods: Vec<JudgingPod>,
  pub complete: bool,
  pub deferred: bool,
}