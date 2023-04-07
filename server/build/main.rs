use std::{env, fs};

mod schema_generator;
mod env_generator;

use crate::schema_generator::generate_schema;
use crate::env_generator::generate_env;
use crate::env_generator::generate_env_yaml;

use std::ffi::OsString;
use std::fs::read_dir;
use std::path::PathBuf;
use std::io;
use std::io::ErrorKind;


pub fn get_project_root() -> io::Result<PathBuf> {
  let path = env::current_dir()?;
  let mut path_ancestors = path.as_path().ancestors();

  while let Some(p) = path_ancestors.next() {
    let has_cargo =
      read_dir(p)?
        .into_iter()
        .any(|p| p.unwrap().file_name() == OsString::from("Cargo.lock"));
    if has_cargo {
      return Ok(PathBuf::from(p))
    }
  }
  Err(io::Error::new(ErrorKind::NotFound, "Ran out of places to find Cargo.toml"))
}


fn main() -> anyhow::Result<()> {

  // Generate dotenv files
  let env_rust_dir = get_project_root().unwrap();
  generate_env(&env_rust_dir.clone().into_os_string()); // generate rust env
  generate_env(&env_rust_dir.clone().join("../").into_os_string()); // generate root env
  generate_env(&env_rust_dir.clone().join("../tms").into_os_string()); // generate flutter env

  // Generate azure env yaml
  generate_env_yaml(&env_rust_dir.clone().join("../azure").into_os_string());

  // Generate Schema file
  let schema_dir = get_project_root().unwrap();
  let schema_dir = schema_dir.join("../schema");
  fs::create_dir_all(schema_dir.clone()).unwrap();
  generate_schema(&schema_dir.into_os_string());

  Ok(())
}