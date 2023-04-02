use std::borrow::Borrow;
use std::ffi::OsString;
use std::fs::{self, File};
use std::io::{BufWriter, Write};
use std::path::Path;


pub fn generate_env(outdir: &OsString) {
  let version = "2023.0.0";


  let env = [
    format!("TMS_TAG={}\n", version),
    format!("DOCKER_TAG={}\n", version)
  ];

  let env_path = Path::new(outdir).join(".env");
  let f = File::create(env_path).expect("Unable to create file");
  let mut f = BufWriter::new(f);


  for line in &env {
    f.write_all(line.as_bytes());
  }
}