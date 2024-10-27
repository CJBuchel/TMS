use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::{infra::DataSchemeExtensions, GameScoreSheet, QuestionAnswer};

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct RobotGameScoreSheetSubmitRequest {
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

impl Default for RobotGameScoreSheetSubmitRequest {
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
pub struct RobotGameScoreSheetInsertRequest {
  pub score_sheet_id: Option<String>,
  pub score_sheet: GameScoreSheet,
}

impl Default for RobotGameScoreSheetInsertRequest {
  fn default() -> Self {
    Self {
      score_sheet_id: None,
      score_sheet: GameScoreSheet::default(),
    }
  }
}

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct RobotGameScoreSheetRemoveRequest {
  pub score_sheet_id: String,
}

impl Default for RobotGameScoreSheetRemoveRequest {
  fn default() -> Self {
    Self { score_sheet_id: "".to_string() }
  }
}

impl DataSchemeExtensions for RobotGameScoreSheetSubmitRequest {}
impl DataSchemeExtensions for RobotGameScoreSheetInsertRequest {}
impl DataSchemeExtensions for RobotGameScoreSheetRemoveRequest {}