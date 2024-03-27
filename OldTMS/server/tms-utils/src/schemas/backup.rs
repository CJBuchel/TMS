use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct Backup {
  pub entry: String,
  pub unix_timestamp: u64,
}