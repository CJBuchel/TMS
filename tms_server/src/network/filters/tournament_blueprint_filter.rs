use warp::Filter;

use crate::network::handlers::*;
use crate::network::*;
use crate::{database::*, network::ClientMap};

use super::header_filters::{auth_token_filter::check_auth_token_filter, role_permission_filter::role_permission_filter};

pub fn tournament_blueprint_filter(clients: ClientMap, db: SharedDatabase) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  let tournament_blueprint_path = warp::path("tournament").and(warp::path("blueprint"));

  let add_blueprint = tournament_blueprint_path
    .and(warp::path("add"))
    .and(warp::post())
    .and(warp::body::bytes())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec![]))
    .and_then(|bytes: warp::hyper::body::Bytes, db| {
      let body = String::from_utf8(bytes.to_vec()).unwrap();
      tournament_blueprint_add_blueprint_handler(body, db)
    });

  add_blueprint
}
