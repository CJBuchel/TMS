use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use regex::Regex;

use super::QuestionAnswer;

// rule used to provide basic serializable logic for json forms
#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct QuestionRule {
  pub condition: String, // i.e m00a == 1 or m00a != m00b
  pub output: i32,
}

impl QuestionRule {
  pub fn new(condition: String, output: i32) -> QuestionRule {
    Self {
      condition,
      output,
    }
  }

  fn id_substitution(input: String, answers: Vec<QuestionAnswer>) -> String {
    // e.g if input is m00a, then find the answer for m00a
    let answer = answers.iter().find(|a| a.question_id == input);
    match answer {
      Some(a) => a.answer.clone(),
      None => input.to_string(),
    }
  }

  fn evaluate_condition(left: &str, operator: &str, right: &str, answers: Vec<QuestionAnswer>) -> bool {
    let left = Self::id_substitution(left.to_string(), answers.clone());
    let right = Self::id_substitution(right.to_string(), answers.clone());

    match operator {
      "==" => left == right,
      "!=" => left != right,
      ">" => left > right,
      "<" => left < right,
      ">=" => left >= right,
      "<=" => left <= right,
      _ => false,
    }
  }

  fn parse_condition(condition: &str) -> Result<(String, String, String), String> {
    let re = match Regex::new(r"(\w+)\s*(==|!=|>|<|>=|<=)\s*(\w+)") {
      Ok(re) => re,
      Err(_) => return Err("Invalid condition, must be simple `m00a == 2`".to_string()),
    };


    let caps = match re.captures(condition) {
      Some(caps) => caps,
      None => return Err("Invalid condition, must be simple `m00a == 2`".to_string()),
    };
  
    let left = caps.get(1).map_or("", |m| m.as_str()).to_string();
    let operator = caps.get(2).map_or("", |m| m.as_str()).to_string();
    let right = caps.get(3).map_or("", |m| m.as_str()).to_string();
    
    Ok((left, operator, right))
  }

  fn split_expression(expression: &str, delimiter: &str) -> Option<(String, String)> {
    let mut depth = 0;
    for (i, c) in expression.chars().enumerate() {
      match c {
        '(' => depth += 1,
        ')' => depth -= 1,
        _ if depth == 0 => {
          if expression[i..].starts_with(delimiter) {
            return Some((expression[..i].to_string(), expression[i + delimiter.len()..].to_string()));
          }
        }
        _ => {}
      }
    }

    None
  }

  fn evaluate_expression(expression: &str, answers: Vec<QuestionAnswer>) -> bool {
    let expression = expression.trim();

    // Handle parentheses by evaluating the expression inside first
    if expression.starts_with('(') && expression.ends_with(')') {
      return Self::evaluate_expression(&expression[1..expression.len() - 1], answers);
    }

    // Split by '||' (OR)
    if let Some((left, right)) = Self::split_expression(expression, "||") {
      return Self::evaluate_expression(&left, answers.clone()) || Self::evaluate_expression(&right, answers);
    }

    // Split by '&&' (AND)
    if let Some((left, right)) = Self::split_expression(expression, "&&") {
      return Self::evaluate_expression(&left, answers.clone()) && Self::evaluate_expression(&right, answers);
    }

    // Otherwise, evaluate the basic condition
    if let Ok((left, operator, right)) = Self::parse_condition(expression) {
      return Self::evaluate_condition(&left, &operator, &right, answers);
    }

    false
  }

  pub fn evaluate(&self, answers: Vec<QuestionAnswer>) -> bool {
    Self::evaluate_expression(&self.condition, answers)
  }

  pub fn apply(&self, answers: Vec<QuestionAnswer>) -> i32 {
    if self.evaluate(answers) {
      self.output
    } else {
      0
    }
  }
}