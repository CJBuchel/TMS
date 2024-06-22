use tms_infra::RobotGamesLoadMatchRequest;

use crate::{database::SharedDatabase, services::{ControlsSubService, SharedServices}};


pub async fn robot_game_matches_load_matches_handler(request: RobotGamesLoadMatchRequest, _db: SharedDatabase, services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let read_services = services.read().await;

  read_services.match_service.load_matches(request.game_match_numbers).await;

  Ok(warp::http::StatusCode::OK)
}