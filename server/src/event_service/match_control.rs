use log::warn;
use tms_utils::{TmsClients, tms_clients_ws_send, network_schemas::{SocketMessage, SocketMatchLoadedMessage}};

use crate::db::db::TmsDBArc;

#[derive(Clone)]
pub struct MatchControl {
  tms_db: TmsDBArc,
  tms_clients: TmsClients,
  loaded_matches: std::sync::Arc<tokio::sync::RwLock<Vec<String>>>,
  is_timer_running: std::sync::Arc<std::sync::atomic::AtomicBool>,
  is_matches_loaded: std::sync::Arc<std::sync::atomic::AtomicBool>
}

impl MatchControl {
  pub fn new(tms_db: TmsDBArc, tms_clients: TmsClients) -> Self {
    Self {
      tms_db,
      tms_clients,
      loaded_matches: std::sync::Arc::new(tokio::sync::RwLock::new(vec![])),
      is_timer_running: std::sync::Arc::new(std::sync::atomic::AtomicBool::new(false)),
      is_matches_loaded: std::sync::Arc::new(std::sync::atomic::AtomicBool::new(false)),
    }
  }

  async fn timer(time: u32, endgame_time: u32, loaded_matches: std::sync::Arc<tokio::sync::RwLock<Vec<String>>>, clients: TmsClients, timer_running: std::sync::Arc<std::sync::atomic::AtomicBool>, matches_loaded: std::sync::Arc<std::sync::atomic::AtomicBool>, tms_db: TmsDBArc) {
    // countdown from set time (150) to 0
    warn!("Timer running...");

    // Publish start message
    tms_clients_ws_send(SocketMessage {
      from_id: None,
      topic: String::from("clock"),
      sub_topic: String::from("start"),
      message: String::from("")
    }, clients.clone(), None).await;

    tms_clients_ws_send(SocketMessage {
      from_id: None,
      topic: String::from("clock"),
      sub_topic: String::from("time"),
      message: time.to_string(),
    }, clients.clone(), None).await;


    for i in (0..time).rev() {
      tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
      if !timer_running.load(std::sync::atomic::Ordering::Relaxed) {
        return;
      }
      // publish time message
      tms_clients_ws_send(SocketMessage {
        from_id: None,
        topic: String::from("clock"),
        sub_topic: String::from("time"),
        message: i.to_string()
      }, clients.clone(), None).await;

      // endgame message
      if i == endgame_time {
        tms_clients_ws_send(SocketMessage {
          from_id: None,
          topic: String::from("clock"),
          sub_topic: String::from("endgame"),
          message: i.to_string(),
        }, clients.clone(), None).await;
      }
    }

    tms_clients_ws_send(SocketMessage {
      from_id: None,
      topic: String::from("clock"),
      sub_topic: String::from("end"),
      message: String::from("")
    }, clients.clone(), None).await;

    // set database matches to be completed, send the update and unload the matches
    if timer_running.load(std::sync::atomic::Ordering::Relaxed) {
      for match_number in loaded_matches.read().await.iter() {
        match tms_db.get_data().await.matches.get(&match_number) {
          Ok(Some(mut game_match)) => {
            game_match.complete = true;
            let _ = tms_db.get_data().await.matches.insert(game_match.match_number.as_bytes(), game_match.clone());
            warn!("Match {} completed", game_match.match_number.clone());
            tokio::spawn(tms_clients_ws_send(SocketMessage {
              from_id: None,
              topic: String::from("match"),
              sub_topic: String::from("update"),
              message: game_match.match_number.clone(),
            }, clients.clone(), None));
          },
          Ok(None) => {
            println!("Failed to get match from db");
          },
          Err(e) => {
            println!("Failed to get match from db: {}", e);
          }
        }
      }
  
      // unload matches
      matches_loaded.store(false, std::sync::atomic::Ordering::Relaxed);
      loaded_matches.write().await.clear();
      tms_clients_ws_send(SocketMessage {
        from_id: None,
        topic: String::from("match"),
        sub_topic: String::from("unload"),
        message: String::from("")
      }, clients.clone(), None).await;
    }

    timer_running.store(false, std::sync::atomic::Ordering::Relaxed);
  }

  pub async fn start_timer(&mut self, override_running: bool) {
    // get time from db
    if !self.is_timer_running.load(std::sync::atomic::Ordering::Relaxed) || override_running {
      warn!("Starting timer...");
      self.is_timer_running.store(true, std::sync::atomic::Ordering::Relaxed);
      let time = match self.tms_db.get_data().await.event.get() {
        Ok(Some(event)) => event.timer_length,
        Ok(None) => 150,
        Err(e) => {
          println!("Failed to get event from db: {}", e);
          150
        }
      };
      let endgame_time = match self.tms_db.get_data().await.event.get() {
        Ok(Some(event)) => event.end_game_timer_length,
        Ok(None) => 30,
        Err(e) => {
          println!("Failed to get event from db: {}", e);
          30
        }
      };

      let timer_flag = self.is_timer_running.clone();
      let matches_loaded_flag = self.is_matches_loaded.clone();
      let clients = self.tms_clients.clone();
      let loaded_matches = self.loaded_matches.clone();
      let tms_db = self.tms_db.clone();
      
      tokio::task::spawn(async move {
        MatchControl::timer(time, endgame_time, loaded_matches, clients, timer_flag, matches_loaded_flag, tms_db).await;
      });
    } else {
      warn!("Timer already running!");
    }
  }

  async fn pre_timer(clients: TmsClients, timer_running: std::sync::Arc<std::sync::atomic::AtomicBool>) {
    // prestart timer, then start main timer
    warn!("Pre-Starting timer...");
    let pre_start_timer: u32 = 5;
    tms_clients_ws_send(SocketMessage {
      from_id: None,
      topic: String::from("clock"),
      sub_topic: String::from("pre_start"),
      message: String::from(""),
    }, clients.clone(), None).await;

    tms_clients_ws_send(SocketMessage {
      from_id: None,
      topic: String::from("clock"),
      sub_topic: String::from("time"),
      message: pre_start_timer.to_string(),
    }, clients.clone(), None).await;
    tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;

    for i in (1..pre_start_timer).rev() {
      if !timer_running.load(std::sync::atomic::Ordering::Relaxed) {
        return;
      }
  
      tms_clients_ws_send(SocketMessage {
        from_id: None,
        topic: String::from("clock"),
        sub_topic: String::from("time"),
        message: i.to_string(),
      }, clients.clone(), None).await;


      tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
    }
  }

  pub fn pre_start_timer(&mut self) {
    // get time from db
    if !self.is_timer_running.load(std::sync::atomic::Ordering::Relaxed) {
      self.is_timer_running.store(true, std::sync::atomic::Ordering::Relaxed);
      
      let timer_flag = self.is_timer_running.clone();
      let clients = self.tms_clients.clone();
      
      // one time starter function with override
      let start_timer_function = {
        let tms_db_clone = self.tms_db.clone();
        let tms_clients_clone = self.tms_clients.clone();
        let loaded_matches_clone = self.loaded_matches.clone();
        let is_timer_running_clone = self.is_timer_running.clone();
        let is_matches_loaded_clone = self.is_matches_loaded.clone();
        move |override_running| {
          let start_timer_function = async move {
            let mut control = MatchControl {
              tms_db: tms_db_clone,
              tms_clients: tms_clients_clone,
              loaded_matches: loaded_matches_clone,
              is_timer_running: is_timer_running_clone,
              is_matches_loaded: is_matches_loaded_clone
            };
            control.start_timer(override_running).await;
          };

          start_timer_function
        }
      };

      // pre-start the timer then run the main timer
      tokio::task::spawn(async move {
        MatchControl::pre_timer(clients, timer_flag.clone()).await;
        if timer_flag.load(std::sync::atomic::Ordering::Relaxed) {
          start_timer_function(true).await;
        }
      });
    } else {
      warn!("Timer already running!");
    }
  }

  pub fn stop_timer(&mut self) {
    warn!("Stopping timer...");
    if self.is_timer_running.load(std::sync::atomic::Ordering::Relaxed) {
      self.is_timer_running.store(false, std::sync::atomic::Ordering::Relaxed);
      tokio::spawn(tms_clients_ws_send(SocketMessage {
        from_id: None,
        topic: String::from("clock"),
        sub_topic: String::from("stop"),
        message: String::from("")
      }, self.tms_clients.clone(), None));
    } else {
      warn!("Cannot abort match. Timer is not running! Reloading clocks...");
      tokio::spawn(tms_clients_ws_send(SocketMessage {
        from_id: None,
        topic: String::from("clock"),
        sub_topic: String::from("reload"),
        message: String::from("")
      }, self.tms_clients.clone(), None));
    }
  }

  async fn send_load_matches(loaded_matches: Vec<String>, clients: TmsClients, matches_loaded: std::sync::Arc<std::sync::atomic::AtomicBool>) {
    while matches_loaded.load(std::sync::atomic::Ordering::Relaxed) {
      tms_clients_ws_send(SocketMessage {
        from_id: None,
        topic: String::from("match"),
        sub_topic: String::from("load"),
        message: serde_json::to_string(&SocketMatchLoadedMessage {
          match_numbers: loaded_matches.clone()
        }).unwrap()
      }, clients.clone(), None).await;
      tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
    }
  }

  pub fn load_matches(&mut self, matches: Vec<String>) {
    if !self.is_matches_loaded.load(std::sync::atomic::Ordering::Relaxed) {
      warn!("Loading matches...");
      self.is_matches_loaded.store(true, std::sync::atomic::Ordering::Relaxed);
      self.loaded_matches = std::sync::Arc::new(tokio::sync::RwLock::new(matches.clone()));
      let matches_loaded_flag = self.is_matches_loaded.clone();
      let clients = self.tms_clients.clone();
      tokio::task::spawn(async move {
        MatchControl::send_load_matches(matches, clients, matches_loaded_flag).await;
      });
    } else {
      warn!("Matches already loaded!");
    }
  }

  pub async fn unload_matches(&mut self) {
    warn!("Forcefully unloading matches...");
    self.is_matches_loaded.store(false, std::sync::atomic::Ordering::Relaxed);
    self.loaded_matches.write().await.clear();

    tokio::spawn(tms_clients_ws_send(SocketMessage {
      from_id: None,
      topic: String::from("match"),
      sub_topic: String::from("unload"),
      message: String::from("")
    }, self.tms_clients.clone(), None));
  }
}