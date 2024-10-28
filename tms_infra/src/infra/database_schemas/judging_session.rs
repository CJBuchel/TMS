use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;

use super::{TmsCategory, TmsDateTime};


#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct JudgingSessionPod {
  pub pod_name: String,
  pub team_number: String,
  pub core_values_submitted: bool,
  pub innovation_submitted: bool,
  pub robot_design_submitted: bool,
}

impl Default for JudgingSessionPod {
  fn default() -> Self {
    Self {
      pod_name: "".to_string(),
      team_number: "".to_string(),
      core_values_submitted: false,
      innovation_submitted: false,
      robot_design_submitted: false,
    }
  }
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct JudgingSession {
  pub session_number: String,
  pub start_time: TmsDateTime,
  pub end_time: TmsDateTime,
  pub judging_session_pods: Vec<JudgingSessionPod>,
  pub completed: bool,

  // category
  pub category: TmsCategory,
}

impl Default for JudgingSession {
  fn default() -> Self {
    Self {
      session_number: "".to_string(),
      start_time: TmsDateTime::default(),
      end_time: TmsDateTime::default(),
      judging_session_pods: Vec::new(),
      completed: false,
      category: TmsCategory::default(),
    }
  }
}

impl DataSchemeExtensions for JudgingSession {}
impl DataSchemeExtensions for JudgingSessionPod {}