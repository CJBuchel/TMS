use fll_games::schemas::ScoreAnswer;
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};


#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct GameScoresheet {
  pub team_id: String,
  pub tournament_id: String,
  pub round: u32,
  pub answers: Vec<ScoreAnswer>,
  pub public_comment: String,
  pub private_comment: String
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct JudgingScoresheet {
  pub team_id: String,
  pub tournament_id: String,
  pub answers: Vec<ScoreAnswer>,
  pub feedback_pros: String,
  pub feedback_crit: String
}