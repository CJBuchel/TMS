use crate::{database::SharedDatabase, network::ClientMap};

mod timer_sub_service;
pub use timer_sub_service::*;

pub struct MatchService {
  db: SharedDatabase,
  clients: ClientMap,
}

impl MatchService {
  pub fn new(db: SharedDatabase, clients: ClientMap) -> Self {
    Self { db, clients }
  }
}

