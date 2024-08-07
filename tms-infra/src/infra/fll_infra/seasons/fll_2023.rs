use std::vec;

use crate::{infra::fll_infra::{QuestionAnswer, QuestionValidationError}, FllBlueprint};

use super::BaseSeason;

pub struct MasterPiece {}

impl BaseSeason for MasterPiece {
  fn validate(&self, _: Vec<QuestionAnswer>) -> Vec<QuestionValidationError> {
    vec![] // TODO: Implement this
  }

  fn get_season(&self) -> String {
    "2023".to_string()
  }

  fn get_fll_game(&self) -> FllBlueprint {
    FllBlueprint::default() // TODO: Implement this
  }
}