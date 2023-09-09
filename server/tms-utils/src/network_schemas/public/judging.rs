use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::schemas::JudgingSession;

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct JudgingSessionsResponse {
  pub judging_sessions: Vec<JudgingSession>,
}