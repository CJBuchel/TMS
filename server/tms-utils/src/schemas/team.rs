use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use super::{TeamGameScore, TeamJudgingScore};
#[derive(JsonSchema, Deserialize, Serialize, Clone, Default)]
pub struct Team {
  pub team_number: String,
  pub team_name: String,
  pub team_affiliation: String,
  pub team_id: String,
  pub game_scores: Vec<TeamGameScore>,
  pub core_values_scores: Vec<TeamJudgingScore>,
  pub innovation_project_scores: Vec<TeamJudgingScore>,
  pub robot_design_scores: Vec<TeamJudgingScore>,
  pub ranking: u8
}