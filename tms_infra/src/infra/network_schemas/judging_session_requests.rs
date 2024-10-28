use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::{DataSchemeExtensions, JudgingSession};

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct JudgingSessionInsertRequest {
  pub session_id: Option<String>,
  pub session: JudgingSession,
}

impl Default for JudgingSessionInsertRequest {
  fn default() -> Self {
    Self {
      session_id: None,
      session: JudgingSession::default(),
    }
  }
}

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct JudgingSessionRemoveRequest {
  pub session_id: String,
}

impl Default for JudgingSessionRemoveRequest {
  fn default() -> Self {
    Self {
      session_id: "".to_string(),
    }
  }
}

impl DataSchemeExtensions for JudgingSessionInsertRequest {}
impl DataSchemeExtensions for JudgingSessionRemoveRequest {}