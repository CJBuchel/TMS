use crate::{database::SharedDatabase, network::ClientMap};

mod match_service;
pub use match_service::*;

pub struct Services {
  pub match_service: match_service::MatchService,
}

impl Services {
  pub fn new(db: SharedDatabase, clients: ClientMap) -> Self {
    Services {
      match_service: match_service::MatchService::new(db, clients),
    }
  }
}

pub type SharedServices = std::sync::Arc<tokio::sync::RwLock<Services>>;

pub trait SharedServicesTrait {
  fn new_instance(db: SharedDatabase, clients: ClientMap) -> SharedServices;
}

impl SharedServicesTrait for SharedServices {
  fn new_instance(db: SharedDatabase, clients: ClientMap) -> SharedServices {
    std::sync::Arc::new(tokio::sync::RwLock::new(Services::new(db, clients)))
  }
}
