use super::{FllGame, QuestionAnswer, QuestionValidationError};

pub mod fll_2023;
pub use fll_2023::*;


pub trait BaseSeason {
  fn validate(&self, answers: Vec<QuestionAnswer>) -> Vec<QuestionValidationError> {
    vec![]
  }

  fn get_season(&self) -> String {
    "".to_string()
  }

  fn get_fll_game(&self) -> FllGame {
    FllGame::default()
  }
}