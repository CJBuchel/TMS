use schemars::JsonSchema;
use serde::{de::DeserializeOwned, Serialize};

pub mod network_schemas;
pub mod database_schemas;
pub mod fll_infra;

pub trait DataSchemeExtensions: Default + Serialize + JsonSchema + DeserializeOwned {
  #[flutter_rust_bridge::frb(sync)]
  fn to_schema() -> String {
    let schema = schemars::schema_for!(Self);
    serde_json::to_string_pretty(&schema).unwrap_or_default()
  }

  #[flutter_rust_bridge::frb(sync)]
  fn to_json_string(&self) -> String {
    serde_json::to_string_pretty(&self).unwrap_or_default()
  }

  #[flutter_rust_bridge::frb(sync)]
  fn from_json_string(json: &str) -> Self {
    serde_json::from_str(json).unwrap_or_default()
  }
}


#[derive(serde::Deserialize, serde::Serialize, Clone, JsonSchema)]
pub struct TmsTreeRole {
  pub role_id: String,
  pub password: String,
  pub read_echo_trees: Vec<String>, // list of topics/trees the role can read from
  pub read_write_echo_trees: Vec<String>, // list of topics/trees the role can write to
}

impl Default for TmsTreeRole {
  fn default() -> Self {
    Self {
      role_id: "".to_string(),
      password: "".to_string(),
      read_echo_trees: vec![],
      read_write_echo_trees: vec![],
    }
  }
}

impl DataSchemeExtensions for TmsTreeRole {}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
  // Default utilities - feel free to customize
  flutter_rust_bridge::setup_default_user_utils();
}