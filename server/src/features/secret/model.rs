use database::Record;
use serde::{Deserialize, Serialize};

#[derive(Clone, Serialize, Deserialize)]
pub struct Secret(pub Vec<u8>);

impl Default for Secret {
  fn default() -> Self {
    Self(rand::random::<[u8; 32]>().to_vec())
  }
}

impl Record for Secret {
  fn table_name() -> &'static str {
    "jwt_secret"
  }
}
