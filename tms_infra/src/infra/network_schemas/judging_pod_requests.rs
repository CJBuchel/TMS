use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct JudgingPodInsertRequest {
  pub pod_id: Option<String>,
  pub pod: String,
}

impl Default for JudgingPodInsertRequest {
  fn default() -> Self {
    Self {
      pod_id: None,
      pod: "".to_string(),
    }
  }
}

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct JudgingPodRemoveRequest {
  pub pod_id: String,
}

impl Default for JudgingPodRemoveRequest {
  fn default() -> Self {
    Self {
      pod_id: "".to_string(),
    }
  }
}

impl DataSchemeExtensions for JudgingPodInsertRequest {}
impl DataSchemeExtensions for JudgingPodRemoveRequest {}