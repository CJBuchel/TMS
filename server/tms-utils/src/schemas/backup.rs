use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct Backup {
  pub entry: String,
  pub timestamp_pretty: String,
  pub timestamp: u64,
}