use std::{collections::HashMap, vec};

use crate::{
  infra::fll_infra::{QuestionAnswer, QuestionValidationError},
  CategoricalOption, CategoricalQuestion, FllBlueprint, Mission, Question, QuestionInput,
};

use super::BaseSeason;

pub struct Submerged {}

impl BaseSeason for Submerged {
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

    //
    // Game validations
    //

    // m01
    let m01a = answers.get("m01a").map_or("".to_string(), |r| r.answer.clone());
    let m01b = answers.get("m01b").map_or("".to_string(), |r| r.answer.clone());
    if m01a == "No" && m01b == "Yes" {
      errors.push(QuestionValidationError {
        question_ids: "m01a,m01b".to_string(),
        message: "Coral tree can't be in it's holder without being raised!".to_string(),
      });
    }

    // m02
    let m02a = answers.get("m02a").map_or("".to_string(), |r| r.answer.clone());
    let m02b = answers.get("m02b").map_or("".to_string(), |r| r.answer.clone());
    if m02a == "No" && m02b == "Yes" {
      errors.push(QuestionValidationError {
        question_ids: "m02a,m02b".to_string(),
        message: "Shark can't be in the habitat without leaving the cave".to_string(),
      });
    }

    // m04
    let m04a = answers.get("m04a").map_or("".to_string(), |r| r.answer.clone());
    let m04b = answers.get("m04b").map_or("".to_string(), |r| r.answer.clone());
    if m04a == "No" && m04b == "Yes" {
      errors.push(QuestionValidationError {
        question_ids: "m04a,m04b".to_string(),
        message: "Scuba diver can't be on the coral reef support without leaving the nursery".to_string(),
      });
    }

    // m09
    let m09a = answers.get("m09a").map_or("".to_string(), |r| r.answer.clone());
    let m09b = answers.get("m09b").map_or("".to_string(), |r| r.answer.clone());
    if m09a == "No" && m09b == "Yes" {
      errors.push(QuestionValidationError {
        question_ids: "m09a,m09b".to_string(),
        message: "Unknown creature can't be in the seep if it's not released".to_string(),
      });
    }

    // m15
    let m07a = if answers.get("m07a").map_or("".to_string(), |r| r.answer.clone()) == "Yes" { 1 } else { 0 };
    let m14a = if answers.get("m14a").map_or("".to_string(), |r| r.answer.clone()) == "Yes" { 1 } else { 0 };
    let m14b = if answers.get("m14b").map_or("".to_string(), |r| r.answer.clone()) == "Yes" { 1 } else { 0 };
    let m14c = if answers.get("m14c").map_or("".to_string(), |r| r.answer.clone()) == "Yes" { 1 } else { 0 };
    let m14d: i32 = match answers.get("m14d").map_or("".to_string(), |r| r.answer.clone()).parse() {
      Ok(v) => v,
      Err(_) => 0,
    };

    let m15_max_possible = m07a + m14a + m14b + m14c + m14d;
    let m15a: i32 = match answers.get("m15a").map_or("".to_string(), |r| r.answer.clone()).parse() {
      Ok(v) => v,
      Err(_) => 0,
    };

    if m15a > m15_max_possible {
      errors.push(QuestionValidationError {
        question_ids: "m15a".to_string(),
        message: "Samples in the cargo area is greater than samples released / moved".to_string(),
      });
    }

    errors
  }

  fn get_season(&self) -> String {
    "2024".to_string()
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
          label: "M01 - Coral Nursery".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm01.png?alt=media&token=890336d1-0c4b-40c7-8728-74f1b5cd0c0e".to_string()),
        },
        Mission {
          id: "m02".to_string(),
          label: "M02 - Shark".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm02.png?alt=media&token=1f7a4483-3fcd-47a3-80d4-3574a2805c9e".to_string()),
        },
        Mission {
          id: "m03".to_string(),
          label: "M03 - Coral Reef".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm03.png?alt=media&token=35d3fa56-a386-41d7-b6dc-71d49cacb6b9".to_string()),
        },
        Mission {
          id: "m04".to_string(),
          label: "M04 - Scuba Diver".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm04.png?alt=media&token=4ba33459-2fcc-49fe-bed7-2b7784b740fc".to_string()),
        },
        Mission {
          id: "m05".to_string(),
          label: "M05 - Angler Fish".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm05.png?alt=media&token=d4991f56-5354-4bbb-9d97-bec071de207e".to_string()),
        },
        Mission {
          id: "m06".to_string(),
          label: "M06 - Raise the Mast".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm06.png?alt=media&token=cb987744-88f6-4a04-bb25-f8b4b5de8de3".to_string()),
        },
        Mission {
          id: "m07".to_string(),
          label: "M07 - Kraken's Treasure".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm07.png?alt=media&token=ce22fd7c-b735-4a2f-9679-315ebc54747d".to_string()),
        },
        Mission {
          id: "m08".to_string(),
          label: "M08 - Artificial Habitat".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm08.png?alt=media&token=65969fbf-3f16-47d5-a362-b2c03f4b6350".to_string()),
        },
        Mission {
          id: "m09".to_string(),
          label: "M09 - Unexpected Encounter".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm09.png?alt=media&token=3885451c-befd-48d5-9a5b-89dab5ac8988".to_string()),
        },
        Mission {
          id: "m10".to_string(),
          label: "M10 - Send Over the Submersible".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm10.png?alt=media&token=f5e6c7ac-2495-4b11-afb0-ed9fdecf09c2".to_string()),
        },
        Mission {
          id: "m11".to_string(),
          label: "M11 - Sonar Discovery".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm11.png?alt=media&token=cc568b7b-7885-4998-96db-40657a29fd5b".to_string()),
        },
        Mission {
          id: "m12".to_string(),
          label: "M12 - Feed the Whale".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm12.png?alt=media&token=a0491454-1dc1-4a39-ac02-0767491f726b".to_string()),
        },
        Mission {
          id: "m13".to_string(),
          label: "M13 - Changing Shipping Lanes".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm13.png?alt=media&token=ebe85962-f11e-4a30-9658-2908eaf5bc5e".to_string()),
        },
        Mission {
          id: "m14".to_string(),
          label: "M14 - Sample Collection".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm14.png?alt=media&token=14ba4f48-8a68-4fd0-b450-190b72e4d117".to_string()),
        },
        Mission {
          id: "m15".to_string(),
          label: "M15 - Research Vessel".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm15.png?alt=media&token=c02a068e-9be7-4cfb-a3d0-f27888113c01".to_string()),
        },
        Mission {
          id: "m16".to_string(),
          label: "M16 - Precision Tokens".to_string(),
          image_url: Some("https://firebasestorage.googleapis.com/v0/b/firstaustralia-system.appspot.com/o/scoring%2Fsubmerged%2Fm16.png?alt=media&token=df25500a-98e5-456a-9c1d-6bdcc15c3eef".to_string()),
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
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 20 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m01a".to_string(),
          label: "Is the coral tree hanging on the coral tree support?".to_string(),
          label_short: "Coral tree on support?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 20 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m01b".to_string(),
          label: "Is the bottom of the coral tree in its holder?".to_string(),
          label_short: "Coral tree in holder?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 10 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m01c".to_string(),
          label: "Are the coral buds flipped up?".to_string(),
          label_short: "Coral buds up?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 20 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m02a".to_string(),
          label: "Is the shark not touching the cave?".to_string(),
          label_short: "Shark no cave?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 20 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m02b".to_string(),
          label: "Is the shark at least partially touching the shark habitat mat?".to_string(),
          label_short: "Shark not touching?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 10 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m03a".to_string(),
          label: "Is the coral reef flipped up & not touching the mat?".to_string(),
          label_short: "coral not touching?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 20 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m03b".to_string(),
          label: "Number of reef segments upright, out of home, touching mat".to_string(),
          label_short: "Reef segments?".to_string(),
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
          id: "m04a".to_string(),
          label: "Is the scuba diver not touching the coral nursery?".to_string(),
          label_short: "Scuba moved?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 20 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m04b".to_string(),
          label: "Is the angler fish latched within the shipwreck?".to_string(),
          label_short: "Angler fish?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 20 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m05a".to_string(),
          label: "Is the angler fish latched within the shipwreck?".to_string(),
          label_short: "Angler fish?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 30 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m06a".to_string(),
          label: "Is the shipwrecks mast completely raised?".to_string(),
          label_short: "Mast?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 30 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m07a".to_string(),
          label: "Is the treasure chest completely outside the krakens nest?".to_string(),
          label_short: "Treasure chest?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 20 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m08a".to_string(),
          label: "Number of artificial habitat stack segments completely flat & upright?".to_string(),
          label_short: "Artificial habitat?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "0".to_string(), score: 0 },
              CategoricalOption { label: "1".to_string(), score: 10 },
              CategoricalOption { label: "2".to_string(), score: 20 },
              CategoricalOption { label: "3".to_string(), score: 30 },
              CategoricalOption { label: "4".to_string(), score: 40 },
            ],
            default_option: "0".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m09a".to_string(),
          label: "Is the unknown creature released?".to_string(),
          label_short: "Unknown released?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 20 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m09b".to_string(),
          label: "Is the unknown creature partly in the cold seep?".to_string(),
          label_short: "Unknown seep?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 10 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m10a".to_string(),
          label: "Is your teams yellow flag down?".to_string(),
          label_short: "Yellow flag?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 30 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m10b".to_string(),
          label: "Is the submersible clearly closer to the opposing field?".to_string(),
          label_short: "Submersible?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 10 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m11a".to_string(),
          label: "Number of whales revealed?".to_string(),
          label_short: "Whales?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "0".to_string(), score: 0 },
              CategoricalOption { label: "1".to_string(), score: 20 },
              CategoricalOption { label: "2".to_string(), score: 30 },
            ],
            default_option: "0".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m12a".to_string(),
          label: "Number of krill partly in the whale's mouth?".to_string(),
          label_short: "Krill?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "0".to_string(), score: 0 },
              CategoricalOption { label: "1".to_string(), score: 10 },
              CategoricalOption { label: "2".to_string(), score: 20 },
              CategoricalOption { label: "3".to_string(), score: 30 },
              CategoricalOption { label: "4".to_string(), score: 40 },
              CategoricalOption { label: "5".to_string(), score: 50 },
            ],
            default_option: "0".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m13a".to_string(),
          label: "Is the ship in the new shipping lane, touching the mat?".to_string(),
          label_short: "Ship?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 20 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m14a".to_string(),
          label: "Is the water sample completely outside the sample area?".to_string(),
          label_short: "Water sample?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 5 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m14b".to_string(),
          label: "Is the seabed sample not touching the seabed?".to_string(),
          label_short: "Seabed sample?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 10 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m14c".to_string(),
          label: "Is the plankton sample not touching the kelp forest?".to_string(),
          label_short: "Plankton sample?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 10 },
            ],
            default_option: "No".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m14d".to_string(),
          label: "Number of trident pieces not touching the shipwreck?".to_string(),
          label_short: "Trident pieces?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "0".to_string(), score: 0 },
              CategoricalOption { label: "1".to_string(), score: 20 },
              CategoricalOption { label: "2".to_string(), score: 30 },
            ],
            default_option: "0".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m15a".to_string(),
          label: "Number of samples, trident part(s), or treasure chest at least partly in the cargo area?".to_string(),
          label_short: "Samples in cargo?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "0".to_string(), score: 0 },
              CategoricalOption { label: "1".to_string(), score: 5 },
              CategoricalOption { label: "2".to_string(), score: 10 },
              CategoricalOption { label: "3".to_string(), score: 15 },
              CategoricalOption { label: "4".to_string(), score: 20 },
              CategoricalOption { label: "5".to_string(), score: 25 },
              CategoricalOption { label: "6".to_string(), score: 30 },
            ],
            default_option: "0".to_string(),
          }),
          rules: vec![],
        },
        Question {
          id: "m15b".to_string(),
          label: "Is the ports latch at least partly in the research vessel's loop?".to_string(),
          label_short: "Ports latch?".to_string(),
          input: QuestionInput::Categorical(CategoricalQuestion {
            options: vec![
              CategoricalOption { label: "No".to_string(), score: 0 },
              CategoricalOption { label: "Yes".to_string(), score: 20 },
            ],
            default_option: "No".to_string(),
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