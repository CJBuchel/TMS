use database::SharedDatabase;
use warp::Filter;
use crate::{clients::ClientMap, filters::{register_filter::registration_filter, websocket_filter::websocket_filter}, handlers::handle_rejection};

pub struct Network {
  db: SharedDatabase,
  clients: ClientMap,
  local_ip: String,
  tls: bool,
  port: u16,
}

impl Network {
  pub fn new(db: SharedDatabase, clients: ClientMap, local_ip: String, tls: bool, port: u16) -> Self {
    Self { db, clients, local_ip, tls, port }
  }

  pub fn get_network_routes(&self) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
    let cors = warp::cors()
    .allow_any_origin()
    .allow_headers(vec!["content-type"])
    .allow_methods(vec!["GET", "POST", "DELETE", "OPTIONS"]);

    let routes = registration_filter(self.clients.clone(), self.db.clone(), self.local_ip.clone(), self.tls, self.port)
      .or(websocket_filter(self.clients.clone(), self.db.clone()))
      .recover(handle_rejection)
      .with(cors);
    routes
  }
}