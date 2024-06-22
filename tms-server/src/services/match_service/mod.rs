use crate::{database::SharedDatabase, network::ClientMap};

mod controls_sub_service;
pub use controls_sub_service::*;

mod timer_sub_service;
pub use timer_sub_service::*;

pub struct MatchService {
  db: SharedDatabase,
  clients: ClientMap,

  loaded_matches: AtomicRefStrVec,
  is_timer_running: AtomicRefBool,
  is_matches_loaded: AtomicRefBool,
}

impl MatchService {
  pub fn new(db: SharedDatabase, clients: ClientMap) -> Self {
    Self { 
      db, 
      clients,
      loaded_matches: std::sync::Arc::new(tokio::sync::RwLock::new(Vec::new())),
      is_timer_running: std::sync::Arc::new(std::sync::atomic::AtomicBool::new(false)),
      is_matches_loaded: std::sync::Arc::new(std::sync::atomic::AtomicBool::new(false)),
    }
  }
}

