use tms_utils::TmsClients;

use crate::db::db::TmsDB;

pub mod match_control;
pub mod scoring;
pub mod teams;

pub struct TmsEventService {
  pub match_control: match_control::MatchControl,
  pub scoring: scoring::Scoring,
  pub teams: teams::Teams,
}

impl TmsEventService {
  pub fn new(tms_db: std::sync::Arc<TmsDB>, tms_clients: TmsClients) -> Self {
    Self {
      match_control: match_control::MatchControl::new(tms_db.clone(), tms_clients),
      scoring: scoring::Scoring::new(tms_db.clone()),
      teams: teams::Teams::new(tms_db.clone()),
    }
  }
}


// read write lock, when in read lock it still allows other reads but not writes
pub type TmsEventServiceArc = std::sync::Arc<tokio::sync::RwLock<TmsEventService>>;

pub async fn with_tms_event_service_write<F, R>(tms_event_service: &TmsEventServiceArc, f: F) -> Result<R, &'static str>
where
  F: FnOnce(&mut TmsEventService) -> R,
{ 
  let mut guard = tms_event_service.write().await;
  Ok(f(&mut *guard))
}

pub async fn with_tms_event_service_read<F, R>(tms_event_service: &TmsEventServiceArc, f: F) -> Result<R, &'static str>
where
  F: FnOnce(&TmsEventService) -> R,
{
  let guard = tms_event_service.read().await;
  Ok(f(&*guard))
}