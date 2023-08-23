use tms_utils::TmsClients;

use crate::db::db::TmsDB;

pub mod match_control;

// #[derive(Clone)]
pub struct TmsEventService {
  pub match_control: match_control::MatchControl,
}

impl TmsEventService {
  pub fn new(tms_db: std::sync::Arc<TmsDB>, tms_clients: TmsClients) -> Self {
    Self {
      match_control: match_control::MatchControl::new(tms_db, tms_clients)
    }
  }
}