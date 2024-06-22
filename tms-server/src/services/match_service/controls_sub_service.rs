use crate::{network::ClientMap, network::client_publish::*};

use super::{AtomicRefBool, MatchService};


#[async_trait::async_trait]
pub trait ControlsSubService {
  async fn load_matches_loop_sender(
    is_matches_loaded: AtomicRefBool,
    loaded_matches: Vec<String>,
    clients: ClientMap,
  );
  async fn load_matches(&self, game_match_numbers: Vec<String>);
  async fn unload_matches(&self);
}


#[async_trait::async_trait]
impl ControlsSubService for MatchService {

  async fn load_matches_loop_sender(
    is_matches_loaded: AtomicRefBool,
    loaded_matches: Vec<String>,
    clients: ClientMap,
  ) {
    // tokio loop selector
    while is_matches_loaded.load(std::sync::atomic::Ordering::Relaxed) {
      let read_clients = clients.read().await;
      read_clients.publish_load_matches(loaded_matches.clone());
      // delay
      tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
    }
  }

  async fn load_matches(&self, game_match_numbers: Vec<String>) {
    if !self.is_matches_loaded.load(std::sync::atomic::Ordering::Relaxed) {
      log::info!("Loading Matches: {:?}", game_match_numbers);
      self.is_matches_loaded.store(true, std::sync::atomic::Ordering::Relaxed);
      self.loaded_matches.write().await.clear();
      self.loaded_matches.write().await.extend(game_match_numbers.clone());

      // setup clones
      let is_matches_loaded = self.is_matches_loaded.clone();
      let game_matches = game_match_numbers.clone();
      let clients = self.clients.clone();

      tokio::spawn(async move {
        MatchService::load_matches_loop_sender(is_matches_loaded,  game_matches, clients).await;
      });
    } else {
      log::warn!("Matches already loaded");
    }
  }

  async fn unload_matches(&self) {
    if self.is_matches_loaded.load(std::sync::atomic::Ordering::Relaxed) {
      log::info!("Unloading Matches");
      self.is_matches_loaded.store(false, std::sync::atomic::Ordering::Relaxed);
      self.loaded_matches.write().await.clear();

      let read_clients = self.clients.read().await;
      read_clients.publish_unload_matches();
    } else {
      log::warn!("Matches already unloaded");
    }
  }
}