
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
  setup_request: SetupRequest,
  purge_request: PurgeRequest,
  proxy_bytes_response: ProxyBytesResponse,
  // users
  login_request: LoginRequest,
  login_response: LoginResponse,
  users_request: UsersRequest,
  users_response: UsersResponse,
  add_user_request: AddUserRequest,
  delete_user_request: DeleteUserRequest,
  update_user_request: UpdateUserRequest,
  
  //
  // Network structures (Socket)
  //
  socket_event: SocketMessage,
  socket_match_loaded_message: SocketMatchLoadedMessage,
  
  //
  // Network structures (Event Data)
  //
  events_get_response: EventResponse,
  event_get_api_link_request: ApiLinkRequest,
  event_get_api_link_response: ApiLinkResponse,
  //teams
  teams_get_response: TeamsResponse,
  team_get_request: TeamRequest,
  team_get_response: TeamResponse,
  team_update_request: TeamUpdateRequest,
  team_post_game_scoresheet_request: TeamPostGameScoresheetRequest,
  // matches
  matches_get_response: MatchesResponse,
  match_get_request: MatchRequest,
  match_get_response: MatchResponse,
  match_update_request: MatchUpdateRequest,
  //judging
  judging_sessions_get_response: JudgingSessionsResponse,
  judging_session_get_request: JudgingSessionRequest,
  judging_session_get_response: JudgingSessionResponse,
  // games
  game_get_response: GameResponse,
  missions_get_response: MissionsResponse,
  questions_get_response: QuestionsResponse,
  seasons_get_response: SeasonsResponse,
  questions_validate_request: QuestionsValidateRequest,
  questions_validate_response: QuestionsValidateResponse,
  
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