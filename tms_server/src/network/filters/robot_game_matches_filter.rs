use crate::{database::SharedDatabase, network::*, services::SharedServices};
use tms_infra::{HEAD_REFEREE_ROLE, QUEUER_ROLE};
use warp::Filter;

use super::{
  header_filters::{auth_token_filter::check_auth_token_filter, role_permission_filter::role_permission_filter},
  with_services,
};

pub fn robot_game_matches_filter(clients: ClientMap, db: SharedDatabase, services: SharedServices) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  let robot_game_matches_path = warp::path("robot_game").and(warp::path("matches"));

  let load_matches = robot_game_matches_path
    .and(warp::path("load_matches"))
    .and(warp::post())
    .and(warp::body::json())
    .and(with_services(services.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec![HEAD_REFEREE_ROLE]))
    .and_then(robot_game_match_load_handler);

  let unload_matches = robot_game_matches_path
    .and(warp::path("unload_matches"))
    .and(warp::post())
    .and(with_services(services.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec![HEAD_REFEREE_ROLE]))
    .and_then(robot_game_match_unload_handler);

  let ready_matches = robot_game_matches_path
    .and(warp::path("ready_matches"))
    .and(warp::post())
    .and(with_services(services.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec![HEAD_REFEREE_ROLE]))
    .and_then(robot_game_match_ready_handler);

  let unready_matches = robot_game_matches_path
    .and(warp::path("unready_matches"))
    .and(warp::post())
    .and(with_services(services.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec![HEAD_REFEREE_ROLE]))
    .and_then(robot_game_match_unready_handler);

  let update_match = robot_game_matches_path
    .and(warp::path("insert_match"))
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec![HEAD_REFEREE_ROLE]))
    .and_then(robot_game_match_insert_handler);

  let remove_match = robot_game_matches_path
    .and(warp::path("remove_match"))
    .and(warp::delete())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec![HEAD_REFEREE_ROLE]))
    .and_then(robot_game_match_remove_handler);

  let toggle_team_check_in = robot_game_matches_path
    .and(warp::path("toggle_team_check_in"))
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec![QUEUER_ROLE]))
    .and_then(robot_game_toggle_team_check_in_handler);

  load_matches.or(unload_matches).or(ready_matches).or(unready_matches).or(update_match).or(remove_match).or(toggle_team_check_in)
}
