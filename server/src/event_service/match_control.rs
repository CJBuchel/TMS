use log::{error, warn};

use crate::db::db::TmsDB;

// #[derive(Clone)]
pub struct MatchControl {
  tms_db: std::sync::Arc<TmsDB>,
  time: std::sync::atomic::AtomicU32,
  timer_running: std::sync::atomic::AtomicBool
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
      time: std::sync::atomic::AtomicU32::new(time),
      timer_running: std::sync::atomic::AtomicBool::new(false)
    }
  }

  async fn timer(&mut self) {
    // countdown from set time (150) to 0
    warn!("Timer running...");
    for i in (0..*self.time.get_mut() as i32).rev() {
      warn!("Time: {}", i);
      tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
    }
    println!("Time's up!");
  }

  pub fn start_timer(&mut self) {
    // get time from db
    if self.timer_running.load(std::sync::atomic::Ordering::Relaxed) == false {
      warn!("Starting timer...");
      self.timer_running.get_mut() = true;
      let time = match self.tms_db.tms_data.event.get() {
        Ok(Some(event)) => event.timer_length,
        Ok(None) => 150,
        Err(e) => {
          println!("Failed to get event from db: {}", e);
          150
        }
      };

      self.time = time;

      // launch timer in it's own thread
      tokio::spawn(async move {
        self.timer().await;
        // self.timer_running = false;
      });
    } else {
      warn!("Timer already running!");
    }
  }

  pub fn prestart_timer(self) {

  }
}