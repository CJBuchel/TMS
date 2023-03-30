use super::packets::*;
use super::handler;

use std::convert::Infallible;
use std::{sync::Arc, collections::HashMap};

use tokio::sync::RwLock;
use tokio::{self, sync::{mpsc, Mutex}};
use warp::{ws::Message, Rejection, Filter};

fn with_clients(clients: Clients) -> impl Filter<Extract = (Clients,), Error = Infallible> + Clone {
  warp::any().map(move || clients.clone())
}

// Websocket server
pub async fn start() {
  println!("Starting Network");
  let clients: Clients = Arc::new(RwLock::new(HashMap::new()));

  let health_route = warp::path!("health").and_then(handler::health_handler);

  let register = warp::path("register");
  let register_routes = register
    .and(warp::post())
    .and(warp::body::json())
    .and(with_clients(clients.clone()))
    .and_then(handler::register_handler)
    .or(register
      .and(warp::delete())
      .and(warp::path::param())
      .and(with_clients(clients.clone()))
      .and_then(handler::unregister_handler));

  let publish = warp::path!("publish")
    .and(warp::body::json())
    .and(with_clients(clients.clone()))
    .and_then(handler::publish_handler);

  let ws_route = warp::path("ws")
    .and(warp::ws())
    .and(warp::path::param())
    .and(with_clients(clients.clone()))
    .and_then(handler::ws_handler);

  let routes = health_route
    .or(register_routes)
    .or(ws_route)
    .or(publish)
    .with(warp::cors().allow_any_origin());

  warp::serve(routes).run(([0, 0, 0, 0], 2122))
  .await;
}