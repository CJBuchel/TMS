use schemars::JsonSchema;
use serde::{Deserialize, Serialize};


#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct IntegrityMessage {
  pub message: String,
}