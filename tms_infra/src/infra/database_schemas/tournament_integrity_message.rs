use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;

use super::{TournamentCode, TournamentErrorCode, TournamentWarningCode};

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub enum TournamentIntegrityCode {
  Error(TournamentErrorCode),
  Warning(TournamentWarningCode),
}

impl TournamentIntegrityCode {
  
  pub fn get_stringified_code(&self) -> String {
    match self {
      Self::Error(code) => code.get_stringified_code(),
      Self::Warning(code) => code.get_stringified_code(),
    }
  }

  
  pub fn get_message(&self) -> String {
    match self {
      Self::Error(code) => code.get_message(),
      Self::Warning(code) => code.get_message(),
    }
  }
}

impl Default for TournamentIntegrityCode {
  fn default() -> Self {
    Self::Error(TournamentErrorCode::E001)
  }
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct TournamentIntegrityMessage {
  pub integrity_code: TournamentIntegrityCode,
  pub message: String,
  pub team_number: Option<String>,
  pub match_number: Option<String>,
  pub session_number: Option<String>,
}

impl TournamentIntegrityMessage {
  
  pub fn new(
    integrity_code: TournamentIntegrityCode,
    team_number: Option<String>,
    match_number: Option<String>,
    session_number: Option<String>,
  ) -> Self {
    // message format e.g [E001]: Team: 1234, Match: 1, Session: 1, - Team number is missing

    let mut message_segments: Vec<String> = Vec::new();

    // add the integrity code
    message_segments.push(format!("[{}]:", integrity_code.get_stringified_code()));
    
    // add the team
    match team_number.to_owned() {
      Some(team_number) => message_segments.push(format!(" Team: {},", team_number)),
      None => {},
    }

    // add the match
    match match_number.to_owned() {
      Some(match_number) => message_segments.push(format!(" Match: {},", match_number)),
      None => {},
    }
    
    // add the session
    match session_number.to_owned() {
      Some(session_number) => message_segments.push(format!(" Session: {},", session_number)),
      None => {},
    }

    // remove trailing comma
    message_segments.last_mut().map(|s| *s = s.trim_end_matches(',').to_string());

    // add the message
    message_segments.push(format!(" - {}", integrity_code.get_message()));

    // join the segments/build the message
    let message = message_segments.join("");

    TournamentIntegrityMessage {
      integrity_code,
      message,
      team_number,
      match_number,
      session_number,
    }
  }
}

impl Default for TournamentIntegrityMessage {
  fn default() -> Self {
    TournamentIntegrityMessage {
      integrity_code: TournamentIntegrityCode::default(),
      message: "".to_string(),
      team_number: None,
      match_number: None,
      session_number: None,
    }
  }
}

impl DataSchemeExtensions for TournamentIntegrityCode {}
impl DataSchemeExtensions for TournamentIntegrityMessage {}