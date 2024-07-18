use tms_infra::RobotGamesLoadMatchRequest;

use crate::services::{ControlsSubService, SharedServices};


pub async fn robot_game_matches_load_matches_handler(request: RobotGamesLoadMatchRequest, services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let read_services = services.read().await;
  read_services.match_service.load_matches(request.game_match_numbers).await;
  Ok(warp::http::StatusCode::OK)
}

pub async fn robot_game_matches_unload_matches_handler(services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let read_services = services.read().await;
  read_services.match_service.unload_matches().await;
  Ok(warp::http::StatusCode::OK)
}

pub async fn robot_game_matches_ready_matches_handler(services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let read_services = services.read().await;
  read_services.match_service.ready_matches().await;
  Ok(warp::http::StatusCode::OK)
}

pub async fn robot_game_matches_unready_matches_handler(services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let read_services = services.read().await;
  read_services.match_service.unready_matches().await;
  Ok(warp::http::StatusCode::OK)
}