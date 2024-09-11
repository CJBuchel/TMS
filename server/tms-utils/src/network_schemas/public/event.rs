
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::schemas::Event;

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct EventResponse {
  pub event: Event,
}