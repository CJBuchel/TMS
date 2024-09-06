use crate::{
  network::BadRequestWithMessage,
  services::{SharedServices, TimerSubService},
};

pub async fn robot_game_timer_start_handler(services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let mut write_services = services.write().await;
  match write_services.match_service.start_timer().await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(BadRequestWithMessage { message: e })),
  }
}

pub async fn robot_game_timer_stop_handler(services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let read_services = services.read().await;
  match read_services.match_service.stop_timer().await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(BadRequestWithMessage { message: e })),
  }
}

pub async fn robot_game_timer_start_countdown_handler(services: SharedServices) -> Result<impl warp::Reply, warp::Rejection> {
  let mut write_services = services.write().await;
  match write_services.match_service.start_countdown_timer().await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(BadRequestWithMessage { message: e })),
  }
}
