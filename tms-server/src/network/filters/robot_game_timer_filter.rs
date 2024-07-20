use warp::Filter;
use crate::{database::SharedDatabase, network::{robot_game_timer_start_countdown_handler, robot_game_timer_start_handler, robot_game_timer_stop_handler, ClientMap}, services::SharedServices};

use super::{header_filters::{auth_token_filter::check_auth_token_filter, role_permission_filter::role_permission_filter}, with_services};


pub fn robot_game_timer_filter(clients: ClientMap, db: SharedDatabase, services: SharedServices) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  let robot_game_timer_path = warp::path("robot_game").and(warp::path("timer"));

  let start_timer = robot_game_timer_path.and(warp::path("start"))
    .and(warp::post())
    .and(with_services(services.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["admin", "head_referee"]))
    .and_then(robot_game_timer_start_handler);

  let stop_timer = robot_game_timer_path.and(warp::path("stop"))
    .and(warp::post())
    .and(with_services(services.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["admin", "head_referee"]))
    .and_then(robot_game_timer_stop_handler);

  let start_countdown_timer = robot_game_timer_path.and(warp::path("start_countdown"))
    .and(warp::post())
    .and(with_services(services.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["admin", "head_referee"]))
    .and_then(robot_game_timer_start_countdown_handler);

  start_timer.or(stop_timer).or(start_countdown_timer)
}