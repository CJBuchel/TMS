use std::collections::HashMap;

use super::{FllBlueprint, QuestionAnswer, QuestionValidationError};

pub mod fll_2023;
pub use fll_2023::*;

pub mod fll_2024;
pub use fll_2024::*;

pub trait BaseSeason {
  fn validate(&self, answers: &HashMap<String, QuestionAnswer>) -> Vec<QuestionValidationError>;
  fn get_season(&self) -> String;
  fn get_fll_game(&self) -> FllBlueprint;
}
