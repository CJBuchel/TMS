use tms_schedule_handler::TmsSchedule;

use crate::database::Database;

use super::TeamExtensions;


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
        },
        Err(e) => {
          log::error!("Error inserting team: {}", e);
          return Err(format!("Error inserting team: {}", e));
        },
      }
    }

    Ok(())
  }
}