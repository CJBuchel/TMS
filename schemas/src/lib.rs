use std::ffi::CStr;
use std::os::raw::c_char;


struct SchemaTest {
  data: bool,
}

#[no_mangle]
pub extern "C" fn schema_func() {
  let test_Data = SchemaTest { data: true };
  println!("Data: {}", test_Data.data);
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn it_works() {
    let test_data = SchemaTest { data: true };
    println!("Data: {}", test_data.data);
  }
}
