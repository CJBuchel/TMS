use crate::{schemas::Mission, firebase_links::MISSION_PICS_20232024};

pub fn get_missions_20232024() -> Vec<Mission> {
  return vec![
    Mission {
      prefix: "m00".to_string(),
      title: "M00 - Equipment Inspection Bonus".to_string(),
      image: None,
    },
  
    Mission {
      prefix: "m01".to_string(),
      title: "M01 - 3D Cinema".to_string(),
      image: Some(MISSION_PICS_20232024[0].url.to_string()),
    },
  
    Mission {
      prefix: "m02".to_string(),
      title: "M02 - Theatre Scene Change".to_string(),
      image: Some(MISSION_PICS_20232024[1].url.to_string()),
    },
  
    Mission {
      prefix: "m03".to_string(),
      title: "M03 - Immersive Experience".to_string(),
      image: Some(MISSION_PICS_20232024[2].url.to_string()),
    },
  
    Mission {
      prefix: "m04".to_string(),
      title: "M04 - MASTERPIECE℠".to_string(),
      image: Some(MISSION_PICS_20232024[3].url.to_string()),
    },
  
    Mission {
      prefix: "m05".to_string(),
      title: "M05 - Augmented Reality Statue".to_string(),
      image: Some(MISSION_PICS_20232024[4].url.to_string()),
    },
  
    Mission {
      prefix: "m06".to_string(),
      title: "M06 - Music Concert Light and Sound".to_string(),
      image: Some(MISSION_PICS_20232024[5].url.to_string()),
    },
  
    Mission {
      prefix: "m07".to_string(),
      title: "M07 - Hologram Performer".to_string(),
      image: Some(MISSION_PICS_20232024[6].url.to_string()),
    },
  
    Mission {
      prefix: "m08".to_string(),
      title: "M08 - Rolling Camera".to_string(),
      image: Some(MISSION_PICS_20232024[7].url.to_string()),
    },
  
    Mission {
      prefix: "m09".to_string(),
      title: "M09 - Movie Set".to_string(),
      image: Some(MISSION_PICS_20232024[8].url.to_string()),
    },
  
    Mission {
      prefix: "m10".to_string(),
      title: "M10 - Sound Mixer".to_string(),
      image: Some(MISSION_PICS_20232024[9].url.to_string()),
    },
  
    Mission {
      prefix: "m11".to_string(),
      title: "M11 - Light Show".to_string(),
      image: Some(MISSION_PICS_20232024[10].url.to_string()),
    },
  
    Mission {
      prefix: "m12".to_string(),
      title: "M12 - Virtual Reality Artist".to_string(),
      image: Some(MISSION_PICS_20232024[11].url.to_string()),
    },
  
    Mission {
      prefix: "m13".to_string(),
      title: "M13 - Craft Creator".to_string(),
      image: Some(MISSION_PICS_20232024[12].url.to_string()),
    },
  
    Mission {
      prefix: "m14".to_string(),
      title: "M14 - Audience Delivery".to_string(),
      image: Some(MISSION_PICS_20232024[13].url.to_string()),
    },
  
    Mission {
      prefix: "m15".to_string(),
      title: "M15 - Expert Delivery".to_string(),
      image: Some(MISSION_PICS_20232024[14].url.to_string()),
    },
  
    Mission {
      prefix: "m16".to_string(),
      title: "M16 - Precision Tokens".to_string(),
      image: Some(MISSION_PICS_20232024[15].url.to_string()),
    },
  
    Mission {
      prefix: "gp".to_string(),
      title: "Gracious Professionalism".to_string(),
      image: None,
    },
  ];
}