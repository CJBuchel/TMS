use echo_tree_infra::DataSchemeExtensions;
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct TmsDate {
  pub year: i32, // 4-digit year
  pub month: u32, // 1-12
  pub day: u32, // 1-31
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct TmsTime {
  pub hour: u32, // 24-hour format
  pub minute: u32, // 0-59
  pub second: u32, // 0-59
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct TmsDateTime {
  pub date: Option<TmsDate>,
  pub time: Option<TmsTime>,
}

impl Default for TmsDateTime {
  fn default() -> Self {
    Self {
      date: None,
      time: None,
    }
  }
}

impl DataSchemeExtensions for TmsDateTime {}