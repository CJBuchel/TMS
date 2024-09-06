use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct User {
  pub username: String,
  pub password: String,
  pub roles: Vec<String>, // roles from the role manager
}

impl Default for User {
  fn default() -> Self {
    Self {
      username: "".to_string(),
      password: "".to_string(),
      roles: vec!["public".to_string()],
    }
  }
}

impl DataSchemeExtensions for User {}
