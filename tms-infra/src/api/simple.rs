use serde::{Deserialize, Serialize};


pub trait ToJson: Serialize {
  fn to_json(&self) -> String {
    serde_json::to_string(self).unwrap()
  }
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct TestStruct {
  pub name: String,
  pub age: i32,
}

impl ToJson for TestStruct {}

// pub fn tms_serialize<V>(data: V) -> Result<String, ()> {
//   // convert test struct to json string
//   let test_struct = TestStruct {
//     name: "John".to_string(),
//     age: 30,
//   };

//   let json_string = serde_json::to_string(&test_struct).unwrap();

//   return Ok(json_string);
// }

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
  // Default utilities - feel free to customize
  flutter_rust_bridge::setup_default_user_utils();
}
