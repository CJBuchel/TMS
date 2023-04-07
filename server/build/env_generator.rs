use std::ffi::OsString;
use std::fs::{self, File};
use std::io::{BufWriter, Write};
use std::path::Path;

use serde::Serialize;

// variables:
//   - name: version
//     value: '2023.0.0'


#[derive(Debug, Serialize)]
struct YamlEnv {
  name: String,
  value: String
}

#[derive(Debug, Serialize)]
struct YamlVariables {
  variables: Vec<YamlEnv>
}

const VERSION: &str = "2023.0.0";

pub fn generate_env(outdir: &OsString) {

  let env: Vec<String> = [
    format!("TMS_TAG={}\n", VERSION),
    format!("DOCKER_TAG={}\n", VERSION)
  ].to_vec();

  let env_path = Path::new(outdir).join(".env");
  let f = File::create(env_path).expect("Unable to create file");
  let mut f = BufWriter::new(f);

  for line in &env {
    f.write_all(line.as_bytes()).expect("Could not write to file");
  }
}

pub fn generate_env_yaml(outdir: &OsString) {
  // Yaml Env
  let mut yaml:YamlVariables = YamlVariables { variables: Vec::new() };
  yaml.variables.push(YamlEnv { name: "version".to_string(), value: VERSION.to_string() });
  let env_path = Path::new(outdir).join("vars.yml");
  let f = File::create(env_path).expect("Could not write to file");
  serde_yaml::to_writer(f, &yaml).unwrap();
}