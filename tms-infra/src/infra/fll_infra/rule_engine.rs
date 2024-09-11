use std::collections::HashMap;

use lazy_static::lazy_static;
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
    Self { condition, output }
  }

  fn id_substitution(input: &str, answers: &HashMap<String, QuestionAnswer>) -> String {
    answers.get(input).map_or(input.to_string(), |a| a.answer.clone())
  }

  fn evaluate_condition(left: &str, operator: &str, right: &str, answers: &HashMap<String, QuestionAnswer>) -> bool {
    let left = Self::id_substitution(left, answers);
    let right = Self::id_substitution(right, answers);

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
    lazy_static! {
      static ref RE: Regex = Regex::new(r"(\w+)\s*(==|!=|>|<|>=|<=)\s*(\w+)").unwrap();
    }

    let caps = match RE.captures(condition) {
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

  fn evaluate_expression(expression: &str, answers: &HashMap<String, QuestionAnswer>) -> bool {
    let expression = expression.trim();

    // Handle parentheses by evaluating the expression inside first
    if expression.starts_with('(') && expression.ends_with(')') {
      return Self::evaluate_expression(&expression[1..expression.len() - 1], answers);
    }

    // Split by '||' (OR)
    if let Some((left, right)) = Self::split_expression(expression, "||") {
      return Self::evaluate_expression(&left, answers) || Self::evaluate_expression(&right, answers);
    }

    // Split by '&&' (AND)
    if let Some((left, right)) = Self::split_expression(expression, "&&") {
      return Self::evaluate_expression(&left, answers) && Self::evaluate_expression(&right, answers);
    }

    // Otherwise, evaluate the basic condition
    if let Ok((left, operator, right)) = Self::parse_condition(expression) {
      return Self::evaluate_condition(&left, &operator, &right, answers);
    }

    false
  }

  pub fn evaluate(&self, answers: &HashMap<String, QuestionAnswer>) -> bool {
    Self::evaluate_expression(&self.condition, answers)
  }

  pub fn apply(&self, answers: &HashMap<String, QuestionAnswer>) -> Option<i32> {
    if self.evaluate(answers) {
      Some(self.output)
    } else {
      None
    }
  }
}
