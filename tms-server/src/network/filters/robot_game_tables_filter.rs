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
    .and_then(robot_game_table_not_ready_signal_handler);

  let ready_signal = robot_game_tables_filter
    .and(warp::path("ready_signal"))
    .and(warp::post())
    .and(warp::body::json())
    .and(with_clients(clients.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["head_referee", "referee"]))
    .and_then(robot_game_table_ready_signal_handler);

  let insert_table = robot_game_tables_filter
    .and(warp::path("insert_table"))
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["head_referee"]))
    .and_then(robot_game_table_insert_handler);

  let remove_table = robot_game_tables_filter
    .and(warp::path("remove_table"))
    .and(warp::delete())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["head_referee"]))
    .and_then(robot_game_table_remove_handler);

  not_ready_signal.or(ready_signal).or(insert_table).or(remove_table)
}