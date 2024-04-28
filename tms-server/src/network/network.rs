use warp::Filter;

use crate::database::SharedDatabase;

use super::{filters::{pulse_filter::pulse_filter, register_filter::registration_filter, websocket_filter::websocket_filter}, handlers::handle_rejection, login_filter::login_filter, tournament_config_filter::tournament_config_filter, ClientMap};
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
    .allow_headers(vec!["Content-Type", "X-Client-Id", "X-Auth-Token"])
    .allow_methods(vec!["GET", "POST", "DELETE", "OPTIONS"]);

    let routes = pulse_filter()
      .or(tournament_config_filter(self.clients.clone(), self.db.clone()))
      .or(login_filter(self.clients.clone(), self.db.clone()))
      .or(registration_filter(self.clients.clone(), self.db.clone(), self.local_ip.clone(), self.tls, self.port))
      .or(websocket_filter(self.clients.clone(), self.db.clone()))
      .recover(handle_rejection)
      .with(cors);
    routes
  }
}