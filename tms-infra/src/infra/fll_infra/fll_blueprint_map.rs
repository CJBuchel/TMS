
use std::collections::HashMap;

use super::{BaseSeason, FllBlueprint, MasterPiece, QuestionAnswer, QuestionValidationError};

const SEASONS: &[(&str, &'static dyn BaseSeason)] = &[
  ("2023", &MasterPiece {}),
];


pub struct FllBlueprintMap {}

impl FllBlueprintMap {
  pub fn validate(season: String, answers: Vec<QuestionAnswer>) -> Option<Vec<QuestionValidationError>> {
    // switch to hashmap, for faster lookup
    let answers_map: HashMap<String, QuestionAnswer> = answers.iter().map(|a| (a.question_id.clone(), a.clone())).collect();
    // match_season!(season, validate(answers))
    match SEASONS.iter().find(|(s, _)| *s == season) {
      Some((_, season)) => Some(season.validate(&answers_map)),
      None => None,
    }
  }

  pub fn calculate_score(blueprint: FllBlueprint, answers: Vec<QuestionAnswer>) -> i32 {
    // switch to hashmap, for faster lookup
    let answers_map: HashMap<String, QuestionAnswer> = answers.iter().map(|a| (a.question_id.clone(), a.clone())).collect();
    
    blueprint.robot_game_questions.iter().fold(0, |acc, question| {
      acc + question.get_score(&answers_map)
    })
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