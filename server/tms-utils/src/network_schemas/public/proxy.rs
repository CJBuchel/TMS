use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct ProxyBytesResponse {
  pub bytes: Vec<u8>
}