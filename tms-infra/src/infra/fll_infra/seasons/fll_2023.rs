use std::vec;

use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};

use crate::infra::fll_infra::{FllGame, QuestionAnswer, QuestionValidationError};

use super::BaseSeason;

#[flutter_rust_bridge::frb(opaque)]
pub struct MasterPiece {}

impl BaseSeason for MasterPiece {
  fn validate(&self, _: Vec<QuestionAnswer>) -> Vec<QuestionValidationError> {
    vec![] // TODO: Implement this
  }

  fn get_season(&self) -> String {
    "2023".to_string()
  }

  fn get_fll_game(&self) -> FllGame {
    FllGame::default() // TODO: Implement this
  }
}