use crate::{database::SharedDatabase, network::*};

use filters::header_filters::{auth_token_filter::check_auth_token_filter, role_permission_filter::role_permission_filter};
use warp::Filter;

pub fn robot_game_scoring_filter(clients: ClientMap, db: SharedDatabase) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  let robot_game_scoring_filter = warp::path("robot_game").and(warp::path("scoring"));

  let game_score_sheet = robot_game_scoring_filter
    .and(warp::path("submit_score_sheet"))
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["head_referee", "referee"]))
    .and_then(robot_game_scoring_submit_score_sheet);

  game_score_sheet
}