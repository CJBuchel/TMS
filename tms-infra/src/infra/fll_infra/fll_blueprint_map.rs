
use super::{BaseSeason, FllBlueprint, MasterPiece, QuestionAnswer, QuestionValidationError};

const SEASONS: &[(&str, &'static dyn BaseSeason)] = &[
  ("2023", &MasterPiece {}),
];


pub struct FllBlueprintMap {}

impl FllBlueprintMap {
  pub fn validate(&self, season: String, answers: Vec<QuestionAnswer>) -> Option<Vec<QuestionValidationError>> {
    // match_season!(season, validate(answers))
    match SEASONS.iter().find(|(s, _)| *s == season) {
      Some((_, season)) => Some(season.validate(answers)),
      None => None,
    }
  }

  pub fn calculate_score(&self, blueprint: FllBlueprint, answers: Vec<QuestionAnswer>) -> i32 {
    let mut score = 0;
    for answer in answers {
      let question = blueprint.robot_game_questions.iter().find(|q| q.id == answer.question_id);
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
  pub fn get_fll_game(&self, season: String) -> Option<FllBlueprint> {
    // match_season!(season, get_fll_game())
    match SEASONS.iter().find(|(s, _)| *s == season) {
      Some((_, season)) => Some(season.get_fll_game()),
      None => None,
    }
  }

  // this doesn't get FRB annotations to avoid frontend confusion. (Flutter gets game from server db)
  #[flutter_rust_bridge::frb(ignore)]
  pub fn get_seasons(&self) -> Vec<String> {
    SEASONS.iter().map(|(s, _)| s.to_string()).collect()
  }
}