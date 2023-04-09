use schemars::JsonSchema;
use serde::{Deserialize, Serialize};
#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct User {
  pub username: String,
  pub password: String
}