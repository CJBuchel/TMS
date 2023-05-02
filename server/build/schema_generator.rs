
use std::ffi::OsString;
use std::fs;
use std::path::Path;

use schemars::JsonSchema;

include!("../src/schemas/mod.rs");

#[allow(dead_code)]
#[derive(JsonSchema, Clone)]
pub struct TmsSchema {
  // Storage Structures
  team: Team,
  game_match: GameMatch,
  judging_session: JudgingSession,
  users: User,
  event: Event,

  // Network structures
  register_request: RegisterRequest,
  register_response: RegisterResponse,
  socket_event: SocketMessage,
  integrity_message: IntegrityMessage
}

pub fn generate_schema(outdir: &OsString) {
  let schema = schemars::schema_for!(TmsSchema);
  let schema_file = Path::new(outdir).join("tms-schema.json");

  fs::write(schema_file, serde_json::to_string_pretty(&schema).unwrap()).unwrap();
}