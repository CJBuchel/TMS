use crate::{database::SharedDatabase, network::*};

use filters::header_filters::{auth_token_filter::check_auth_token_filter, role_permission_filter::role_permission_filter};
use warp::Filter;

pub fn robot_game_tables_filter(clients: ClientMap, db: SharedDatabase) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  let robot_game_tables_filter = warp::path("robot_game").and(warp::path("tables"));

  let not_ready_signal = robot_game_tables_filter
    .and(warp::path("not_ready_signal"))
    .and(warp::post())
    .and(warp::body::json())
    .and(with_clients(clients.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["head_referee", "referee"]))
    .and_then(robot_game_tables_not_ready_signal_handler);

  let ready_signal = robot_game_tables_filter
    .and(warp::path("ready_signal"))
    .and(warp::post())
    .and(warp::body::json())
    .and(with_clients(clients.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["head_referee", "referee"]))
    .and_then(robot_game_tables_ready_signal_handler);

  not_ready_signal.or(ready_signal)
}