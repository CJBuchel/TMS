use super::{FllBlueprint, QuestionAnswer, QuestionValidationError};

pub mod fll_2023;
pub use fll_2023::*;

pub trait BaseSeason {
  fn validate(&self, answers: Vec<QuestionAnswer>) -> Vec<QuestionValidationError>;
  fn get_season(&self) -> String;
  fn get_fll_game(&self) -> FllBlueprint;
}