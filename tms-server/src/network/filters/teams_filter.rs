use crate::{database::SharedDatabase, network::*};
use filters::header_filters::{auth_token_filter::check_auth_token_filter, role_permission_filter::role_permission_filter};
use warp::Filter;

pub fn teams_filter(clients: ClientMap, db: SharedDatabase) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  let teams_path = warp::path("teams");

  let update_team = teams_path
    .and(warp::path("update_team"))
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["judge_advisor"]))
    .and_then(team_update_team_handler);

  update_team
}
