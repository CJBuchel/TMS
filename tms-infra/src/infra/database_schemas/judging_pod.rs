use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct JudgingPod {
  pub pod_name: String,
}

impl Default for JudgingPod {
  fn default() -> Self {
    Self { pod_name: "".to_string() }
  }
}

impl DataSchemeExtensions for JudgingPod {}
