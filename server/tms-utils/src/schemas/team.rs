use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use super::{GameScoresheet, JudgingScoresheet};
#[derive(JsonSchema, Deserialize, Serialize, Clone, Default)]
pub struct Team {
  pub team_number: String,
  pub team_name: String,
  pub team_affiliation: String,
  pub team_id: String,
  pub game_scores: Vec<GameScoresheet>,
  pub core_values_scores: Vec<JudgingScoresheet>,
  pub innovation_project_scores: Vec<JudgingScoresheet>,
  pub robot_design_scores: Vec<JudgingScoresheet>,
  pub ranking: u8
}