
use schema_utils::schemas::{Mission, ScoreError};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct MissionsResponse {
  pub missions: Vec<Mission>
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct QuestionsResponse {
  pub questions: Vec<schema_utils::schemas::Score>
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct GameResponse {
  pub game: schema_utils::schemas::Game
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