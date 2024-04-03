use schemars::JsonSchema;
use serde::{de::DeserializeOwned, Serialize};

mod register_requests;
pub use register_requests::*;

mod errors;
pub use errors::*;

pub trait DataSchemeExtensions: Default + JsonSchema + Serialize + DeserializeOwned {
  fn to_schema() -> String {
    let schema = schemars::schema_for!(Self);
    serde_json::to_string_pretty(&schema).unwrap_or_default()
  }

  fn to_json(&self) -> String {
    serde_json::to_string_pretty(&self).unwrap_or_default()
  }

  fn from_schema(schema: &str) -> Self {
    serde_json::from_str(schema).unwrap_or_default()
  }
}