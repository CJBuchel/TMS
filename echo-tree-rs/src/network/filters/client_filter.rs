use warp::Filter;

use crate::common::{with_clients, with_db, ClientMap, EchoDB};
use crate::network::handlers::pulse_handler;
use crate::network::handlers::register_handlers::{register_handler, unregister_handler};
use crate::network::handlers::role_auth_handler::role_auth_handler;
use crate::network::handlers::ws_handlers::ws_handler;

use super::auth_token_filter::check_auth;
use super::HEADER_X_CLIENT_ID;

// client routes
// 
pub fn client_filter(clients: ClientMap, database: EchoDB, local_ip: String, tls: bool, port: u16) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  let pulse_route = warp::path("echo_tree").and(warp::path("pulse")).and_then(pulse_handler);

  let register = warp::path("echo_tree").and(warp::path("register"));
  
  let register_routes = register
    .and(warp::post())
    .and(warp::body::json())
    .and(with_clients(clients.clone()))
    .and(with_db(database.clone()))
    .and(warp::any().map(move || local_ip.clone()))
    .and(warp::any().map(move || tls))
    .and(warp::any().map(move || port))
    .and(warp::filters::addr::remote())
    .and_then(register_handler);

  let unregister_routes = register
    .and(warp::delete())
    .and(warp::header::<String>(HEADER_X_CLIENT_ID))
    .and(with_clients(clients.clone()))
    .and(check_auth(clients.clone()))
    .and_then(unregister_handler);

  let role_auth_route = warp::path("echo_tree").and(warp::path("role_auth"))
    .and(warp::post())
    .and(warp::header::<String>(HEADER_X_CLIENT_ID))
    .and(warp::body::json())
    .and(with_clients(clients.clone()))
    .and(with_db(database.clone()))
    .and(check_auth(clients.clone()))
    .and_then(role_auth_handler);

  let ws_route = warp::path("echo_tree").and(warp::path("ws"))
    .and(warp::ws())
    .and(warp::path::param())
    .and(with_clients(clients.clone()))
    .and(with_db(database.clone()))
    .and_then(ws_handler);

  let cors = warp::cors()
    .allow_any_origin()
    .allow_headers(vec!["content-type"])
    .allow_methods(vec!["GET", "POST", "DELETE", "OPTIONS"]);

  let routes = pulse_route
    .or(register_routes)
    .or(unregister_routes)
    .or(role_auth_route)
    .or(ws_route)
    .with(cors);

  routes
}