use crate::{network::client_publish::*, network::ClientMap};

use super::{AtomicRefBool, MatchService};

#[async_trait::async_trait]
pub trait ControlsSubService {
  async fn load_matches_loop_sender(is_matches_loaded: AtomicRefBool, is_ready: AtomicRefBool, is_running: AtomicRefBool, loaded_matches: Vec<String>, clients: ClientMap);
  // load
  async fn load_matches(&self, game_match_numbers: Vec<String>) -> Result<(), String>;
  async fn unload_matches(&self) -> Result<(), String>;

  // ready
  async fn ready_matches(&self) -> Result<(), String>;
  async fn unready_matches(&self) -> Result<(), String>;
}

#[async_trait::async_trait]
impl ControlsSubService for MatchService {
  async fn load_matches_loop_sender(is_matches_loaded: AtomicRefBool, is_ready: AtomicRefBool, is_running: AtomicRefBool, loaded_matches: Vec<String>, clients: ClientMap) {
    // tokio loop selector
    while is_matches_loaded.load(std::sync::atomic::Ordering::Relaxed) {

      // if ready
      if is_running.load(std::sync::atomic::Ordering::Relaxed) {
        clients.read().await.publish_running_matches(loaded_matches.clone());
      } else if is_ready.load(std::sync::atomic::Ordering::Relaxed) {
        clients.read().await.publish_ready_matches(loaded_matches.clone());
      } else {
        clients.read().await.publish_load_matches(loaded_matches.clone());
      }
      // delay
      tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
    }
  }

  async fn load_matches(&self, game_match_numbers: Vec<String>) -> Result<(), String> {
    let is_loaded = self.is_matches_loaded.load(std::sync::atomic::Ordering::Relaxed);
    let is_ready = self.is_matches_ready.load(std::sync::atomic::Ordering::Relaxed);

    if !is_loaded && !is_ready {
      log::info!("Loading Matches: {:?}", game_match_numbers);
      self.is_matches_loaded.store(true, std::sync::atomic::Ordering::Relaxed);
      self.loaded_matches.write().await.clear();
      self.loaded_matches.write().await.extend(game_match_numbers.clone());

      // setup clones
      let is_matches_loaded = self.is_matches_loaded.clone();
      let is_matches_ready = self.is_matches_ready.clone();
      let is_matches_running = self.is_timer_running.clone();
      let game_matches = game_match_numbers.clone();
      let clients = self.clients.clone();

      tokio::spawn(async move {
        MatchService::load_matches_loop_sender(is_matches_loaded, is_matches_ready, is_matches_running, game_matches, clients).await;
      });

      Ok(())
    } else {
      log::warn!("Matches can't be loaded");
      Err("Matches can't be loaded".to_string())
    }
  }

  async fn unload_matches(&self) -> Result<(), String> {
    let is_loaded = self.is_matches_loaded.load(std::sync::atomic::Ordering::Relaxed);
    let is_ready = self.is_matches_ready.load(std::sync::atomic::Ordering::Relaxed);


    if is_loaded && !is_ready {
      log::info!("Unloading Matches");
      self.is_matches_loaded.store(false, std::sync::atomic::Ordering::Relaxed);
      self.loaded_matches.write().await.clear();

      self.clients.read().await.publish_unload_matches();
      Ok(())
    } else {
      log::warn!("Matches can't be unloaded");
      Err("Matches can't be unloaded".to_string())
    }
  }

  async fn ready_matches(&self) -> Result<(), String> {
    // if matches are loaded and not ready
    let is_loaded = self.is_matches_loaded.load(std::sync::atomic::Ordering::Relaxed);
    let is_ready = self.is_matches_ready.load(std::sync::atomic::Ordering::Relaxed);

    if is_loaded && !is_ready {
      log::info!("Ready Matches");
      self.is_matches_ready.store(true, std::sync::atomic::Ordering::Relaxed);
      // send ready matches to clients as well (for instant update)
      self.clients.read().await.publish_ready_matches(self.loaded_matches.read().await.clone());
      Ok(())
    } else {
      log::warn!("Can't ready matches");
      Err("Can't ready matches".to_string())
    }
  }

  async fn unready_matches(&self) -> Result<(), String> {
    // if matches are loaded and ready
    let is_loaded = self.is_matches_loaded.load(std::sync::atomic::Ordering::Relaxed);
    let is_ready = self.is_matches_ready.load(std::sync::atomic::Ordering::Relaxed);

    if is_loaded && is_ready {
      log::info!("Unready Matches");
      self.is_matches_ready.store(false, std::sync::atomic::Ordering::Relaxed);
      // send unready matches to clients as well (for instant update)
      // unready is just the loaded state yet to be ready again.
      self.clients.read().await.publish_load_matches(self.loaded_matches.read().await.clone());
      Ok(())
    } else {
      log::warn!("Can't unready matches");
      Err("Can't unready matches".to_string())
    }
  }
}
