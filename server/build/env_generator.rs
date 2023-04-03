use std::borrow::Borrow;
use std::ffi::OsString;
use std::fs::{self, File};
use std::io::{BufWriter, Write};
use std::path::Path;

use serde::Serialize;

#[derive(Debug, Serialize)]
struct YamlEnv {
  version: String
}

#[derive(Debug, Serialize)]
struct YamlVariables {
  variables: YamlEnv
}

pub fn generate_env(outdir: &OsString) {
  let version = "2023.0.0";

  let env: Vec<String> = [
    format!("TMS_TAG={}\n", version),
    format!("DOCKER_TAG={}\n", version)
  ].to_vec();

  let env_path = Path::new(outdir).join(".env");
  let f = File::create(env_path).expect("Unable to create file");
  let mut f = BufWriter::new(f);


  for line in &env {
    f.write_all(line.as_bytes()).expect("Could not write to file");
  }

  // Yaml Env
  let yaml:YamlVariables = YamlVariables { variables: YamlEnv { version: version.to_string() } };
  let env_path = Path::new(outdir).join("env.yaml");
  let f = File::create(env_path).expect("Could not write to file");
  serde_yaml::to_writer(f, &yaml).unwrap();
}