
use std::{fs, path::PathBuf};

use tms_infra_schema::*;
use schemars::JsonSchema;

#[derive(JsonSchema)]
struct DatabaseSchema {
  _team: Team,
  _tournament_config: TournamentConfig,
}

#[derive(JsonSchema)]
struct NetworkSchema {
  _register_request: RegisterRequest,
  _register_response: RegisterResponse,
  _login_request: LoginRequest,
  _login_response: LoginResponse,
  _tournament_config_set_name_request: TournamentConfigSetNameRequest,
}

fn get_workspace_path() -> std::io::Result<PathBuf> {
  let path = std::env::current_dir()?;
  let mut path_ancestors = path.ancestors();

  while let Some(p) = path_ancestors.next() {
    let cargo_toml_path = p.join("Cargo.toml");
    if cargo_toml_path.exists() {
      let contents = fs::read_to_string(&cargo_toml_path)?;
      if contents.contains("[workspace]") {
        return Ok(p.to_path_buf());
      }
    }
  }

  Err(std::io::Error::new(
    std::io::ErrorKind::NotFound,
    "Ran out of places to find workspace root",
  ))
}

fn generate_schema<T: JsonSchema>(schema_name: &str) {
  let workspace_path = get_workspace_path().expect("Unable to get workspace path");
  let schema = schemars::schema_for!(T);
  let schema_file = std::path::Path::new(&workspace_path).join(format!("schemas/{}.json", schema_name));
  let json = serde_json::to_string_pretty(&schema).unwrap_or_default();
  fs::write(schema_file, json).expect("Unable to write schema file");
}

fn main() {
  generate_schema::<DatabaseSchema>("databaseSchema");
  generate_schema::<NetworkSchema>("networkSchema");
}