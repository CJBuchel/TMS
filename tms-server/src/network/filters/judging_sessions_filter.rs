use crate::{database::SharedDatabase, network::*};
use filters::header_filters::{auth_token_filter::check_auth_token_filter, role_permission_filter::role_permission_filter};
use warp::Filter;

pub fn judging_sessions_filter(clients: ClientMap, db: SharedDatabase) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  let judging_sessions_path = warp::path("judging_sessions");

  let insert_session_path = judging_sessions_path
    .and(warp::path("insert_session"))
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["judge_advisor"]))
    .and_then(judging_session_insert_handler);

  let remove_session_path = judging_sessions_path
    .and(warp::path("remove_session"))
    .and(warp::delete())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["judge_advisor"]))
    .and_then(judging_session_remove_handler);

  insert_session_path.or(remove_session_path)
}
