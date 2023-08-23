use log::{error, warn};

use crate::db::db::TmsDB;

// #[derive(Clone)]
pub struct MatchControl {
  tms_db: std::sync::Arc<TmsDB>,
  time: u32,
  timer_running: std::sync::Arc<std::sync::atomic::AtomicBool>
}

impl MatchControl {
  pub fn new(tms_db: std::sync::Arc<TmsDB>) -> Self {
    let time = match tms_db.tms_data.event.get() {
      Ok(Some(event)) => event.timer_length,
      Ok(None) => 150,
      Err(e) => {
        error!("Failed to get time from db, defaulting to 150: {}", e);
        150
      }
    };

    Self {
      tms_db,
      time,
      timer_running: std::sync::Arc::new(std::sync::atomic::AtomicBool::new(false))
    }
  }

  async fn timer(time: u32, timer_running: std::sync::Arc<std::sync::atomic::AtomicBool>) {
    // countdown from set time (150) to 0
    warn!("Timer running...");
    for i in (0..time as i32).rev() {
      warn!("Time: {}", i);
      tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
    }
    timer_running.store(false, std::sync::atomic::Ordering::Relaxed);
    println!("Time's up!");
  }

  pub fn start_timer(&mut self) {
    // get time from db
    if !self.timer_running.load(std::sync::atomic::Ordering::Relaxed) {
      warn!("Starting timer...");
      self.timer_running.store(true, std::sync::atomic::Ordering::Relaxed);
      let time = match self.tms_db.tms_data.event.get() {
        Ok(Some(event)) => event.timer_length,
        Ok(None) => 150,
        Err(e) => {
          println!("Failed to get event from db: {}", e);
          150
        }
      };

      self.time = time;
      let timer_flag = self.timer_running.clone();
      tokio::task::spawn(async move {
        MatchControl::timer(time, timer_flag).await;
      });
    } else {
      warn!("Timer already running!");
    }
  }

  pub fn prestart_timer(self) {

  }
}