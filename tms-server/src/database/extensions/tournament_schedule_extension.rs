use tms_schedule_handler::TmsSchedule;

use crate::database::Database;

use super::{GameMatchExtensions, GameTableExtensions, JudgingPodExtensions, JudgingSessionExtensions, TeamExtensions};

#[async_trait::async_trait]
pub trait TournamentScheduleExtensions {
  async fn set_tournament_schedule(&mut self, schedule: TmsSchedule) -> Result<(), String>;
}

#[async_trait::async_trait]
impl TournamentScheduleExtensions for Database {
  async fn set_tournament_schedule(&mut self, schedule: TmsSchedule) -> Result<(), String> {
    // set teams
    for team in schedule.teams {
      match self.insert_team(team.clone(), None).await {
        Ok(_) => {
          log::info!("Inserted team: {}, name: {}, affiliation: {}", team.number, team.name, team.affiliation);
        }
        Err(e) => {
          log::error!("Error inserting team: {}", e);
          return Err(format!("Error inserting team: {}", e));
        }
      }
    }

    // set tables
    for table in schedule.game_tables {
      match self.insert_game_table(table.clone(), None).await {
        Ok(_) => {
          log::info!("Inserted table: {}", table);
        }
        Err(e) => {
          log::error!("Error inserting table: {}", e);
          return Err(format!("Error inserting table: {}", e));
        }
      }
    }

    // set matches
    for game_match in schedule.game_matches {
      match self.insert_game_match(game_match.clone(), None).await {
        Ok(_) => {
          log::info!("Inserted game match: {}", game_match.match_number);
        }
        Err(e) => {
          log::error!("Error inserting game match: {}", e);
          return Err(format!("Error inserting game match: {}", e));
        }
      }
    }

    // set pods
    for pod in schedule.judging_pods {
      match self.insert_judging_pod(pod.clone(), None).await {
        Ok(_) => {
          log::info!("Inserted judging pod: {}", pod);
        }
        Err(e) => {
          log::error!("Error inserting judging pod: {}", e);
          return Err(format!("Error inserting judging pod: {}", e));
        }
      }
    }

    // set sessions
    for session in schedule.judging_sessions {
      match self.insert_judging_session(session.clone(), None).await {
        Ok(_) => {
          log::info!("Inserted judging session: {}", session.session_number);
        }
        Err(e) => {
          log::error!("Error inserting judging session: {}", e);
          return Err(format!("Error inserting judging session: {}", e));
        }
      }
    }

    Ok(())
  }
}
