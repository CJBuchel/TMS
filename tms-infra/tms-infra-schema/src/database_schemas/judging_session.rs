use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct JudgingSessionPod {
  pub pod: String,
  pub team_number: String,
  pub core_values_submitted: bool,
  pub innovation_submitted: bool,
  pub robot_design_submitted: bool,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct JudgingSession {
  pub session_number: String,
  pub start_time: String,
  pub end_time: String,
  pub judging_session_pods: Vec<JudgingSessionPod>,
}

impl Default for JudgingSession {
  fn default() -> Self {
    Self {
      session_number: "".to_string(),
      start_time: "".to_string(),
      end_time: "".to_string(),
      judging_session_pods: Vec::new(),
    }
  }
}

impl DataSchemeExtensions for JudgingSession {}