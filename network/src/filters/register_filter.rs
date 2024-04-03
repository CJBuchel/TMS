use database::SharedDatabase;
use warp::Filter;

use crate::{clients::{with_clients, with_db, ClientMap}, handlers::{register_handler, unregister_handler}};

use super::auth_token_filter::check_auth_token;


pub fn registration_filter(clients: ClientMap, db: SharedDatabase, local_ip: String, tls: bool, port: u16) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  let register_path = warp::path("register");

  let register = register_path
    .and(warp::post())
    .and(warp::body::json())
    .and(with_clients(clients.clone()))
    .and(with_db(db.clone()))
    .and(warp::any().map(move || local_ip.clone()))
    .and(warp::any().map(move || tls))
    .and(warp::any().map(move || port))
    .and_then(register_handler);

  let unregister = register_path
    .and(warp::delete())
    .and(warp::path::param())
    .and(with_clients(clients.clone()))
    .and(check_auth_token(clients.clone()))
    .and_then(unregister_handler);

  register.or(unregister)
}