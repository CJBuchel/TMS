use std::{env, fs};

mod schema_generator;

use crate::schema_generator::generate_schema;
use std::ffi::OsString;
use std::fs::read_dir;
use std::path::{PathBuf, Path};
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


macro_rules! p {
  ($($tokens: tt)*) => {
    println!("cargo:warning=BUILD.rs -> {}", format!($($tokens)*))
  };
}

fn main() -> anyhow::Result<()> {
  p!("Generating Schemas...");

  let outdir = get_project_root().unwrap();
  // p!("Path {}", outdir);
  // for (key, value) in env::vars_os() {
  //   p!("{key:?}: {value:?}");
  // }

  let outdir = outdir.join("../schema");
  fs::create_dir_all(outdir.clone()).unwrap();
  generate_schema(&outdir.into_os_string());

  Ok(())
}