
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema)]
pub struct TmsSchema {
  pub my_int: i32,
}