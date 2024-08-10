
use super::{BaseSeason, FllBlueprint, MasterPiece, QuestionAnswer, QuestionValidationError};

const SEASONS: &[(&str, &'static dyn BaseSeason)] = &[
  ("2023", &MasterPiece {}),
];


pub struct FllBlueprintMap {}

impl FllBlueprintMap {
  pub fn validate(season: String, answers: Vec<QuestionAnswer>) -> Option<Vec<QuestionValidationError>> {
    // match_season!(season, validate(answers))
    match SEASONS.iter().find(|(s, _)| *s == season) {
      Some((_, season)) => Some(season.validate(answers)),
      None => None,
    }
  }

  pub fn calculate_score(blueprint: FllBlueprint, answers: Vec<QuestionAnswer>) -> i32 {
    let mut score = 0;

    for question in blueprint.robot_game_questions.iter() {
      score += question.get_score(answers.clone());
    }

    score
  }

  // this doesn't get FRB annotations to avoid frontend confusion. (Flutter gets game from server db)
  #[flutter_rust_bridge::frb(ignore)]
  pub fn get_fll_blueprint(season: String) -> Option<FllBlueprint> {
    // match_season!(season, get_fll_game())
    match SEASONS.iter().find(|(s, _)| *s == season) {
      Some((_, season)) => Some(season.get_fll_game()),
      None => None,
    }
  }

  // this doesn't get FRB annotations to avoid frontend confusion. (Flutter gets game from server db)
  #[flutter_rust_bridge::frb(ignore)]
  pub fn get_seasons() -> Vec<String> {
    SEASONS.iter().map(|(s, _)| s.to_string()).collect()
  }
}