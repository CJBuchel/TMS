use super::extensions::*;
use super::SharedDatabase;

#[async_trait::async_trait]
pub trait IntegrityCheckService {
  async fn start_integrity_check_service(&mut self);
  async fn reset_integrity_check_service(&mut self);
  async fn stop_integrity_check_service(&mut self);
}

#[async_trait::async_trait]
impl IntegrityCheckService for SharedDatabase {
  async fn start_integrity_check_service(&mut self) {
    if self.read().await.integrity_check_service_thread.is_some() {
      log::warn!("Integrity check service already running");
      return;
    }

    let mut stop_signal_receiver = self.read().await.integrity_check_stop_signal_sender.subscribe();
    let mut reset_signal_receiver = self.read().await.integrity_check_reset_signal_sender.subscribe();

    // clone self to move into the async block
    let self_clone = self.clone();

    self.write().await.integrity_check_service_thread = Some(tokio::spawn(async move {
      loop {
        tokio::select! {
          _ = stop_signal_receiver.changed() => {
            log::info!("Integrity check service stopped");
            break;
          }
          _ = reset_signal_receiver.changed() => {
            log::info!("Integrity check service reset");
            continue;
          }
          _ = async {
            // run the integrity check
            self_clone.read().await.check_integrity().await;
            tokio::time::sleep(tokio::time::Duration::from_secs(10)).await;
          } => {}
        }
      }
    }));
  }

  async fn stop_integrity_check_service(&mut self) {
    if let Some(handle) = self.write().await.integrity_check_service_thread.take() {
      match self.read().await.integrity_check_stop_signal_sender.send(true) {
        Ok(_) => {
          log::info!("Stopping integrity check service...");
        }
        Err(e) => {
          log::error!("Failed to stop integrity check service: {:?}", e);
        }
      }
      match handle.await {
        Ok(_) => log::info!("Integrity check service stopped"),
        Err(e) => log::error!("Failed to stop integrity check service: {:?}", e),
      }
    }
  }

  async fn reset_integrity_check_service(&mut self) {
    if let Some(handle) = self.write().await.integrity_check_service_thread.take() {
      match self.read().await.integrity_check_reset_signal_sender.send(true) {
        Ok(_) => {
          log::info!("Resetting integrity check service...");
        }
        Err(e) => {
          log::error!("Failed to reset integrity check service: {:?}", e);
        }
      }
      self.write().await.integrity_check_service_thread = Some(handle);
    }
  }
}