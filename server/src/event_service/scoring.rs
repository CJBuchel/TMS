use tms_utils::{ScoreError, Games, ScoreAnswer, Game};

use crate::db::db::TmsDB;

pub struct Validation {
  pub errors: Vec<ScoreError>,
  pub score: i32,
}

pub struct Scoring {
  tms_db: std::sync::Arc<TmsDB>,
}

impl Scoring {
  pub fn new(tms_db: std::sync::Arc<TmsDB>) -> Self {
    Self {
      tms_db
    }
  }

  pub fn validate(&self, answers: Vec<ScoreAnswer>) -> Option<Validation> {
    let season = self.tms_db.tms_data.event.get().unwrap().unwrap().season;
    match Games::get_games().get(season.as_str()) {
      Some(g) => {
        let errors = g.validate(answers.clone());
        let score = g.score(answers.clone());
        Some(Validation {errors,score})
      },
      None => None
    }
  }

  pub fn get_game(&self) -> Game {
    let season = self.tms_db.tms_data.event.get().unwrap().unwrap().season;
    match Games::get_games().get(season.as_str()) {
      Some(g) => g.get_game(),
      None => Game {
        name: "".to_string(),
        program: "".to_string(),
        rule_book_url: "".to_string(),
        missions: vec![],
        questions: vec![],
      }
    }
  }
}