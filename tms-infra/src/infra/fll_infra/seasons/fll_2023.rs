use std::vec;

use crate::{infra::fll_infra::{QuestionAnswer, QuestionValidationError}, CategoricalOption, CategoricalQuestion, FllBlueprint, Mission, Question, QuestionInput, QuestionRule};

use super::BaseSeason;

pub struct MasterPiece {}

impl BaseSeason for MasterPiece {
  fn validate(&self, _: Vec<QuestionAnswer>) -> Vec<QuestionValidationError> {
    // TODO: Implement this
    vec![]
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
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsuperpowered%2Fsp_m00.png?alt=media&token=4254e65f-d66a-4998-b726-7f89df87906e".to_string()),
        },

        Mission {
          id: "m01".to_string(),
          label: "M01 - 3D Cinema".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm01.png?alt=media&token=7eeb7bcc-66c4-41ef-9179-580d1a1bd235".to_string()),
        },
      
        Mission {
          id: "m02".to_string(),
          label: "M02 - Theatre Scene Change".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm02.png?alt=media&token=a5a4cb5d-b15c-44ff-a39f-9eba82f01f54".to_string()),
        },
      
        Mission {
          id: "m03".to_string(),
          label: "M03 - Immersive Experience".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm03.png?alt=media&token=b740de59-8f3b-4603-a452-24128c318ae5".to_string()),
        },
      
        Mission {
          id: "m04".to_string(),
          label: "M04 - MASTERPIECE℠".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm04.png?alt=media&token=949eecda-c4ef-4408-a29f-b0f57ebfc5a6".to_string()),
        },
      
        Mission {
          id: "m05".to_string(),
          label: "M05 - Augmented Reality Statue".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm05.png?alt=media&token=6b13a06b-c3d6-49c8-a5b7-def9a849dc63".to_string()),
        },
      
        Mission {
          id: "m06".to_string(),
          label: "M06 - Music Concert Light and Sound".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm06.png?alt=media&token=ebe651f8-85e8-4bb0-9572-1082a19e7c77".to_string()),
        },
      
        Mission {
          id: "m07".to_string(),
          label: "M07 - Hologram Performer".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm07.png?alt=media&token=8b2e9c32-f422-4d01-84b2-f2ee6d2ca544".to_string()),
        },
      
        Mission {
          id: "m08".to_string(),
          label: "M08 - Rolling Camera".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm08.png?alt=media&token=375e673c-345b-494f-b83a-82ae5de42b6d".to_string()),
        },
      
        Mission {
          id: "m09".to_string(),
          label: "M09 - Movie Set".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm09.png?alt=media&token=b8b63278-d844-494e-aea1-a39878528bb4".to_string()),
        },
      
        Mission {
          id: "m10".to_string(),
          label: "M10 - Sound Mixer".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm10.png?alt=media&token=37fad34e-f795-429d-b478-d0bc5cfda77b".to_string()),
        },
      
        Mission {
          id: "m11".to_string(),
          label: "M11 - Light Show".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm11.png?alt=media&token=99f4bea0-094c-4b7f-b3c9-99472509828a".to_string()),
        },
      
        Mission {
          id: "m12".to_string(),
          label: "M12 - Virtual Reality Artist".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm12.png?alt=media&token=9ed9d7e7-5421-4d0b-8e91-8b10db30b093".to_string()),
        },
      
        Mission {
          id: "m13".to_string(),
          label: "M13 - Craft Creator".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm13.png?alt=media&token=a6bab50e-75d5-46e4-8e30-b674bf8a3e79".to_string()),
        },
      
        Mission {
          id: "m14".to_string(),
          label: "M14 - Audience Delivery".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm14.png?alt=media&token=128312e9-391d-4a05-a80d-1b2e1860ce6e".to_string()),
        },
      
        Mission {
          id: "m15".to_string(),
          label: "M15 - Expert Delivery".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm15.png?alt=media&token=4a82c201-b1fa-49bc-a2d9-94eee1c186a8".to_string()),
        },
      
        Mission {
          id: "m16".to_string(),
          label: "M16 - Precision Tokens".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fmasterpiece%2Fm16.png?alt=media&token=02e50c9a-6847-47e5-ba09-a20b8ef9ff66".to_string()),
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
          }),
          rules: vec![],
        },

        Question {
          id: "m01a".to_string(),
          label: "If the 3D cinema's small red beam is completely to the right of the black frame".to_string(),
          label_short: "Beam right?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m02a".to_string(),
          label: "If your theater's red flag is down and the active scene color is:".to_string(),
          label_short: "Flag down + color?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m02b".to_string(),
          label: "Do both teams' active scenes match?".to_string(),
          label_short: "Teams match?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
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
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m04a".to_string(),
          label: "Your team's LEGO® art piece is at least partly in the museum target area:".to_string(),
          label_short: "In area?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m04b".to_string(),
          label: "The art piece is completely supported by the pedestal?".to_string(),
          label_short: "On pedestal?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
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
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m06a".to_string(),
          label: "The lights' orange lever is rotated completely downwards?".to_string(),
          label_short: "Lights?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m06b".to_string(),
          label: "The speakers' orange lever is rotated completely to the left?".to_string(),
          label_short: "Speakers?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m07a".to_string(),
          label: "The performer's orange push activator is completely past the black stage set line?".to_string(),
          label_short: "Turned?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m08a".to_string(),
          label: "The rolling camera's white pointer is left of?".to_string(),
          label_short: "Left of?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m09a".to_string(),
          label: "The boat is touching the mat and is completely past the black scene line?".to_string(),
          label_short: "Boat?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m09b".to_string(),
          label: "The camera is touching the mat and is at least partly in the camera target area?".to_string(),
          label_short: "Camera?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m10a".to_string(),
          label: "Number of sound mixer sliders raised?".to_string(),
          label_short: "Sliders?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m11a".to_string(),
          label: "The light show's white pointer is within zone?".to_string(),
          label_short: "Zone?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m12a".to_string(),
          label: "The chicken is intact and has moved from its starting position?".to_string(),
          label_short: "chicken moved?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m12b".to_string(),
          label: "The chicken is over or completely past the lavender dot?".to_string(),
          label_short: "chicken over dot?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
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
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m13b".to_string(),
          label: "If the craft machine's light pink latch is pointing straight down?".to_string(),
          label_short: "Latch?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m14a".to_string(),
          label: "Number of audience members completely in a target destination?".to_string(),
          label_short: "People?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m14b".to_string(),
          label: "Number of destinations with at least one audience member completely in it?".to_string(),
          label_short: "Destinations?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m15a".to_string(),
          label: "Number of experts at least partly in their target destination?".to_string(),
          label_short: "Experts?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
          }),
          rules: vec![],
        },

        Question {
          id: "m16a".to_string(),
          label: "Precision?".to_string(),
          label_short: "Number of precision tokens remaining?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
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
              CategoricalOption {
                label: "4 - Exceeds".to_string(),
                score: 0,
              },
            ],
            default_option: "3 - Accomplished".to_string(),
          }),
          rules: vec![],
        },
      ],
    }
  }
}