use database::SharedDatabase;

use crate::{clients::ClientMap, filters::register_filter::register_filter};


pub struct Network {
  db: SharedDatabase,
  clients: ClientMap,
}

impl Network {
  pub fn new(db: SharedDatabase, clients: ClientMap) -> Self {
    Self {
      db,
      clients,
    }
  }

  pub fn get_network_routes(&self) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
    let routes = register_filter(self.clients.clone(), self.db.clone());
    routes
  }
}