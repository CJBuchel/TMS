use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct ProxyImageRequest {
  pub url: String
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct ProxyImageResponse {
  pub image: Vec<u8>
}