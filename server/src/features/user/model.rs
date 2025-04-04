use async_graphql::InputObject;
use database::Record;
use serde::{Deserialize, Serialize};

#[derive(Clone, Serialize, Deserialize, InputObject)]
pub struct User {
  pub username: String,
  pub password: String,
}

impl Default for User {
  fn default() -> Self {
    Self {
      username: "".to_string(),
      password: "".to_string(),
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
