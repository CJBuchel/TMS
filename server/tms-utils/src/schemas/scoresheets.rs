use schema_utils::schemas::ScoreAnswer;
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};


#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct GameScoresheet {
  team_id: String,
  tournament_id: String,
  round: u32,
  answers: Vec<ScoreAnswer>,
  private_comment: String,
  public_comment: String
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct JudgingScoresheet {
  team_id: String,
  tournament_id: String,
  answers: Vec<ScoreAnswer>,
  feedback_pros: String,
  feedback_crit: String
}