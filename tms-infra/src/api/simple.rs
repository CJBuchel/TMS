use serde::{Deserialize, Serialize};


pub trait ToJson<'a>: Serialize + Deserialize<'a> {
  fn to_json(&self) -> String {
    serde_json::to_string(self).unwrap()
  }

  fn from_json(json: &'a str) -> Result<Self, serde_json::Error>
  where
    Self: Sized,
  {
    serde_json::from_str(json)
  }
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct TestStruct {
  pub name: String,
  pub age: i32,
}

impl ToJson<'_> for TestStruct {}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
  // Default utilities - feel free to customize
  flutter_rust_bridge::setup_default_user_utils();
}
