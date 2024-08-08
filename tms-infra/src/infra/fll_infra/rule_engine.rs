use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use regex::Regex;

use super::{FllBlueprint, QuestionAnswer};


// rule used to provide basic serializable logic for json forms
#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct QuestionRule {
  pub condition: String, // i.e m00a == 1 or m00a != m00b
  pub score_modifier: i32, // if true, then output
}

impl QuestionRule {
  fn parse_condition(&self) -> Result<(String, String, String), String> {
    let re = match Regex::new(r"(\w+)\s*(==|!=|>|<|>=|<=)\s*(\w+)") {
      Ok(re) => re,
      Err(_) => return Err("Invalid condition, must be simple `m00a == 2`".to_string()),
    };


    let caps = match re.captures(&self.condition) {
      Some(caps) => caps,
      None => return Err("Invalid condition, must be simple `m00a == 2`".to_string()),
    };
  
    let left = caps.get(1).map_or("", |m| m.as_str()).to_string();
    let operator = caps.get(2).map_or("", |m| m.as_str()).to_string();
    let right = caps.get(3).map_or("", |m| m.as_str()).to_string();
    
    Ok((left, operator, right))
  }

  pub fn new(condition: String, score_modifier: i32) -> QuestionRule {
    Self {
      condition,
      score_modifier,
    }
  }

  fn id_substitution(input: String, answers: Vec<QuestionAnswer>) -> String {
    // if left is m00a, then find the answer for m00a
    let answer = answers.iter().find(|a| a.question_id == input);
    match answer {
      Some(a) => a.answer.clone(),
      None => input.to_string(),
    }
  }

  pub fn evaluate(&self, answers: Vec<QuestionAnswer>, _: FllBlueprint) -> Result<bool, String> {
    let (left, operator, right) = self.parse_condition()?;

    let left_value = Self::id_substitution(left, answers.clone());
    let right_value = Self::id_substitution(right, answers.clone());

    // do the comparison
    let result = match operator.as_str() {
      "==" => left_value == right_value,
      "!=" => left_value != right_value,
      ">" => left_value > right_value,
      "<" => left_value < right_value,
      ">=" => left_value >= right_value,
      "<=" => left_value <= right_value,
      _ => return Err("Invalid operator".to_string()),
    };

    Ok(result)
  }
}