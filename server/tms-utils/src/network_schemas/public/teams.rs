use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::schemas::Team;

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct TeamsResponse {
  pub teams: Vec<Team>,
}