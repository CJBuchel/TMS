use database::Record;
use serde::{Deserialize, Serialize};

use crate::core::permissions::Role;

#[derive(Clone, Serialize, Deserialize)]
pub struct User {
  pub username: String,
  pub password: String,
  pub roles: Vec<Role>,
}

impl Default for User {
  fn default() -> Self {
    Self {
      username: "".to_string(),
      password: "".to_string(),
      roles: vec![],
    }
  }
}

impl Record for User {
  fn table_name() -> &'static str {
    "user"
  }

  fn secondary_indexes(&self) -> Vec<String> {
    vec![self.username.clone()]
  }
}
