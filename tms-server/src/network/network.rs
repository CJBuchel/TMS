use warp::Filter;

use crate::{database::SharedDatabase, services::SharedServices};

use super::{handle_rejection, ClientMap};
use crate::network::filters::*;

pub struct Network {
  db: SharedDatabase,
  clients: ClientMap,
  services: SharedServices,
  local_ip: String,
  tls: bool,
  port: u16,
}

impl Network {
  pub fn new(db: SharedDatabase, clients: ClientMap, services: SharedServices, local_ip: String, tls: bool, port: u16) -> Self {
    Self { db, clients, services, local_ip, tls, port }
  }

  pub fn get_network_routes(&self) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
    let cors = warp::cors()
      .allow_any_origin()
      .allow_headers(vec!["Content-Type", "X-Client-Id", "X-Auth-Token"])
      .allow_methods(vec!["GET", "POST", "DELETE", "OPTIONS"]);

    let routes = pulse_filter()
      // main filters
      .or(tournament_schedule_filter(self.clients.clone(), self.db.clone()))
      .or(tournament_config_filter(self.clients.clone(), self.db.clone()))
      .or(tournament_blueprint_filter(self.clients.clone(), self.db.clone()))
      .or(login_filter(self.clients.clone(), self.db.clone()))
      .or(robot_game_matches_filter(self.clients.clone(), self.db.clone(), self.services.clone()))
      .or(robot_game_timer_filter(self.clients.clone(), self.db.clone(), self.services.clone()))
      .or(robot_game_tables_filter(self.clients.clone(), self.db.clone()))
      .or(robot_game_scoring_filter(self.clients.clone(), self.db.clone()))
      .or(teams_filter(self.clients.clone(), self.db.clone()))
      // core filters
      .or(registration_filter(self.clients.clone(), self.db.clone(), self.local_ip.clone(), self.tls, self.port))
      .or(websocket_filter(self.clients.clone(), self.db.clone()))
      .recover(handle_rejection)
      .with(cors);
    routes
  }
}
