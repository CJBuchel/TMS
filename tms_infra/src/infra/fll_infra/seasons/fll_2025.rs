use std::{collections::HashMap, vec};

use crate::{
  infra::fll_infra::{QuestionAnswer, QuestionValidationError},
  CategoricalOption, CategoricalQuestion, FllBlueprint, Mission, Question, QuestionInput, QuestionRule,
};

use super::BaseSeason;

pub struct Unearthed {}
impl BaseSeason for Unearthed {
  fn validate(&self, answers: &HashMap<String, QuestionAnswer>) -> Vec<QuestionValidationError> {
    let mut errors: Vec<QuestionValidationError> = vec![];
    let mut empty_q_ids: Vec<String> = vec![];

    // Iterate over the HashMap and collect question IDs with empty answers
    let n_empty_ids = answers.values().filter(|r| r.answer.is_empty()).count();

    for (question_id, answer) in answers.iter() {
      if answer.answer.is_empty() {
        empty_q_ids.push(question_id.clone());
      }
    }

    if n_empty_ids > 0 {
      errors.push(QuestionValidationError {
        question_ids: empty_q_ids.join(","),
        message: format!("{} empty answers", n_empty_ids),
      });
    }

    // Game specific validation rules
    let brush = if answers.get("m01b").map(|r| r.answer.as_str()) == Some("Yes") { 1 } else { 0 };
    let topsoil = if answers.get("m02a").map(|r| r.answer.as_str()) != Some("0") && answers.get("m02a").map(|r| !r.answer.is_empty()).unwrap_or(false) {
      1
    } else {
      0
    };
    let minecart = if answers.get("m03b").map(|r| r.answer.as_str()) == Some("Yes") { 1 } else { 0 };
    let artefact = if answers.get("m04a").map(|r| r.answer.as_str()) == Some("Yes") { 1 } else { 0 };
    let ore = if answers.get("m06a").map(|r| r.answer.as_str()) != Some("0") && answers.get("m06a").map(|r| !r.answer.is_empty()).unwrap_or(false) {
      1
    } else {
      0
    };
    let millstone = if answers.get("m07a").map(|r| r.answer.as_str()) == Some("Yes") { 1 } else { 0 };
    let scale_pan = if answers.get("m10b").map(|r| r.answer.as_str()) == Some("Yes") { 1 } else { 0 };

    // m14 max possible
    let m14_max_possible = brush + topsoil + minecart + artefact + ore + millstone + scale_pan;
    let m14a = answers.get("m14a").map(|r| r.answer.parse::<i32>().unwrap_or(0)).unwrap_or(0);

    if m14a > m14_max_possible {
      errors.push(QuestionValidationError {
        question_ids: "m14a".to_string(),
        message: format!("Samples in forum {} exceeds max possible {}", m14a, m14_max_possible),
      });
    }

    errors
  }

  fn get_season(&self) -> String {
    "2025".to_string()
  }

  fn get_fll_game(&self) -> FllBlueprint {
    FllBlueprint {
      robot_game_missions: vec![
        Mission {
          id: "m00".to_string(),
          label: "M00 - Equipment Inspection Bonus".to_string(),
          image_url: None,
        },
        Mission {
          id: "m01".to_string(),
          label: "M01 - Surface Brushing".to_string(),
          image_url: None,
        },
        Mission {
          id: "m02".to_string(),
          label: "M02 - Map Reveal".to_string(),
          image_url: None,
        },
        Mission {
          id: "m03".to_string(),
          label: "M03 - Mineshaft Explorer".to_string(),
          image_url: None,
        },
        Mission {
          id: "m04".to_string(),
          label: "M04 - Careful Recovery".to_string(),
          image_url: None,
        },
        Mission {
          id: "m05".to_string(),
          label: "M05 - Who Lived Here?".to_string(),
          image_url: None,
        },
        Mission {
          id: "m06".to_string(),
          label: "M06 - Forge".to_string(),
          image_url: None,
        },
        Mission {
          id: "m07".to_string(),
          label: "M07 - Heavy Lifting".to_string(),
          image_url: None,
        },
        Mission {
          id: "m08".to_string(),
          label: "M08 - Silo".to_string(),
          image_url: None,
        },
        Mission {
          id: "m09".to_string(),
          label: "M09 - What's on Sale?".to_string(),
          image_url: None,
        },
        Mission {
          id: "m10".to_string(),
          label: "M10 - Tip the Scales".to_string(),
          image_url: None,
        },
        Mission {
          id: "m11".to_string(),
          label: "M11 - Angler Artefacts".to_string(),
          image_url: None,
        },
        Mission {
          id: "m12".to_string(),
          label: "M12 - Salvage Operation".to_string(),
          image_url: None,
        },
        Mission {
          id: "m13".to_string(),
          label: "M13 - Statue Rebuild".to_string(),
          image_url: None,
        },
        Mission {
          id: "m14".to_string(),
          label: "M14 - Forum".to_string(),
          image_url: None,
        },
        Mission {
          id: "m15".to_string(),
          label: "M15 - Site Marking".to_string(),
          image_url: None,
        },
        Mission {
          id: "m16".to_string(),
          label: "M16 - Precision Tokens".to_string(),
          image_url: None,
        },
        Mission {
          id: "gp".to_string(),
          label: "Gracious Professionalism".to_string(),
          image_url: None,
        },
      ],

      robot_game_questions: vec![
        Question {
          id: "m00a".to_string(),
          label: "All team equipment fits in one launch area and under 12 in. (305 mm)?".to_string(),
          label_short: "Inspection?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 20 }],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m01a".to_string(),
          label: "Soil deposits completely cleared, touching the mat".to_string(),
          label_short: "Soil cleared?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "0".to_string(), score: 0 },
              CategoricalOption { label: "1".to_string(), score: 10 },
              CategoricalOption { label: "2".to_string(), score: 20 },
            ],
            default_option: "0".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m01b".to_string(),
          label: "Archaeologist's brush is not touching the dig site".to_string(),
          label_short: "Brush touching?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 10 }],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m02a".to_string(),
          label: "".to_string(),
          label_short: "".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "0".to_string(), score: 0 },
              CategoricalOption { label: "1".to_string(), score: 10 },
              CategoricalOption { label: "2".to_string(), score: 20 },
              CategoricalOption { label: "3".to_string(), score: 30 },
            ],
            default_option: "0".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m03a".to_string(),
          label: "Your team's minecart is on the opposing team's field (must pass completely through the mineshaft entry)?".to_string(),
          label_short: "Your minecart?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 30 }],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m03b".to_string(),
          label: "Opposing team's minecart is on your field?".to_string(),
          label_short: "Opposing minecart?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 10 }],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m04a".to_string(),
          label: "Precious artefact is not touching the mine?".to_string(),
          label_short: "Artefact not touching?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 30 }],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m04b".to_string(),
          label: "Are both support structures standing?".to_string(),
          label_short: "Supports standing?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 10 }],
            default_option: "true".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m05a".to_string(),
          label: "Is the structure floor completely upright?".to_string(),
          label_short: "".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 30 }],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m06a".to_string(),
          label: "Ore blocks not touching the forge?".to_string(),
          label_short: "".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "0".to_string(), score: 0 },
              CategoricalOption { label: "1".to_string(), score: 10 },
              CategoricalOption { label: "2".to_string(), score: 20 },
              CategoricalOption { label: "3".to_string(), score: 30 },
            ],
            default_option: "0".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m07a".to_string(),
          label: "Is the millstone not touching the forge?".to_string(),
          label_short: "".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 30 }],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m08a".to_string(),
          label: "Preserved pieces outside the silo?".to_string(),
          label_short: "Pieces outside?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "0".to_string(), score: 0 },
              CategoricalOption { label: "1".to_string(), score: 10 },
              CategoricalOption { label: "2".to_string(), score: 20 },
              CategoricalOption { label: "3".to_string(), score: 30 },
            ],
            default_option: "0".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m09a".to_string(),
          label: "Is the roof completely raised?".to_string(),
          label_short: "Roof raised?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 20 }],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m09b".to_string(),
          label: "Are the market wares raised?".to_string(),
          label_short: "Wares raised?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 10 }],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m10a".to_string(),
          label: "Is the scale tipped and touching the mat?".to_string(),
          label_short: "Scale tipped?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 20 }],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m10b".to_string(),
          label: "Is the scale pan completely removed?".to_string(),
          label_short: "'Pan removed?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 10 }],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m11a".to_string(),
          label: "Are the artifacts raised above the ground layer?".to_string(),
          label_short: "Artifacts raised?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 20 }],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m11b".to_string(),
          label: "Is the crane flag at least partly lowered?".to_string(),
          label_short: "Crane flag?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 0 }],
            default_option: "No".to_string(),
          }),
          rules: vec![QuestionRule {
            condition: "m11a == Yes".to_string(),
            output: 10,
          }],
        },
        Question {
          id: "m12a".to_string(),
          label: "Is the sand completely cleared (pull activator past the line on the mat)?".to_string(),
          label_short: "Sand cleared?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 20 }],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m12b".to_string(),
          label: "Is the ship completely raised?".to_string(),
          label_short: "Ship raised?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 10 }],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m13a".to_string(),
          label: "'Is the statue completely raised?".to_string(),
          label_short: "Statue raised?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![CategoricalOption { label: "No".to_string(), score: 0 }, CategoricalOption { label: "Yes".to_string(), score: 30 }],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m14a".to_string(),
          label: "Artifacts touching the mat and at least partly in the forum?".to_string(),
          label_short: "Artifacts?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "0".to_string(), score: 0 },
              CategoricalOption { label: "1".to_string(), score: 10 },
              CategoricalOption { label: "2".to_string(), score: 20 },
              CategoricalOption { label: "3".to_string(), score: 30 },
              CategoricalOption { label: "4".to_string(), score: 40 },
              CategoricalOption { label: "5".to_string(), score: 50 },
              CategoricalOption { label: "6".to_string(), score: 60 },
              CategoricalOption { label: "7".to_string(), score: 70 },
            ],
            default_option: "0".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m15a".to_string(),
          label: "Sites with a flag at least partly inside and touching the mat?".to_string(),
          label_short: "Sites flagged?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "0".to_string(), score: 0 },
              CategoricalOption { label: "1".to_string(), score: 10 },
              CategoricalOption { label: "2".to_string(), score: 20 },
              CategoricalOption { label: "3".to_string(), score: 30 },
            ],
            default_option: "0".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m16a".to_string(),
          label: "Precision?".to_string(),
          label_short: "Number of precision tokens remaining?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "0".to_string(), score: 0 },
              CategoricalOption { label: "1".to_string(), score: 10 },
              CategoricalOption { label: "2".to_string(), score: 15 },
              CategoricalOption { label: "3".to_string(), score: 25 },
              CategoricalOption { label: "4".to_string(), score: 35 },
              CategoricalOption { label: "5".to_string(), score: 50 },
              CategoricalOption { label: "6".to_string(), score: 50 },
            ],
            default_option: "6".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "gp".to_string(),
          label: "Gracious Professionalism® displayed at the robot game table?".to_string(),
          label_short: "GP".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "2 - Developing".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "3 - Accomplished".to_string(),
                score: 0,
              },
              CategoricalOption { label: "4 - Exceeds".to_string(), score: 0 },
            ],
            default_option: "3 - Accomplished".to_string(),
          }),
          rules: vec![],
        },
      ],
    }
  }
}
