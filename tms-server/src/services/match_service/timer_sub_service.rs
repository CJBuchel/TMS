use crate::{database::*, network::ClientMap, network::client_publish::*};

use super::MatchService;

type AtomicRefBool = std::sync::Arc<std::sync::atomic::AtomicBool>;
type AtomicRefStrVec = std::sync::Arc<tokio::sync::RwLock<Vec<String>>>;

#[async_trait::async_trait]
pub trait TimerSubService {
  async fn timer(
    time: u32, 
    endgame_time: u32, 
    loaded_matches: AtomicRefStrVec,
    timer_running: AtomicRefBool,
    clients: ClientMap,
    db: SharedDatabase,
  );
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

    let read_clients = clients.read().await;

    // send the start message
    read_clients.publish_start_timer();
    // send time message
    read_clients.publish_time_timer(time);

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
      read_clients.publish_time_timer(i);

      // check if timer is endgame, send the endgame signal once
      if i == endgame_time {
        read_clients.publish_endgame_timer(endgame_time);
      }

      let elapsed_epoch = start_epoch.elapsed();
      if let Some(sleep_duration) = std::time::Duration::from_secs(1).checked_sub(elapsed_epoch) {
        tokio::time::sleep(sleep_duration).await;
      }
    }

    // countdown finished, send end message
    read_clients.publish_end_timer();

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
      read_clients.publish_unload_matches();
    }

    // finally set timer no longer running
    timer_running.store(false, std::sync::atomic::Ordering::Relaxed);
  }
}