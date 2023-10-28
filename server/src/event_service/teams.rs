use log::error;

use crate::db::db::TmsDB;


pub struct Teams {
  tms_db: std::sync::Arc<TmsDB>,
}


impl Teams {
  pub fn new(tms_db: std::sync::Arc<TmsDB>) -> Self {
    Self {
      tms_db
    }
  }

  fn remove_team_matches(&self, team_number: String) -> Result<(), String> {
    // find all instances of team in matches and remove them
    let matches_iter = self.tms_db.tms_data.matches.iter();
    for match_raw in matches_iter {
      let mut game_match = match match_raw {
        Ok(game_match) => game_match.1,
        _ => {
          error!("Failed to get match (matches get) {}", match_raw.err().unwrap());
          return Err("Failed to get match".to_string());
        }
      };

      for table in game_match.match_tables.clone() {
        if table.team_number == team_number {
          // remove OnTable structure from game_match
          game_match.match_tables.retain(|t| t.team_number != team_number);
          // update game_match in db
          match self.tms_db.tms_data.matches.insert(game_match.match_number.as_bytes(), game_match.clone()) {
            Ok(_) => {},
            Err(_) => {
              error!("Failed to update match {}", game_match.match_number);
              return Err("Failed to update match".to_string());
            }
          }
        }
      }
    }

    Ok(())
  }

  fn remove_team_judging(&self, team_number: String) -> Result<(), String> {
    // remove team from judging sessions
    let judging_iter = self.tms_db.tms_data.judging_sessions.iter();
    for judging_raw in judging_iter {
      let mut judging_session = match judging_raw {
        Ok(judging_session) => judging_session.1,
        _ => {
          error!("Failed to get judging session (judging get) {}", judging_raw.err().unwrap());
          return Err("Failed to get judging session".to_string());
        }
      };

      for pod in judging_session.judging_pods.clone() {
        if pod.team_number == team_number {
          // remove pod from judging session
          judging_session.judging_pods.retain(|p| p.team_number != team_number);
          // update judging session in db
          match self.tms_db.tms_data.judging_sessions.insert(judging_session.session_number.as_bytes(), judging_session.clone()) {
            Ok(_) => {},
            Err(_) => {
              error!("Failed to update judging session {}", judging_session.session_number);
              return Err("Failed to update judging session".to_string());
            }
          }
        }
      }
    }

    Ok(())
  }

  pub fn remove_team(&self, team_number: String) -> Result<(), String> {
    // remove from matches, teams, and judging

    // remove team from matches
    match self.remove_team_matches(team_number.clone()) {
      Ok(_) => {},
      Err(_) => {
        error!("Failed to remove team {} from matches, will continue removal...", team_number);
      }
    }

    // remove team from judging
    match self.remove_team_judging(team_number.clone()) {
      Ok(_) => {},
      Err(_) => {
        error!("Failed to remove team {} from judging, will continue removal...", team_number);
      }
    }

    // remove team from teams
    match self.tms_db.tms_data.teams.remove(team_number.as_bytes()) {
      Ok(_) => {},
      Err(_) => {
        error!("Failed to remove team from teams, flagged as fail {}", team_number);
        return Err("Failed to remove team".to_string());
      }
    }

    Ok(())
  }
}