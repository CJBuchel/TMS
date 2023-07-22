use crate::db::db::TmsDB;

#[derive(Clone)]
pub struct MatchControl {
  tms_db: std::sync::Arc<TmsDB>,
}

impl MatchControl {
  pub fn new(tms_db: std::sync::Arc<TmsDB>) -> Self {
    Self {
      tms_db
    }
  }

  pub fn start_timer(&self) {
    println!("Starting Timer");
  }
}