use schemars::{JsonSchema};
use serde::{Deserialize, Serialize};

use super::{GameScoresheet, JudgingScoresheet};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct TeamGameScore {
  pub gp: String,
  pub referee: String,
  pub no_show: bool,
  pub score: i32,
  pub cloud_published: bool,
  pub scoresheet: GameScoresheet
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct TeamJudgingScore {
  pub judge: String,
  pub no_show: bool,
  pub score: i32,
  pub cloud_published: bool,
  pub scoresheet: JudgingScoresheet
}