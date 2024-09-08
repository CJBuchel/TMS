use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::{infra::DataSchemeExtensions, GameMatch, QuestionAnswer};

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct RobotGamesLoadMatchRequest {
  pub game_match_numbers: Vec<String>,
}

impl Default for RobotGamesLoadMatchRequest {
  fn default() -> Self {
    Self { game_match_numbers: vec![] }
  }
}

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct RobotGameTableSignalRequest {
  pub table: String,
  pub team_number: String,
}

impl Default for RobotGameTableSignalRequest {
  fn default() -> Self {
    Self {
      table: "".to_string(),
      team_number: "".to_string(),
    }
  }
}

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct RobotGameScoreSheetRequest {
  pub blueprint_title: String,
  pub table: String,
  pub team_number: String,
  pub referee: String,
  pub match_number: Option<String>,

  // score sheet headers
  pub gp: String,
  pub no_show: bool,
  pub score: i32,
  pub round: u32,

  // score sheet data
  pub is_agnostic: bool,
  pub score_sheet_answers: Vec<QuestionAnswer>, // populated if not agnostic
  
  // referee comments
  pub private_comment: String,
}

impl Default for RobotGameScoreSheetRequest {
  fn default() -> Self {
    Self {
      blueprint_title: "".to_string(),
      table: "".to_string(),
      team_number: "".to_string(),
      referee: "".to_string(),
      match_number: None,
      gp: "".to_string(),
      no_show: false,
      score: 0,
      round: 0,
      is_agnostic: false,
      score_sheet_answers: vec![],
      private_comment: "".to_string(),
    }
  }
}

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct RobotGamesUpdateMatchRequest {
  pub match_id: String,
  pub game_match: GameMatch,
}

impl Default for RobotGamesUpdateMatchRequest {
  fn default() -> Self {
    Self {
      match_id: "".to_string(),
      game_match: GameMatch::default(),
    }
  }
}

impl DataSchemeExtensions for RobotGamesLoadMatchRequest {}
impl DataSchemeExtensions for RobotGameTableSignalRequest {}
impl DataSchemeExtensions for RobotGameScoreSheetRequest {}
impl DataSchemeExtensions for RobotGamesUpdateMatchRequest {}
