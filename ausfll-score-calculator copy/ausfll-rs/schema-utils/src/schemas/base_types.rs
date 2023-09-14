use serde::{Deserialize, Serialize};

use super::{get_missions_20232024, get_questions_20232024};

#[derive(schemars::JsonSchema, Deserialize, Serialize, Clone)]
pub struct ScoreAnswer {
  pub id: String,
  pub answer: String,
}

#[derive(schemars::JsonSchema, Deserialize, Serialize, Clone)]
pub enum DefaultValue {
  Number(i32),
  Text(String),
}

// add for more inputs
#[derive(schemars::JsonSchema, Deserialize, Serialize, Clone)]
pub enum QuestionInput {
  Numerical {
    min: i32,
    max: i32,
  },
  
  Categorical {
    options: Vec<String>,
  }
}

#[derive(schemars::JsonSchema, Deserialize, Serialize, Clone)]
pub struct Score {
  pub id: String,
  pub label: String,
  pub label_short: String,
  pub question_input: QuestionInput,
  pub default_value: DefaultValue,
}

#[derive(schemars::JsonSchema, Deserialize, Serialize, Clone)]
pub struct ScoreError {
  pub id: String,
  pub message: String,
}

#[derive(schemars::JsonSchema, Deserialize, Serialize, Clone)]
pub struct Mission {
  pub prefix: String,
  pub title: String,
  pub image: Option<String>,
}

#[derive(schemars::JsonSchema, Deserialize, Serialize, Clone)]
pub struct MissionPicture { // this is kept as a static because nothing else uses it expects the missions. 
  pub prefix: &'static str, // m00/m01 etc..
  pub url: &'static str, // see firebase_links.rs
}

#[derive(schemars::JsonSchema, Deserialize, Serialize, Clone)]
pub struct Game {
  pub name: String,
  pub program: String,
  pub season: u32, // 20232024
  pub missions: Vec<Mission>,
  pub questions: Vec<Score>,
}

#[derive(schemars::JsonSchema, Deserialize, Serialize, Clone)]
pub struct Games {
  pub game_2023: Game,
}

// get all the games to generate the schemas
pub fn get_games() -> Games {
  Games {
    game_2023: Game {
      name: "Masterpiece".to_string(),
      program: "FLL_CHALLENGE".to_string(),
      season: 20232024,
      missions: get_missions_20232024(),
      questions: get_questions_20232024(),
    },
  }
}