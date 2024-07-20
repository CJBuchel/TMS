use tms_infra::RobotGamesLoadMatchRequest;

use crate::services::{ControlsSubService, SharedServices};


pub async fn robot_game_matches_load_matches_handler(request: RobotGamesLoadMatchRequest, services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let read_services = services.read().await;
  match read_services.match_service.load_matches(request.game_match_numbers).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => {
      Err(warp::reject::custom(crate::network::BadRequestWithMessage {
        message: e,
      }))
    }
  }
}

pub async fn robot_game_matches_unload_matches_handler(services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let read_services = services.read().await;
  match read_services.match_service.unload_matches().await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => {
      Err(warp::reject::custom(crate::network::BadRequestWithMessage {
        message: e,
      }))
    }
  }
}

pub async fn robot_game_matches_ready_matches_handler(services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let read_services = services.read().await;
  match read_services.match_service.ready_matches().await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => {
      Err(warp::reject::custom(crate::network::BadRequestWithMessage {
        message: e,
      }))
    }
  }
}

pub async fn robot_game_matches_unready_matches_handler(services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let read_services = services.read().await;
  match read_services.match_service.unready_matches().await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => {
      Err(warp::reject::custom(crate::network::BadRequestWithMessage {
        message: e,
      }))
    }
  }
}