use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::schemas::JudgingSession;

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct JudgingSessionsResponse {
  pub judging_sessions: Vec<JudgingSession>,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct JudgingSessionRequest {
  pub session_number: String,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct JudgingSessionResponse {
  pub judging_session: JudgingSession,
}