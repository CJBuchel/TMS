
use fll_games::schemas::{Mission, ScoreError};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct MissionsResponse {
  pub missions: Vec<Mission>
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct QuestionsResponse {
  pub questions: Vec<fll_games::schemas::Score>
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct GameResponse {
  pub game: fll_games::schemas::Game
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct SeasonsResponse {
  pub seasons: Vec<String> // e.g 2023
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct QuestionsValidateResponse {
  pub errors: Vec<ScoreError>,
  pub score: i32
}