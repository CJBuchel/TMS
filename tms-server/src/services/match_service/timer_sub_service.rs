use crate::{database::*, network::{client_publish::*, ClientMap}, types::{AtomicRefBool, AtomicRefStrVec}};

use super::MatchService;

#[async_trait::async_trait]
pub trait TimerSubService {
  // main timers
  async fn timer(
    time: u32, 
    endgame_time: u32, 
    loaded_matches: AtomicRefStrVec,
    timer_running: AtomicRefBool,
    clients: ClientMap,
    db: SharedDatabase,
  );
  async fn start_timer(&mut self);

  // countdown timer
  async fn countdown_timer(
    clients: ClientMap,
    timer_running: AtomicRefBool,
  );
  async fn start_countdown_timer(&mut self);

  async fn stop_timer(&self);
}

#[async_trait::async_trait]
impl TimerSubService for MatchService {
  async fn timer(
    time: u32, 
    endgame_time: u32, 
    loaded_matches: AtomicRefStrVec,
    timer_running: AtomicRefBool,
    clients: ClientMap,
    db: SharedDatabase,
  ) {
    log::info!("Timer Running");

    // send the start message
    clients.read().await.publish_start_timer();
    // send time message
    clients.read().await.publish_time_timer(time);

    // initial wait
    tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;

    // countdown from time to 0
    for i in (0..time).rev() {
      let start_epoch = tokio::time::Instant::now();
      // check if timer is still running
      if !timer_running.load(std::sync::atomic::Ordering::Relaxed) {
        return;
      }

      // send time message
      clients.read().await.publish_time_timer(i);

      // check if timer is endgame, send the endgame signal once
      if i == endgame_time {
        clients.read().await.publish_endgame_timer(endgame_time);
      }

      let elapsed_epoch = start_epoch.elapsed();
      if let Some(sleep_duration) = std::time::Duration::from_secs(1).checked_sub(elapsed_epoch) {
        tokio::time::sleep(sleep_duration).await;
      }
    }

    // countdown finished, send end message
    clients.read().await.publish_end_timer();

    // if timer still running, set database matches to complete
    if timer_running.load(std::sync::atomic::Ordering::Relaxed) {

      // get loaded matches and set the to complete
      let loaded_matches = loaded_matches.read().await;
      let write_db = db.write().await;
      for match_number in loaded_matches.iter() {
        let game_match = write_db.get_game_match_by_number(match_number.clone()).await;
        if let Some((game_match_id, _)) = game_match {
          match write_db.set_game_match_complete(game_match_id).await {
            Ok(_) => {}
            Err(e) => {
              log::error!("Error setting match complete: {}", e);
            }
          }
        }
      }

      // unload the matches
      clients.read().await.publish_unload_matches();
    }

    // finally set timer no longer running
    timer_running.store(false, std::sync::atomic::Ordering::Relaxed);

    // reload clocks (may need to wait for a bit)
    tokio::time::sleep(tokio::time::Duration::from_secs(2)).await;
    clients.read().await.publish_reload_timer();
  }

  async fn start_timer(&mut self) {
    if !self.is_timer_running.load(std::sync::atomic::Ordering::Relaxed) {
      log::info!("Starting Timer");
      self.is_timer_running.store(true, std::sync::atomic::Ordering::Relaxed);
      let read_db = self.db.read().await;
      let timer_length = match read_db.get_tournament_timer_length().await {
        Some(t) => t,
        None => {
          log::error!("No timer length set");
          150 // default to 150 seconds
        }
      };
      let endgame_timer_length = match read_db.get_tournament_endgame_timer_length().await {
        Some(t) => t,
        None => {
          log::error!("No endgame timer length set");
          30 // default to 30 seconds
        }
      };

      // clone for move
      let timer_flag = self.is_timer_running.clone();
      let loaded_matches = self.loaded_matches.clone();
      let clients = self.clients.clone();
      let db = self.db.clone();

      // spawn timer thread
      tokio::spawn(async move {
        MatchService::timer(
          timer_length,
          endgame_timer_length,
          loaded_matches,
          timer_flag,
          clients,
          db,
        ).await;
      });
    } else {
      log::warn!("Timer already running");
    }
  }

  async fn countdown_timer(
    clients: ClientMap,
    timer_running: AtomicRefBool,
  ) {
    let countdown_time: u32 = 5; // 5 second countdown
    
    // send the start message
    clients.read().await.publish_start_countdown();
    // send time message
    clients.read().await.publish_time_timer(countdown_time);

    // initial wait
    tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;

    // countdown from time to 0
    for i in (1..countdown_time).rev() {
      let start_epoch = tokio::time::Instant::now();
      // check if timer is still running
      if !timer_running.load(std::sync::atomic::Ordering::Relaxed) {
        return;
      }

      // send time message
      clients.read().await.publish_time_timer(i);

      let elapsed_epoch = start_epoch.elapsed();
      if let Some(sleep_duration) = std::time::Duration::from_secs(1).checked_sub(elapsed_epoch) {
        tokio::time::sleep(sleep_duration).await;
      }
    }
  }

  async fn start_countdown_timer(&mut self) {
    if !self.is_timer_running.load(std::sync::atomic::Ordering::Relaxed) {
      log::info!("Starting Countdown Timer");
      self.is_timer_running.store(true, std::sync::atomic::Ordering::Relaxed);

      // get main timer
      let read_db = self.db.read().await;
      let timer_length = match read_db.get_tournament_timer_length().await {
        Some(t) => t,
        None => {
          log::error!("No timer length set");
          150 // default to 150 seconds
        }
      };

      let endgame_timer = match read_db.get_tournament_endgame_timer_length().await {
        Some(t) => t,
        None => {
          log::error!("No endgame timer length set");
          30 // default to 30 seconds
        }
      };

      let clients = self.clients.clone();
      let timer_flag = self.is_timer_running.clone();
      let loaded_matches = self.loaded_matches.clone();
      let db = self.db.clone();

      // spawn timer thread
      tokio::spawn(async move {
        // countdown timer
        MatchService::countdown_timer(clients.clone(), timer_flag.clone()).await;
        // start main timer
        MatchService::timer(timer_length, endgame_timer, loaded_matches, timer_flag, clients, db).await;
      });
    } else {
      log::warn!("Timer already running");
    }
  }

  async fn stop_timer(&self) {
    let clients = self.clients.clone();
    let is_timer_running = self.is_timer_running.clone();

    if is_timer_running.load(std::sync::atomic::Ordering::Relaxed) {
      log::warn!("Stopping Timer");
      is_timer_running.store(false, std::sync::atomic::Ordering::Relaxed);
    } else {
      log::warn!("Timer not running");
      // reload clocks
      clients.read().await.publish_reload_timer();
    }
  }
}