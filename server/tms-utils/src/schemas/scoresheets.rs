use schemars::JsonSchema;
use serde::{Deserialize, Serialize};
use super::answer::Answer;

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct GameScoresheet {
  team_id: String,
  tournament_id: String,
  round: u8,
  answers: Vec<Answer>,
  private_comment: String,
  public_comment: String
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct JudgingScoresheet {
  team_id: String,
  tournament_id: String,
  answers: Vec<Answer>,
  feedback_pros: String,
  feedback_crit: String
}