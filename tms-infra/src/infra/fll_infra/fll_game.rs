use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

use super::{category_question::CategoricalQuestion, Season};

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
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


#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub enum QuestionType {
  Categorical,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct Question {
  pub id: String,
  pub label: String,
  pub label_short: String,
  pub question_type: QuestionType,
  pub question_input_def: String, // JSON string (based on question type)
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
    }
  }
}


#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct Mission {
  pub id: String,
  pub label: String,
  pub image_url: String,
}

impl Default for Mission {
  fn default() -> Self {
    Self {
      id: "".to_string(),
      label: "".to_string(),
      image_url: "".to_string(),
    }
  }
}

pub struct ValidationError {
  pub question_ids: String,
  pub message: String,
}


#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct FllGame {
  pub season: Season,
  pub questions: Vec<Question>,
  pub missions: Vec<Mission>,
}

impl FllGame {
  pub fn calculate_score(&self, answers: Vec<QuestionAnswer>) -> i32 {
    let mut score = 0;
    for answer in answers {
      let question = self.questions.iter().find(|q| q.id == answer.question_id);
      match question {
        Some(q) => {
          score += q.get_score(answer);
        }
        None => {}
      }
    }
    score
  }
}

impl Default for FllGame {
  fn default() -> Self {
    Self {
      season: Season::default(),
      questions: vec![],
      missions: vec![],
    }
  }
}


impl DataSchemeExtensions for QuestionAnswer {}
impl DataSchemeExtensions for Question {}
impl DataSchemeExtensions for Mission {}
impl DataSchemeExtensions for FllGame {}