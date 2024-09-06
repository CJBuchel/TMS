use crate::database::*;
use tms_schedule_handler::TmsSchedule;

use crate::{database::SharedDatabase, network::BadRequestWithMessage};

pub async fn tournament_schedule_set_csv_handler(request: String, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  match TmsSchedule::from(&request) {
    Ok(s) => {
      // reply with message
      log::info!(
        "Parsed schedule, teams: {}, matches: {}, practice: {}, judging: {}",
        s.teams.len(),
        s.game_matches.len(),
        s.practice_game_matches.len(),
        s.judging_sessions.len()
      );
      // set schedule
      let mut write_db = db.write().await;
      match write_db.set_tournament_schedule(s).await {
        Ok(_) => {
          log::info!("Set tournament schedule");
        }
        Err(e) => {
          log::error!("Failed to set tournament schedule: {}", e);
          // reply with message
          return Err(warp::reject::custom(BadRequestWithMessage { message: e }));
        }
      }
      Ok(warp::http::StatusCode::OK)
    }
    Err(e) => {
      log::error!("Failed to parse schedule: {}", e);
      // reply with message
      Err(warp::reject::custom(BadRequestWithMessage { message: e }))
    }
  }
}
