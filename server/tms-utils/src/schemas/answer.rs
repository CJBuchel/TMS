use schemars::JsonSchema;
use serde::{Deserialize, Serialize};
#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct Answer {
  id: String,
  answer: String
}