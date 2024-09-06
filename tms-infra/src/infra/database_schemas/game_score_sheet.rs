use crate::{DataSchemeExtensions, QuestionAnswer};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use super::TmsDateTime;

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct GameScoreSheet {
  pub table: String,
  pub team_ref_id: String, // team id in db, not team number
  pub referee: String,
  pub match_number: Option<String>,
  pub timestamp: TmsDateTime,

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

  pub modified: bool,
  pub modified_by: Option<String>, // username
}

impl Default for GameScoreSheet {
  fn default() -> Self {
    Self {
      table: "".to_string(),
      team_ref_id: "".to_string(),
      referee: "".to_string(),
      match_number: None,
      timestamp: TmsDateTime::default(),
      gp: "".to_string(),
      no_show: false,
      score: 0,
      round: 0,
      is_agnostic: false,
      score_sheet_answers: Vec::new(),
      private_comment: "".to_string(),
      modified: false,
      modified_by: None,
    }
  }
}

impl DataSchemeExtensions for GameScoreSheet {}