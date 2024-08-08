use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

use super::{CategoricalQuestion, QuestionRule};

pub struct QuestionValidationError {
  pub question_ids: String,
  pub message: String,
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct QuestionAnswer {
  pub question_id: String,
  pub answer: String,
}

impl Default for QuestionAnswer {
  fn default() -> Self {
    Self {
      question_id: "".to_string(),
      answer: "".to_string(),
    }
  }
}


#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub enum QuestionType {
  Categorical,
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct Question {
  pub id: String,
  pub label: String,
  pub label_short: String,
  pub question_type: QuestionType,
  pub question_input_def: String, // JSON string (based on question type)
  pub question_rule: Option<QuestionRule>,
}

impl Question {
  pub fn get_score(&self, answer: QuestionAnswer) -> i32 {
    match self.question_type {
      QuestionType::Categorical => {
        let q = CategoricalQuestion::from_json_string(&self.question_input_def);
        let answer_option = q.options.iter().find(|o| o.label == answer.answer);
        match answer_option {
          Some(option) => option.score,
          None => 0,
        }
      }
    }
  }
}

impl Default for Question {
  fn default() -> Self {
    Self {
      id: "".to_string(),
      label: "".to_string(),
      label_short: "".to_string(),
      question_type: QuestionType::Categorical,
      question_input_def: "".to_string(),
      question_rule: None,
    }
  }
}

impl DataSchemeExtensions for QuestionAnswer {}
impl DataSchemeExtensions for Question {}