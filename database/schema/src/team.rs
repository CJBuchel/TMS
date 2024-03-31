use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::SchemaUtil;


#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct Team {
  pub cloud_id: String,
  pub number: String,
  pub name: String,
  pub affiliation: String,
  pub ranking: u32,
}

impl Default for Team {
  fn default() -> Self {
    Self {
      cloud_id: "".to_string(),
      number: "".to_string(),
      name: "".to_string(),
      affiliation: "".to_string(),
      ranking: 0,
    }
  }
}

impl SchemaUtil for Team {
  fn get_schema() -> String {
    let schema = schemars::schema_for!(Team);
    serde_json::to_string_pretty(&schema).unwrap_or_default()
  }
}