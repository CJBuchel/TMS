use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use super::{GameScoresheet, JudgingScoresheet};
#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct Team {
  team_number: String,
  team_name: String,
  team_affiliation: String,
  team_id: String,
  game_scores: Vec<GameScoresheet>,
  core_values_scores: Vec<JudgingScoresheet>,
  innovation_project_scores: Vec<JudgingScoresheet>,
  robot_design_scores: Vec<JudgingScoresheet>,
  ranking: u8
}