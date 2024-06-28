use schemars::JsonSchema;
use serde::{de::DeserializeOwned, Serialize};

mod network_schemas;
pub use network_schemas::*;

mod database_schemas;
pub use database_schemas::*;

#[derive(serde::Deserialize, serde::Serialize, Clone, JsonSchema)]
pub struct TmsTreeRole {
  pub role_id: String,
  pub password: String,
  pub read_echo_trees: Vec<String>, // list of topics/trees the role can read from
  pub read_write_echo_trees: Vec<String>, // list of topics/trees the role can write to
}

pub trait DataSchemeExtensions: Default + JsonSchema + Serialize + DeserializeOwned {
  fn to_schema() -> String {
    let schema = schemars::schema_for!(Self);
    serde_json::to_string_pretty(&schema).unwrap_or_default()
  }

  fn to_json(&self) -> String {
    serde_json::to_string_pretty(&self).unwrap_or_default()
  }

  fn from_json(json: &str) -> Self {
    serde_json::from_str(json).unwrap_or_default()
  }
}