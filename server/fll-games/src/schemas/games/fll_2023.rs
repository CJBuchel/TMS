use crate::schemas::{Score, QuestionInput, DefaultValue, AusFLLGame, ScoreAnswer, ScoreError};
use crate::{schemas::Mission, firebase_links::MISSION_PICS_20232024};

pub struct Masterpiece;

impl AusFLLGame for Masterpiece {
  fn get_questions(&self) -> Vec<Score> {
    return vec![
      Score {
        id: "m00a".to_string(),
        label: "All team equipment fits in one launch area and under 12 in. (305 mm)?".to_string(),
        label_short: "Inspection?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m01a".to_string(),
        label: "If the 3D cinema's small red beam is completely to the right of the black frame".to_string(),
        label_short: "Beam right?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m02a".to_string(),
        label: "If your theater's red flag is down and the active scene colour is:".to_string(),
        label_short: "Flag down + colour?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Blue".to_string(),
            "Pink".to_string(),
            "Orange".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m02b".to_string(),
        label: "Do both teams' active scenes match?".to_string(),
        label_short: "Teams match?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m03a".to_string(),
        label: "The three immersive experience screens are raised?".to_string(),
        label_short: "Raised?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m04a".to_string(),
        label: "Your team's LEGO® art piece is at least partly in the museum target area:".to_string(),
        label_short: "In area?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m04b".to_string(),
        label: "The art piece is completely supported by the pedestal?".to_string(),
        label_short: "On pedestal?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m05a".to_string(),
        label: "The augmented reality statue's orange lever is rotated completely to the right?".to_string(),
        label_short: "Rotated?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m06a".to_string(),
        label: "The lights' orange lever is rotated completely downwards?".to_string(),
        label_short: "Lights?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m06b".to_string(),
        label: "The speakers' orange lever is rotated completely to the left?".to_string(),
        label_short: "Speakers?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m07a".to_string(),
        label: "The performer's orange push activator is completely past the black stage set line?".to_string(),
        label_short: "Turned?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m08a".to_string(),
        label: "The rolling camera's white pointer is left of?".to_string(),
        label_short: "Left of?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "None".to_string(),
            "Dark blue".to_string(),
            "Dark & medium blue".to_string(),
            "Dark, medium & light blue".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("None".to_string()),
      },
  
      Score {
        id: "m09a".to_string(),
        label: "The boat is touching the mat and is completely past the black scene line?".to_string(),
        label_short: "Boat?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m09b".to_string(),
        label: "The camera is touching the mat and is at least partly in the camera target area?".to_string(),
        label_short: "Camera?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m10a".to_string(),
        label: "Number of sound mixer sliders raised?".to_string(),
        label_short: "Sliders?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "0".to_string(),
            "1".to_string(),
            "2".to_string(),
            "3".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("0".to_string()),
      },
  
      Score {
        id: "m11a".to_string(),
        label: "The light show's white pointer is within zone?".to_string(),
        label_short: "Zone?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "None".to_string(),
            "Yellow".to_string(),
            "Green".to_string(),
            "Blue".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("None".to_string()),
      },
  
      Score {
        id: "m12a".to_string(),
        label: "The chicken is intact and has moved from its starting position?".to_string(),
        label_short: "🐔 moved?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m12b".to_string(),
        label: "The chicken is over or completely past the lavender dot?".to_string(),
        label_short: "🐔 over dot?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m13a".to_string(),
        label: "If the craft machine's orange and white lid is completely open?".to_string(),
        label_short: "Lid?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m13b".to_string(),
        label: "If the craft machine's light pink latch is pointing straight down?".to_string(),
        label_short: "Latch?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "No".to_string(),
            "Yes".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("No".to_string()),
      },
  
      Score {
        id: "m14a".to_string(),
        label: "Number of audience members completely in a target destination?".to_string(),
        label_short: "People?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "0".to_string(),
            "1".to_string(),
            "2".to_string(),
            "3".to_string(),
            "4".to_string(),
            "5".to_string(),
            "6".to_string(),
            "7".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("0".to_string()),
      },
  
      Score {
        id: "m14b".to_string(),
        label: "Number of destinations with at least one audience member completely in it?".to_string(),
        label_short: "Destinations?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "0".to_string(),
            "1".to_string(),
            "2".to_string(),
            "3".to_string(),
            "4".to_string(),
            "5".to_string(),
            "6".to_string(),
            "7".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("0".to_string()),
      },
  
      Score {
        id: "m15a".to_string(),
        label: "Number of experts at least partly in their target destination?".to_string(),
        label_short: "Experts?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "0".to_string(),
            "1".to_string(),
            "2".to_string(),
            "3".to_string(),
            "4".to_string(),
            "5".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("0".to_string()),
      },
  
      Score {
        id: "m16a".to_string(),
        label: "Precision?".to_string(),
        label_short: "Number of precision tokens remaining?".to_string(),
        question_input: QuestionInput::Categorical { 
          options: vec![
            "0".to_string(),
            "1".to_string(),
            "2".to_string(),
            "3".to_string(),
            "4".to_string(),
            "5".to_string(),
            "6".to_string(),
          ],
        },
    
        default_value: DefaultValue::Text("6".to_string()),
      },
  
      Score {
        id: "gp".to_string(),
        label: "Gracious Professionalism® displayed at the robot game table?".to_string(),
        label_short: "GP".to_string(),
        question_input: QuestionInput::Categorical {
          options: vec![
            "2 - Developing".to_string(),
            "3 - Accomplished".to_string(),
            "4 - Exceeds".to_string()
          ],
        },
        default_value: DefaultValue::Text("3 - Accomplished".to_string()),
      },
    ];
  }

  fn get_missions(&self) -> Vec<Mission> {
    return vec![
      Mission {
        prefix: "m00".to_string(),
        title: "M00 - Equipment Inspection Bonus".to_string(),
        image: Some(MISSION_PICS_20232024[0].url.to_string()),
      },
    
      Mission {
        prefix: "m01".to_string(),
        title: "M01 - 3D Cinema".to_string(),
        image: Some(MISSION_PICS_20232024[1].url.to_string()),
      },
    
      Mission {
        prefix: "m02".to_string(),
        title: "M02 - Theatre Scene Change".to_string(),
        image: Some(MISSION_PICS_20232024[2].url.to_string()),
      },
    
      Mission {
        prefix: "m03".to_string(),
        title: "M03 - Immersive Experience".to_string(),
        image: Some(MISSION_PICS_20232024[3].url.to_string()),
      },
    
      Mission {
        prefix: "m04".to_string(),
        title: "M04 - MASTERPIECE℠".to_string(),
        image: Some(MISSION_PICS_20232024[4].url.to_string()),
      },
    
      Mission {
        prefix: "m05".to_string(),
        title: "M05 - Augmented Reality Statue".to_string(),
        image: Some(MISSION_PICS_20232024[5].url.to_string()),
      },
    
      Mission {
        prefix: "m06".to_string(),
        title: "M06 - Music Concert Light and Sound".to_string(),
        image: Some(MISSION_PICS_20232024[6].url.to_string()),
      },
    
      Mission {
        prefix: "m07".to_string(),
        title: "M07 - Hologram Performer".to_string(),
        image: Some(MISSION_PICS_20232024[7].url.to_string()),
      },
    
      Mission {
        prefix: "m08".to_string(),
        title: "M08 - Rolling Camera".to_string(),
        image: Some(MISSION_PICS_20232024[8].url.to_string()),
      },
    
      Mission {
        prefix: "m09".to_string(),
        title: "M09 - Movie Set".to_string(),
        image: Some(MISSION_PICS_20232024[9].url.to_string()),
      },
    
      Mission {
        prefix: "m10".to_string(),
        title: "M10 - Sound Mixer".to_string(),
        image: Some(MISSION_PICS_20232024[10].url.to_string()),
      },
    
      Mission {
        prefix: "m11".to_string(),
        title: "M11 - Light Show".to_string(),
        image: Some(MISSION_PICS_20232024[11].url.to_string()),
      },
    
      Mission {
        prefix: "m12".to_string(),
        title: "M12 - Virtual Reality Artist".to_string(),
        image: Some(MISSION_PICS_20232024[12].url.to_string()),
      },
    
      Mission {
        prefix: "m13".to_string(),
        title: "M13 - Craft Creator".to_string(),
        image: Some(MISSION_PICS_20232024[13].url.to_string()),
      },
    
      Mission {
        prefix: "m14".to_string(),
        title: "M14 - Audience Delivery".to_string(),
        image: Some(MISSION_PICS_20232024[14].url.to_string()),
      },
    
      Mission {
        prefix: "m15".to_string(),
        title: "M15 - Expert Delivery".to_string(),
        image: Some(MISSION_PICS_20232024[15].url.to_string()),
      },
    
      Mission {
        prefix: "m16".to_string(),
        title: "M16 - Precision Tokens".to_string(),
        image: Some(MISSION_PICS_20232024[16].url.to_string()),
      },
    
      Mission {
        prefix: "gp".to_string(),
        title: "Gracious Professionalism".to_string(),
        image: None,
      },
    ];
  }

  fn validate(&self, answers: Vec<ScoreAnswer>) -> Vec<ScoreError> {
    let mut errors: Vec<ScoreError> = vec![];
    let mut empty_q_ids: Vec<String> = vec![];
    let n_empty_ids = answers.iter().filter(|r| r.answer == "").count();

    for r in answers.clone() {
      if r.answer == "" {
        empty_q_ids.push(r.id.clone());
      }
    }

    if n_empty_ids > 0 {
      errors.push(ScoreError {
        id: empty_q_ids.join(","),
        message: format!("{} empty answers", n_empty_ids),
      });
    }
    
    let m14a = self.s_answer(answers.clone(), "m14a");
    let m14b = self.s_answer(answers.clone(), "m14b");
    if m14a != "0" && m14b == "0" {
      errors.push(ScoreError {
        id: "m14a,m14b".to_string(),
        message: "Audiences delivered, but no destinations set!".to_string(),
      });
    }

    return errors;
  }

  fn score(&self, answers: Vec<ScoreAnswer>) -> i32 {
    let mut score = 0;
    // M00
    if self.s_answer(answers.clone(), "m00a") == "Yes" { score += 25; }

    // M01 - 20 points if achieved
    if self.s_answer(answers.clone(), "m01a") == "Yes" { score += 20; }

    // M02 - 10 points per level
    let matching = self.s_answer(answers.clone(), "m02b") == "Yes";
    match self.s_answer(answers.clone(), "m02a").as_str() {
      "Blue" => score += 10 + if matching { 20 } else { 0 },
      "Pink" => score += 20 + if matching { 30 } else { 0 },
      "Orange" => score += 30 + if matching { 10 } else { 0 },
      _ => score += 0
    }

    // M03 - 20 points if Yes
    if self.s_answer(answers.clone(), "m03a") == "Yes" { score += 20; }

    // M04 - 10 points for a, 20 points for b
    if self.s_answer(answers.clone(), "m04a") == "Yes" {
      if self.s_answer(answers.clone(), "m04b") == "Yes" { score += 20 }
      score += 10;
    }

    // M05 - 30 points if Yes
    if self.s_answer(answers.clone(), "m05a") == "Yes" { score += 30; }

    // M06 - 10 points each
    if self.s_answer(answers.clone(), "m06a") == "Yes" { score += 10; }
    if self.s_answer(answers.clone(), "m06b") == "Yes" { score += 10; }

    // M07 - 20 points if Yes
    if self.s_answer(answers.clone(), "m07a") == "Yes" { score += 20; }

    // M08 - 10 points per level
    match self.s_answer(answers.clone(), "m08a").as_str() {
      "Dark blue" => score += 10,
      "Dark & medium blue" => score += 20,
      "Dark, medium & light blue" => score += 30,
      _ => score += 0
    }

    // M09 - 10 points each
    if self.s_answer(answers.clone(), "m09a") == "Yes" { score += 10; }
    if self.s_answer(answers.clone(), "m09b") == "Yes" { score += 10; }

    // M10 - 10 points each
    match self.s_answer(answers.clone(), "m10a").as_str() {
      "1" => score += 10,
      "2" => score += 20,
      "3" => score += 30,
      _ => score += 0
    }

    // M11 - 10 points each
    match self.s_answer(answers.clone(), "m11a").as_str() {
      "Yellow" => score += 10,
      "Green" => score += 20,
      "Blue" => score += 30,
      _ => score += 0
    }

    // M12 - 10 points for a, 30 points if a + b
    if self.s_answer(answers.clone(), "m12a") == "Yes" {
      if self.s_answer(answers.clone(), "m12b") == "Yes" { score += 20 }
      score += 10;
    }

    // M13 - 10 points for a, 20 points for b
    if self.s_answer(answers.clone(), "m13a") == "Yes" { score += 10; }
    if self.s_answer(answers.clone(), "m13b") == "Yes" { score += 20; }



    // M14 - 5 each for a, 5 each for b
    match self.s_answer(answers.clone(), "m14a").as_str() {
      "1" => score += 5,
      "2" => score += 10,
      "3" => score += 15,
      "4" => score += 20, // heh, 420
      "5" => score += 25,
      "6" => score += 30,
      "7" => score += 35,
      _ => score += 0
    }

    match self.s_answer(answers.clone(), "m14b").as_str() {
      "1" => score += 5,
      "2" => score += 10,
      "3" => score += 15,
      "4" => score += 20,
      "5" => score += 25,
      "6" => score += 30,
      "7" => score += 35,
      _ => score += 0
    }

    // M15 - 10 each
    match self.s_answer(answers.clone(), "m15a").as_str() {
      "1" => score += 10,
      "2" => score += 20,
      "3" => score += 30,
      "4" => score += 40,
      "5" => score += 50,
      _ => score += 0
    }

    // M16
    match self.s_answer(answers.clone(), "m16a").as_str() {
      "6" => score += 50,
      "5" => score += 50,
      "4" => score += 35,
      "3" => score += 25,
      "2" => score += 15,
      "1" => score += 10,
      _ => score += 0
    }

    return score;
  }

  fn get_game(&self) -> crate::schemas::Game {
    return crate::schemas::Game {
      name: "Masterpiece".to_string(),
      program: "FLL_CHALLENGE".to_string(),
      rule_book_url: "https://firstinspiresst01.blob.core.windows.net/first-in-show-masterpiece/fll-challenge/fll-challenge-masterpiece-rgr-en.pdf".to_string(),
      missions: self.get_missions(),
      questions: self.get_questions(),
    };
  }
}