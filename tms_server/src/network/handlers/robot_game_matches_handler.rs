use tms_infra::*;

use crate::{database::*, services::*};

pub async fn robot_game_match_load_handler(request: RobotGameMatchLoadRequest, services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let read_services = services.read().await;
  match read_services.match_service.load_matches(request.game_match_numbers).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}

pub async fn robot_game_match_unload_handler(services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let read_services = services.read().await;
  match read_services.match_service.unload_matches().await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}

pub async fn robot_game_match_ready_handler(services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let read_services = services.read().await;
  match read_services.match_service.ready_matches().await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}

pub async fn robot_game_match_unready_handler(services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let read_services = services.read().await;
  match read_services.match_service.unready_matches().await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}

pub async fn robot_game_match_insert_handler(request: RobotGameMatchInsertRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;

  match read_db.insert_game_match(request.game_match, request.match_id).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}

pub async fn robot_game_match_remove_handler(request: RobotGameMatchRemoveRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;

  match read_db.remove_game_match(request.match_id).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}

pub async fn robot_game_toggle_team_check_in_handler(request: RobotGameToggleTeamCheckInRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;

  // get relevant match
  let mut m = match read_db.get_game_match_by_number(request.match_number.clone()).await {
    Some((id, m)) => (id, m),
    None => {
      return Err(warp::reject::custom(crate::network::BadRequestWithMessage {
        message: format!("No match found with number {}", request.match_number),
      }));
    }
  };

  // get relevant team table
  let team_table = m.1.game_match_tables.iter_mut().find(|t| t.team_number == request.team_number);
  let team_table = match team_table {
    Some(t) => t,
    None => {
      return Err(warp::reject::custom(crate::network::BadRequestWithMessage {
        message: format!("Team {} not found in match {}", request.team_number, request.match_number),
      }));
    }
  };

  // Cycle toggle state = (not_checked_in -> checked_in -> not_playing -> not_checked_in)
  team_table.check_in_status = match team_table.check_in_status {
    TeamCheckInStatus::NotCheckedIn => TeamCheckInStatus::CheckedIn,
    TeamCheckInStatus::CheckedIn => TeamCheckInStatus::NotPlaying,
    TeamCheckInStatus::NotPlaying => TeamCheckInStatus::NotCheckedIn,
  };

  // update match in database
  match read_db.insert_game_match(m.1, Some(m.0)).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => {
      return Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e }));
    }
  }
}
