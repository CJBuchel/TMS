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