
use tms_schedule_handler::TmsSchedule;

use crate::{database::SharedDatabase, network::BadRequestWithMessage};

pub async fn tournament_schedule_set_csv_handler(request: String, _db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  // log::debug!("Setting tournament csv schedule: {}", request);

  match TmsSchedule::from(&request) {
    Ok(s) => {
      // reply with message
      log::info!("Parsed schedule, teams: {}, matches: {}, practice: {}, judging: {}", s.teams.len(), s.game_matches.len(), s.practice_game_matches.len(), s.judging_sessions.len());
      Ok(warp::http::StatusCode::OK)
    },
    Err(e) => {
      log::error!("Failed to parse schedule: {}", e);
      // reply with message
      Err(warp::reject::custom(BadRequestWithMessage { message: e }))
    }
  }
}