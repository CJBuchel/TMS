use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::schemas::JudgingSession;

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct JudgingSessionUpdateRequest {
  pub auth_token: String,
  pub session_number: String,
  pub judging_session: JudgingSession,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct JudgingSessionDeleteRequest {
  pub auth_token: String,
  pub session_number: String,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct JudgingSessionAddRequest {
  pub auth_token: String,
  pub judging_session: JudgingSession,
}