pub mod ws_routes;

use std::convert::Infallible;

use log::info;
use tms_utils::{security::Security, TmsClients};
use warp::{hyper::Method, Filter};

use self::ws_routes::ws_handler;

fn with_clients(clients: TmsClients) -> impl Filter<Extract = (TmsClients,), Error = Infallible> + Clone {
  warp::any().map(move || clients.clone())
}

fn with_security(security: Security) -> impl Filter<Extract = (Security,), Error = Infallible> + Clone {
  warp::any().map(move || security.clone())
}


pub struct TmsWebsocket {
  security: Security,
  clients: TmsClients,
  port: u16,
}

impl TmsWebsocket {
  pub fn new(security: Security, clients: TmsClients, port: u16) -> Self {
    Self {
      security,
      clients,
      port
    }
  }

  pub async fn start(&self) {
    info!("Warp starting");
    let cors = warp::cors().allow_any_origin()
    .allow_headers(vec!["Access-Control-Allow-Headers", "Access-Control-Request-Method", "Access-Control-Request-Headers", "Origin", "Accept", "X-Requested-With", "Content-Type"])
    .allow_methods(&[Method::GET, Method::POST, Method::PUT, Method::PATCH, Method::DELETE, Method::OPTIONS, Method::HEAD]);
  
    // websocket route
    let ws_path = warp::path("ws");
    let ws_route = ws_path
    .and(warp::ws())
    .and(warp::path::param())
    .and(with_clients(self.clients.to_owned()))
    .and(with_security(self.security.clone()))
    .and_then(ws_handler);

    info!("Starting websocket server");
    let routes = ws_route.with(cors);
    warp::serve(routes).run(([0,0,0,0], self.port)).await;
  }
}