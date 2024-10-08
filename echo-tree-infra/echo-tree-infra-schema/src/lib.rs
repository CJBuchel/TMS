use schemars::JsonSchema;
use serde::{de::DeserializeOwned, Serialize};

mod echo_tree_schemas;
pub use echo_tree_schemas::*;

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