use std::{fs, path::PathBuf};

use database_schema::*;
use schemars::JsonSchema;

#[derive(JsonSchema)]
struct DatabaseSchema {
  _team: Team,
  _tournament_config: TournamentConfig,
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

fn main() {
  let workspace_path = get_workspace_path().expect("Unable to get workspace path");
  let schema = schemars::schema_for!(DatabaseSchema);
  let schema_file = std::path::Path::new(&workspace_path).join("schemas/database.json");
  let json = serde_json::to_string_pretty(&schema).unwrap_or_default();
  fs::write(schema_file, json).expect("Unable to write schema file");
}
