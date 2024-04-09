use warp::Filter;

use crate::{database::SharedDatabase, network::{handlers::login_handler, with_clients, with_db, ClientMap}};

use super::header_filters::{auth_token_filter::check_auth_token_filter, uuid_param_filter::with_uuid_param_filter};


pub fn login_filter(clients: ClientMap, db: SharedDatabase) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  warp::path("login")
    .and(warp::post())
    .and(warp::body::json())
    .and(with_uuid_param_filter(clients.clone()))
    .and(with_clients(clients.clone()))
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and_then(login_handler)
}