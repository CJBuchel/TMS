use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use ausfll_score_calculator::schemas::ScoreAnswer;

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