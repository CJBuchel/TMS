use crate::{database::SharedDatabase, network::*};
use filters::header_filters::{auth_token_filter::check_auth_token_filter, role_permission_filter::role_permission_filter};
use warp::Filter;

pub fn judging_pods_filter(clients: ClientMap, db: SharedDatabase) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  let judging_pods_path = warp::path("judging_pods");

  let insert_pod_path = judging_pods_path
    .and(warp::path("insert_pod"))
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["judge_advisor"]))
    .and_then(judging_pod_insert_handler);

  let remove_pod_path = judging_pods_path
    .and(warp::path("remove_pod"))
    .and(warp::delete())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["judge_advisor"]))
    .and_then(judging_pod_remove_handler);

  insert_pod_path.or(remove_pod_path)
}
