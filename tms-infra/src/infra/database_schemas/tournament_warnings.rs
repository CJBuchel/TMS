use schemars::JsonSchema;
use serde::{Deserialize, Serialize};
use strum_macros::Display;

use crate::infra::DataSchemeExtensions;

use super::tournament_code::TournamentCode;

#[derive(Display, Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub enum TournamentWarningCode {
  W001,
  W002,
  W003,
  W004,
  W005,
  W006,
  W007,
  W008,
  W009,
  W010,
  W011,
  W012,
  W013,
  W014,
  W015,
  W016,
  W017,
  W018,
}

impl TournamentCode for TournamentWarningCode {
  fn get_message(&self) -> String {
    match self {
      TournamentWarningCode::W001 => "Team name is missing.".to_string(),
      TournamentWarningCode::W002 => "Duplicate Team Name.".to_string(),
      TournamentWarningCode::W003 => "Team has a round 0 score.".to_string(),
      TournamentWarningCode::W004 => "No tables or teams found in match.".to_string(),
      TournamentWarningCode::W005 => "Match is complete but score not submitted.".to_string(),
      TournamentWarningCode::W006 => "Match is not complete but score submitted.".to_string(),
      TournamentWarningCode::W007 => "Blank table in match.".to_string(),
      TournamentWarningCode::W008 => "No team on table.".to_string(),
      TournamentWarningCode::W009 => "Team has judging session within 10 minutes of match.".to_string(),
      TournamentWarningCode::W010 => "No pods or teams found in sessions.".to_string(),
      TournamentWarningCode::W011 => "Session Complete, but no core values score submitted.".to_string(),
      TournamentWarningCode::W012 => "Session Complete, but no innovation score submitted.".to_string(),
      TournamentWarningCode::W013 => "Session Complete, but no robot design score submitted.".to_string(),
      TournamentWarningCode::W014 => "Session not Complete, but core values score submitted.".to_string(),
      TournamentWarningCode::W015 => "Session not Complete, but innovation score submitted.".to_string(),
      TournamentWarningCode::W016 => "Session not Complete, but robot design score submitted.".to_string(),
      TournamentWarningCode::W017 => "Blank pod in session.".to_string(),
      TournamentWarningCode::W018 => "No team in pod.".to_string(),
    }
  }
}

impl Default for TournamentWarningCode {
  fn default() -> Self {
    TournamentWarningCode::W001
  }
}

impl DataSchemeExtensions for TournamentWarningCode {}
