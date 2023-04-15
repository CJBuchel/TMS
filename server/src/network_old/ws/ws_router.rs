use std::{sync::{Arc, RwLock}, collections::HashMap, convert::Infallible};
use tokio::sync::mpsc;
use warp::{ws::Message, Rejection, Filter, hyper::Method};

pub type Result<T> = std::result::Result<T, Rejection>;
pub type Clients = Arc<RwLock<HashMap<String, Client>>>;

use crate::db::db::{TmsDB};

use super::{mdns_broadcaster::start_broadcast, security::Security};
use super::handler;

#[derive(Debug, Clone)]
pub struct Client {
  pub user_id: String,
  pub key: String,
  pub sender: Option<mpsc::UnboundedSender<std::result::Result<Message, warp::Error>>>
}

fn with_clients(clients: Clients) -> impl Filter<Extract = (Clients,), Error = Infallible> + Clone {
  warp::any().map(move || clients.clone())
}

fn with_bytes(bytes: Vec<u8>) -> impl Filter<Extract = (Vec<u8>,), Error = Infallible> + Clone {
  warp::any().map(move || bytes.clone())
}

fn with_security(security: Security) -> impl Filter<Extract = (Security,), Error = Infallible> + Clone {
  warp::any().map(move || security.clone())
}

fn with_database(database: TmsDB) -> impl Filter<Extract = (TmsDB,), Error = Infallible> + Clone {
  warp::any().map(move || database.to_owned())
}

pub struct Router {
  security: Security,
  database: TmsDB
}

impl Router {
  pub fn new(db: TmsDB) -> Self {
    Self { 
      security: Security::new(),
      database: db
    }
  }

  pub async fn start(&self) {
    let cors = warp::cors().allow_any_origin()
        .allow_headers(vec!["Access-Control-Allow-Headers", "Access-Control-Request-Method", "Access-Control-Request-Headers", "Origin", "Accept", "X-Requested-With", "Content-Type"])
        .allow_methods(&[Method::GET, Method::POST, Method::PUT, Method::PATCH, Method::DELETE, Method::OPTIONS, Method::HEAD]);

    let clients: Clients = Arc::new(RwLock::new(HashMap::new()));
    let pulse_route = warp::path!("pulse").and_then(handler::pulse_handler);

    let register = warp::path("register");
    let register_routes = register
      .and(warp::post())
      .and(warp::body::json())
      .and(with_clients(clients.clone()))
      .and(with_bytes(self.security.public_key.clone()))
      .and_then(handler::register_handler)
      .or(register
        .and(warp::delete())
        .and(warp::path::param())
        .and(with_clients(clients.clone()))
        .and_then(handler::unregister_handler)
      );

    let publish = warp::path!("publish")
      .and(warp::body::bytes())
      .and(with_clients(clients.clone()))
      .and(with_security(self.security.clone()))
      .and_then(handler::publish_handler);

    let ws_route = warp::path("ws")
        .and(warp::ws())
        .and(warp::path::param())
        .and(with_clients(clients.clone()))
        .and(with_security(self.security.clone()))
        .and(with_database(self.database.to_owned()))
        .and_then(handler::ws_handler);

    let routes =
        pulse_route
        .or(register_routes)
        .or(ws_route)
        .or(publish)
        .with(cors);
  
    // Start mDNS server
    start_broadcast("_mdns-tms-server".to_string());
    warp::serve(routes).run(([0, 0, 0, 0], 2121)).await;
  }
}