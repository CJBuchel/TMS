
use std::{fs, path::PathBuf};

use lib_flutter_rust_bridge_codegen::codegen;
use tms_infra_schema::*;
use schemars::JsonSchema;

#[derive(JsonSchema)]
struct DatabaseSchema {
  _team: Team,
  _tournament_config: TournamentConfig,
  _game_match: GameMatch,
  _judging_session: JudgingSession,
}

#[derive(JsonSchema)]
struct NetworkSchema {
  _register_request: RegisterRequest,
  _register_response: RegisterResponse,
  _login_request: LoginRequest,
  _login_response: LoginResponse,

  // socket protocol
  _tms_server_socket_message: TmsServerSocketMessage,
  _tms_server_match_timer_time_event: TmsServerMatchTimerTimeEvent,
  _tms_server_match_load_event: TmsServerMatchLoadEvent,

  // config
  _tournament_config_set_name_request: TournamentConfigSetNameRequest,
  _tournament_config_set_season_request: TournamentConfigSetSeasonRequest,
  _tournament_config_set_timer_length_request: TournamentConfigSetTimerLengthRequest,
  _tournament_config_set_endgame_timer_length_request: TournamentConfigSetEndgameTimerLengthRequest,
  _tournament_config_set_backup_interval_request: TournamentConfigSetBackupIntervalRequest,
  _tournament_config_set_retain_backups_request: TournamentConfigSetRetainBackupsRequest,

  // game matches
  _robot_games_load_match_request: RobotGamesLoadMatchRequest,
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

fn main() -> anyhow::Result<()> {
  // only recompile on directory change
  println!("cargo:rerun-if-changed=src");

  // generate_schema::<DatabaseSchema>("databaseSchema");
  // generate_schema::<NetworkSchema>("networkSchema");

  // If you want to see logs
  // Alternatively, use `cargo build -vvv` (instead of `cargo build`) to see logs on screen
  // configure_opinionated_logging("./logs/", true)?;

  // codegen::generate(
  //   codegen::Config {
  //     rust_input: Some("crate::api".to_string()),
  //     rust_root: Some(".".to_string()),
  //     dart_output: Some(get_workspace_path()?.join("tms-client/lib/generated").to_string_lossy().to_string()),
  //     local: Some(true),
  //     ..Default::default()
  //   },
  //   Default::default(),
  // )?;
  Ok(())
}