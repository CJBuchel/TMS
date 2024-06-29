use serde::{Deserialize, Serialize};


pub trait ToJson<'a>: Serialize + Deserialize<'a> {

  #[flutter_rust_bridge::frb(sync)]
  fn to_json(&self) -> String {
    serde_json::to_string(self).unwrap()
  }

  #[flutter_rust_bridge::frb(sync)]
  fn from_json(json: &'a str) -> Result<Self, serde_json::Error>
  where
    Self: Sized,
  {
    serde_json::from_str(json)
  }
}

#[derive(Clone, Debug, Serialize, Deserialize)]
#[flutter_rust_bridge::frb(sync)]
pub struct TestStruct {
  pub name: String,
  pub age: i32,
}

// #[flutter_rust_bridge::frb(sync)]
// pub fn test_output(v: TestStruct) -> String {
//   v.name
// }

impl ToJson<'_> for TestStruct {}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
  // Default utilities - feel free to customize
  flutter_rust_bridge::setup_default_user_utils();
}
