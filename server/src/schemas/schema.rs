
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema)]
pub struct Test {
  pub test_int: i32,
}

#[derive(JsonSchema)]
pub struct TmsSchema {
  pub my_int: Test,
}