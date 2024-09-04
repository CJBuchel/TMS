use std::collections::HashMap;

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
pub enum QuestionInput {
  Categorical(CategoricalQuestion),
  // Numerical(i32), // one day :(
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct Question {
  pub id: String,
  pub label: String,
  pub label_short: String,
  pub input: QuestionInput,
  pub rules: Vec<QuestionRule>, // set of json rules used to modify score, i.e m00a == 1, output = 10
}

impl Question {
  pub fn get_score(&self, answers: &HashMap<String, QuestionAnswer>) -> i32 {
    let answer = match answers.get(&self.id) {
      Some(a) => a,
      None => return 0,
    };

    // apply regular answer score
    let mut score = match &self.input {
      QuestionInput::Categorical(q) => {
        q.options.iter().find(|o| o.label == answer.answer).map_or(0, |o| o.score)
      }
    };

    // get the first matching rule (if any) and return that instead
    for rule in self.rules.iter() {
      score = match rule.apply(answers) {
        Ok(s) => s,
        Err(_) => score,
      };
    }

    score
  }
}

impl Default for Question {
  fn default() -> Self {
    Self {
      id: "".to_string(),
      label: "".to_string(),
      label_short: "".to_string(),
      input: QuestionInput::Categorical(CategoricalQuestion::default()),
      rules: vec![],
    }
  }
}

impl DataSchemeExtensions for QuestionAnswer {}
impl DataSchemeExtensions for Question {}