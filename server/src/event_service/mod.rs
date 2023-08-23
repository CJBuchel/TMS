use crate::db::db::TmsDB;

pub mod match_control;

// #[derive(Clone)]
pub struct TmsEventService {
  pub match_control: match_control::MatchControl,
}

impl TmsEventService {
  pub fn new(tms_db: std::sync::Arc<TmsDB>) -> Self {
    Self {
      match_control: match_control::MatchControl::new(tms_db)
    }
  }
}