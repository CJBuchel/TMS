use strum_macros::Display;
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;

use super::tournament_code::TournamentCode;

#[derive(Display, Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub enum TournamentErrorCode {
  E001,
  E002,
  E003,
  E004,
  E005,
  E006,
  E007,
  E008,
  E009,
  E010,
  E011,
  E012,
}

impl TournamentCode for TournamentErrorCode {
  #[flutter_rust_bridge::frb(sync)]
  fn get_message(&self) -> String {
    match self {
      TournamentErrorCode::E001 => "Team number is missing.".to_string(),
      TournamentErrorCode::E002 => "Duplicate Team Number.".to_string(),
      TournamentErrorCode::E003 => "Team has conflicting scores.".to_string(),
      TournamentErrorCode::E004 => "Table does not exist in event.".to_string(),
      TournamentErrorCode::E005 => "Team in match does not exist in this event.".to_string(),
      TournamentErrorCode::E006 => "Duplicate match number.".to_string(),
      TournamentErrorCode::E007 => "Team has fewer matches than the maximum number of rounds.".to_string(),
      TournamentErrorCode::E008 => "Pod does not exist in event.".to_string(),
      TournamentErrorCode::E009 => "Team in pod does not exist in this event.".to_string(),
      TournamentErrorCode::E010 => "Team has more than one judging session.".to_string(),
      TournamentErrorCode::E011 => "Team is not in any judging sessions.".to_string(),
      TournamentErrorCode::E012 => "Duplicate session number.".to_string(),
    }
  }
}

impl Default for TournamentErrorCode {
  fn default() -> Self {
    TournamentErrorCode::E001
  }
}

impl DataSchemeExtensions for TournamentErrorCode {}
