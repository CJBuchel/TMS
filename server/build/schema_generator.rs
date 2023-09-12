
use std::ffi::OsString;
use std::fs;
use std::path::Path;

use schemars::JsonSchema;
use tms_utils::{

  // Storage structure imports
  schemas::*,
  
  // Network structure imports
  network_schemas::*
};

#[allow(dead_code)]
#[derive(JsonSchema, Clone)]
pub struct TmsSchema {
  //
  // Primitive storage structures
  //
  team: Team,
  game_match: GameMatch,
  judging_session: JudgingSession,
  users: User,
  event: Event,

  //
  // Network structures (Basic)
  //
  register_request: RegisterRequest,
  register_response: RegisterResponse,
  integrity_message: IntegrityMessage,
  login_request: LoginRequest,
  login_response: LoginResponse,
  setup_request: SetupRequest,
  purge_request: PurgeRequest,
  
  //
  // Network structures (Socket)
  //
  socket_event: SocketMessage,
  socket_match_loaded_message: SocketMatchLoadedMessage,
  
  //
  // Network structures (Event Data)
  //
  events_get_response: EventResponse,
  //teams
  teams_get_response: TeamsResponse,
  team_get_request: TeamRequest,
  team_get_response: TeamResponse,
  // matches
  matches_get_response: MatchesResponse,
  match_get_request: MatchRequest,
  match_get_response: MatchResponse,
  //judging
  judging_sessions_get_response: JudgingSessionsResponse,
  judging_session_get_request: JudgingSessionRequest,
  judging_session_get_response: JudgingSessionResponse,
  
  //
  // Network structures (Controls)
  //
  start_timer_request: TimerRequest,
  match_loaded_request: MatchLoadRequest,
}

pub fn generate_schema(outdir: &OsString) {
  let schema = schemars::schema_for!(TmsSchema);
  let schema_file = Path::new(outdir).join("tms_schema.json");

  fs::write(schema_file, serde_json::to_string_pretty(&schema).unwrap()).unwrap();
}