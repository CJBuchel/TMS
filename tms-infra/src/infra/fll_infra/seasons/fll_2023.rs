use std::vec;

use crate::{infra::fll_infra::{QuestionAnswer, QuestionValidationError}, CategoricalOption, CategoricalQuestion, DataSchemeExtensions, FllBlueprint, Mission, Question, QuestionRule, QuestionType};

use super::BaseSeason;

pub struct MasterPiece {}

impl BaseSeason for MasterPiece {
  fn validate(&self, _: Vec<QuestionAnswer>) -> Vec<QuestionValidationError> {
    vec![] // TODO: Implement this
  }

  fn get_season(&self) -> String {
    "2023".to_string()
  }

  fn get_fll_game(&self) -> FllBlueprint {
    FllBlueprint {
      robot_game_missions: vec![
        Mission {
          id: "m00".to_string(),
          label: "M00 - Equipment Inspection Bonus".to_string(),
          image_url: "".to_string(),
        },

        Mission {
          id: "m01".to_string(),
          label: "M01 - 3D Cinema".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "m02".to_string(),
          label: "M02 - Theatre Scene Change".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "m03".to_string(),
          label: "M03 - Immersive Experience".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "m04".to_string(),
          label: "M04 - MASTERPIECE℠".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "m05".to_string(),
          label: "M05 - Augmented Reality Statue".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "m06".to_string(),
          label: "M06 - Music Concert Light and Sound".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "m07".to_string(),
          label: "M07 - Hologram Performer".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "m08".to_string(),
          label: "M08 - Rolling Camera".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "m09".to_string(),
          label: "M09 - Movie Set".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "m10".to_string(),
          label: "M10 - Sound Mixer".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "m11".to_string(),
          label: "M11 - Light Show".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "m12".to_string(),
          label: "M12 - Virtual Reality Artist".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "m13".to_string(),
          label: "M13 - Craft Creator".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "m14".to_string(),
          label: "M14 - Audience Delivery".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "m15".to_string(),
          label: "M15 - Expert Delivery".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "m16".to_string(),
          label: "M16 - Precision Tokens".to_string(),
          image_url: "".to_string(),
        },
      
        Mission {
          id: "gp".to_string(),
          label: "Gracious Professionalism".to_string(),
          image_url: "".to_string(),
        },
      ],


      robot_game_questions: vec![
        Question {
          id: "m00a".to_string(),
          label: "All team equipment fits in one launch area and under 12 in. (305 mm)?".to_string(),
          label_short: "Inspection?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yes".to_string(),
                score: 20,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m01a".to_string(),
          label: "If the 3D cinema's small red beam is completely to the right of the black frame".to_string(),
          label_short: "Beam right?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yes".to_string(),
                score: 20,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m02a".to_string(),
          label: "If your theater's red flag is down and the active scene color is:".to_string(),
          label_short: "Flag down + color?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Blue".to_string(),
                score: 10,
              },
              CategoricalOption {
                label: "Pink".to_string(),
                score: 20,
              },
              CategoricalOption {
                label: "Orange".to_string(),
                score: 30,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m02b".to_string(),
          label: "Do both teams' active scenes match?".to_string(),
          label_short: "Teams match?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "Yes".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![
            QuestionRule {
              condition: "m02a == Blue".to_string(),
              output: 20,
            },
            QuestionRule {
              condition: "m02a == Pink".to_string(),
              output: 30,
            },
            QuestionRule {
              condition: "m02a == Orange".to_string(),
              output: 10,
            },
          ],
        },

        Question {
          id: "m03a".to_string(),
          label: "The three immersive experience screens are raised?".to_string(),
          label_short: "Raised?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yes".to_string(),
                score: 20,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m04a".to_string(),
          label: "Your team's LEGO® art piece is at least partly in the museum target area:".to_string(),
          label_short: "In area?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yes".to_string(),
                score: 10,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m04b".to_string(),
          label: "The art piece is completely supported by the pedestal?".to_string(),
          label_short: "On pedestal?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yes".to_string(),
                score: 0,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![
            QuestionRule {
              condition: "m04a == Yes".to_string(),
              output: 20,
            },
          ],
        },

        Question {
          id: "m05a".to_string(),
          label: "The augmented reality statue's orange lever is rotated completely to the right?".to_string(),
          label_short: "Rotated?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yes".to_string(),
                score: 30,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m06a".to_string(),
          label: "The lights' orange lever is rotated completely downwards?".to_string(),
          label_short: "Lights?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yes".to_string(),
                score: 10,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m06b".to_string(),
          label: "The speakers' orange lever is rotated completely to the left?".to_string(),
          label_short: "Speakers?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yes".to_string(),
                score: 10,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m07a".to_string(),
          label: "The performer's orange push activator is completely past the black stage set line?".to_string(),
          label_short: "Turned?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yes".to_string(),
                score: 20,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m08a".to_string(),
          label: "The rolling camera's white pointer is left of?".to_string(),
          label_short: "Left of?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "None".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Dark blue".to_string(),
                score: 10,
              },
              CategoricalOption {
                label: "Dark & medium blue".to_string(),
                score: 20,
              },
              CategoricalOption {
                label: "Dark, medium & light blue".to_string(),
                score: 30,
              },
            ],
            default_option: "None".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m09a".to_string(),
          label: "The boat is touching the mat and is completely past the black scene line?".to_string(),
          label_short: "Boat?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yes".to_string(),
                score: 10,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m09b".to_string(),
          label: "The camera is touching the mat and is at least partly in the camera target area?".to_string(),
          label_short: "Camera?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yes".to_string(),
                score: 10,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m10a".to_string(),
          label: "Number of sound mixer sliders raised?".to_string(),
          label_short: "Sliders?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "0".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "1".to_string(),
                score: 10,
              },
              CategoricalOption {
                label: "2".to_string(),
                score: 20,
              },
              CategoricalOption {
                label: "3".to_string(),
                score: 30,
              },
            ],
            default_option: "0".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m11a".to_string(),
          label: "The light show's white pointer is within zone?".to_string(),
          label_short: "Zone?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "None".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yellow".to_string(),
                score: 10,
              },
              CategoricalOption {
                label: "Green".to_string(),
                score: 20,
              },
              CategoricalOption {
                label: "Blue".to_string(),
                score: 30,
              },
            ],
            default_option: "None".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m12a".to_string(),
          label: "The chicken is intact and has moved from its starting position?".to_string(),
          label_short: "🐔 moved?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yes".to_string(),
                score: 10,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m12b".to_string(),
          label: "The chicken is over or completely past the lavender dot?".to_string(),
          label_short: "🐔 over dot?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yes".to_string(),
                score: 0,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![
            QuestionRule {
              condition: "m12a == Yes".to_string(),
              output: 20,
            },
          ],
        },

        Question {
          id: "m13a".to_string(),
          label: "If the craft machine's orange and white lid is completely open?".to_string(),
          label_short: "Lid?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yes".to_string(),
                score: 10,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m13b".to_string(),
          label: "If the craft machine's light pink latch is pointing straight down?".to_string(),
          label_short: "Latch?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "No".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "Yes".to_string(),
                score: 10,
              },
            ],
            default_option: "No".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m14a".to_string(),
          label: "Number of audience members completely in a target destination?".to_string(),
          label_short: "People?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "0".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "1".to_string(),
                score: 5,
              },
              CategoricalOption {
                label: "2".to_string(),
                score: 10,
              },
              CategoricalOption {
                label: "3".to_string(),
                score: 15,
              },
              CategoricalOption {
                label: "4".to_string(), // heh, 420
                score: 20,
              },
              CategoricalOption {
                label: "5".to_string(),
                score: 25,
              },
              CategoricalOption {
                label: "6".to_string(),
                score: 30,
              },
              CategoricalOption {
                label: "7".to_string(),
                score: 35,
              },
            ],
            default_option: "0".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m14b".to_string(),
          label: "Number of destinations with at least one audience member completely in it?".to_string(),
          label_short: "Destinations?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "0".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "1".to_string(),
                score: 5,
              },
              CategoricalOption {
                label: "2".to_string(),
                score: 10,
              },
              CategoricalOption {
                label: "3".to_string(),
                score: 15,
              },
              CategoricalOption {
                label: "4".to_string(),
                score: 20,
              },
              CategoricalOption {
                label: "5".to_string(),
                score: 25,
              },
              CategoricalOption {
                label: "6".to_string(),
                score: 30,
              },
              CategoricalOption {
                label: "7".to_string(),
                score: 35,
              },
            ],
            default_option: "0".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m15a".to_string(),
          label: "Number of experts at least partly in their target destination?".to_string(),
          label_short: "Experts?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "0".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "1".to_string(),
                score: 10,
              },
              CategoricalOption {
                label: "2".to_string(),
                score: 20,
              },
              CategoricalOption {
                label: "3".to_string(),
                score: 30,
              },
              CategoricalOption {
                label: "4".to_string(),
                score: 40,
              },
              CategoricalOption {
                label: "5".to_string(),
                score: 50,
              },
            ],
            default_option: "0".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "m16a".to_string(),
          label: "Precision?".to_string(),
          label_short: "Number of precision tokens remaining?".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "0".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "1".to_string(),
                score: 10,
              },
              CategoricalOption {
                label: "2".to_string(),
                score: 15,
              },
              CategoricalOption {
                label: "3".to_string(),
                score: 25,
              },
              CategoricalOption {
                label: "4".to_string(),
                score: 35,
              },
              CategoricalOption {
                label: "5".to_string(),
                score: 50,
              },
              CategoricalOption {
                label: "6".to_string(),
                score: 50,
              },
            ],
            default_option: "6".to_string(),
          }.to_json_string(),
          rules: vec![],
        },

        Question {
          id: "gp".to_string(),
          label: "Gracious Professionalism® displayed at the robot game table?".to_string(),
          label_short: "GP".to_string(),
          question_type: QuestionType::Categorical,
          question_input_def: CategoricalQuestion {
            options: vec![
              CategoricalOption {
                label: "2 - Developing".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "3 - Accomplished".to_string(),
                score: 0,
              },
              CategoricalOption {
                label: "4 - Exceeds".to_string(),
                score: 0,
              },
            ],
            default_option: "3 - Accomplished".to_string(),
          }.to_json_string(),
          rules: vec![],
        },
      ],
    }
  }
}