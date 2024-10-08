use crate::{database::SharedDatabase, network::*};

use filters::header_filters::{auth_token_filter::check_auth_token_filter, role_permission_filter::role_permission_filter};
use tms_infra::{JUDGE_ADVISOR_ROLE, REFEREE_ROLE};
use warp::Filter;

pub fn robot_game_scoring_filter(clients: ClientMap, db: SharedDatabase) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  let robot_game_scoring_filter = warp::path("robot_game").and(warp::path("scoring"));

  let submit_game_score_sheet = robot_game_scoring_filter
    .and(warp::path("submit_score_sheet"))
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec![REFEREE_ROLE]))
    .and_then(robot_game_score_sheet_submit_handler);

  let update_game_score_sheet = robot_game_scoring_filter
    .and(warp::path("insert_score_sheet"))
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec![JUDGE_ADVISOR_ROLE]))
    .and_then(robot_game_score_sheet_insert_handler);

  let delete_game_score_sheet = robot_game_scoring_filter
    .and(warp::path("remove_score_sheet"))
    .and(warp::delete())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec![JUDGE_ADVISOR_ROLE]))
    .and_then(robot_game_score_sheet_remove_handler);

  submit_game_score_sheet.or(update_game_score_sheet).or(delete_game_score_sheet)
}