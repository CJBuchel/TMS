
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct QuestionsValidateRequest {
  pub auth_token: String,
  pub answers: Vec<fll_games::schemas::ScoreAnswer>
}