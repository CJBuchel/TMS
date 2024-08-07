use crate::fll_2023::MasterPiece;

use super::{BaseSeason, FllGame, QuestionAnswer, QuestionValidationError};

#[flutter_rust_bridge::frb(opaque)]
pub struct FllGameMap {}

impl FllGameMap {
  #[flutter_rust_bridge::frb(sync)]
  pub fn get_games() -> Vec<Box<dyn BaseSeason>> {
    vec![
      Box::new(MasterPiece {})
    ]
  }

  #[flutter_rust_bridge::frb(sync)]
  pub fn validate(&self, season: String, answers: Vec<QuestionAnswer>) -> Option<Vec<QuestionValidationError>> {
    let games = FllGameMap::get_games();
    let game = games.iter().find(|g| g.get_season() == season);
    match game {
      Some(g) => Some(g.validate(answers)),
      None => None,
    }
  }

  #[flutter_rust_bridge::frb(sync)]
  pub fn calculate_score(&self, fll_game: FllGame, answers: Vec<QuestionAnswer>) -> i32 {
    let mut score = 0;
    for answer in answers {
      let question = fll_game.questions.iter().find(|q| q.id == answer.question_id);
      match question {
        Some(q) => {
          score += q.get_score(answer);
        }
        None => {}
      }
    }
    score
  }

  // this doesn't get FRB annotations to avoid frontend confusion. (Flutter gets game from server db)
  #[flutter_rust_bridge::frb(ignore)]
  pub fn get_fll_game(&self, season: String) -> Option<FllGame> {
    let games = FllGameMap::get_games();
    let game = games.iter().find(|g| g.get_season() == season);
    match game {
      Some(g) => Some(g.get_fll_game()),
      None => None,
    }
  }
}