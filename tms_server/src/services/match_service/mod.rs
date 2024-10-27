use crate::{database::SharedDatabase, network::ClientMap};

mod game_match_sub_service;
pub use game_match_sub_service::*;

mod controls_sub_service;
pub use controls_sub_service::*;

mod timer_sub_service;
pub use timer_sub_service::*;

pub struct MatchService {
  db: SharedDatabase,
  clients: ClientMap,

  // match fields
  loaded_game_matches: std::sync::Arc<tokio::sync::RwLock<Vec<String>>>,
  
  // match status
  is_timer_running: std::sync::Arc<std::sync::atomic::AtomicBool>,
  is_matches_loaded: std::sync::Arc<std::sync::atomic::AtomicBool>,
  is_matches_ready: std::sync::Arc<std::sync::atomic::AtomicBool>,
}

impl MatchService {
  pub fn new(db: SharedDatabase, clients: ClientMap) -> Self {
    Self { 
      db, 
      clients,
      loaded_game_matches: std::sync::Arc::new(tokio::sync::RwLock::new(Vec::new())),
      is_timer_running: std::sync::Arc::new(std::sync::atomic::AtomicBool::new(false)),
      is_matches_loaded: std::sync::Arc::new(std::sync::atomic::AtomicBool::new(false)),
      is_matches_ready: std::sync::Arc::new(std::sync::atomic::AtomicBool::new(false)),
    }
  }
}

