use crate::schemas::{Score, QuestionInput, DefaultValue};

pub fn get_questions_20232024() -> Vec<Score> {
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