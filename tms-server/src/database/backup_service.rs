use echo_tree_rs::core::TreeManager;
use tms_infra::*;

use super::Database;

#[async_trait::async_trait]
pub trait BackupService {
  fn get_backup_name_format(name: String) -> String {
    let bp_name = format!("{}-backup-{}_{}.kvdb.zip", name, chrono::Local::now().format("%Y-%m-%d"), chrono::Local::now().format("%H-%M-%S"));
    bp_name.replace(" ", "_").replace(":", "-")
  }
  fn get_named_backup_path(&self, backup_name: String) -> String;
  fn get_base_backup_path(&self) -> String;
  fn start_backup_service(&mut self);
  fn reset_backup_service(&mut self);
  async fn create_manual_backup(&mut self);
  async fn stop_backup_service(&mut self);
}

#[async_trait::async_trait]
impl BackupService for Database {
  fn get_named_backup_path(&self, backup_name: String) -> String {
    let bp_name = format!("{}/{}", self.backups_path, backup_name);
    bp_name.replace(" ", "_").replace(":", "-")
  }

  fn get_base_backup_path(&self) -> String {
    self.backups_path.clone()
  }

  fn start_backup_service(&mut self) {
    if self.backup_service_thread.is_some() {
      log::warn!("Backup service already running");
      return;
    }

    let mut stop_signal_receiver = self.backup_service_stop_signal_sender.subscribe();
    let mut reset_signal_receiver = self.backup_service_reset_signal_sender.subscribe();
    let inner = self.inner.clone();
    let base_backup_path = self.get_base_backup_path();

    self.backup_service_thread = Some(tokio::spawn(async move {
      loop {
        tokio::select! {
          _ = stop_signal_receiver.changed() => {
            log::info!("Backup service stopped");
            break;
          }
          _ = reset_signal_receiver.changed() => {
            log::info!("Backup service reset");
            continue;
          }
          _ =  async {
            // backup code
            let config = inner.read().await.get_entry(":tournament:config".to_string(), "config".to_string()).await;
            match config {
              Some(config) => {
                let config = TournamentConfig::from_json_string(&config);
                let interval_seconds = config.backup_interval * 60;
                let name = if config.name.is_empty() { "tms".to_string() } else { config.name };
                let backup_name = Self::get_backup_name_format(name);
                let retain_backups: usize = config.retain_backups.try_into().unwrap_or(0);


                match inner.read().await.backup_db(&format!("{}/{}", base_backup_path, backup_name), retain_backups).await {
                  Ok(_) => {
                    log::info!("Backup successful: {}", backup_name);
                  },
                  Err(e) => {
                    log::error!("Backup failed: {:?}", e);
                  }
                }

                tokio::time::sleep(tokio::time::Duration::from_secs(interval_seconds as u64)).await;
              },
              None => {
                log::warn!("No backup configuration found");
                tokio::time::sleep(tokio::time::Duration::from_secs(10 * 60)).await;
              }
            }
          } => {}
        }
      }
    }));
  }

  async fn create_manual_backup(&mut self) {
    let config: Option<String> = self.inner.read().await.get_entry(":tournament:config".to_string(), "config".to_string()).await;
    let config: TournamentConfig = match config {
      Some(c) => TournamentConfig::from_json_string(&c),
      None => TournamentConfig::default()
    };
    let backup_name = if config.name.is_empty() { "tms".to_string() } else { config.name };
    let backup_name = Self::get_backup_name_format(backup_name);
    let retain_backups: usize = config.retain_backups.try_into().unwrap_or(0);

    match self.inner.read().await.backup_db(&format!("{}/{}", self.get_base_backup_path(), backup_name), retain_backups).await {
      Ok(_) => {
        log::info!("Manual backup successful: {}", backup_name);
      },
      Err(e) => {
        log::error!("Manual backup failed: {:?}", e);
      }
    }
  }

  async fn stop_backup_service(&mut self) {
    if let Some(handle) = self.backup_service_thread.take() {
      match self.backup_service_stop_signal_sender.send(true) {
        Ok(_) => {
          log::info!("Backup service stopping...")
        }
        Err(e) => {
          log::error!("Error stopping backup service: {}", e)
        }
      }
      match handle.await {
        Ok(_) => {
          log::info!("Backup service stopped");
        }
        Err(e) => {
          log::error!("Failed to join backup service: {}", e);
        }
      }
    }
  }

  fn reset_backup_service(&mut self) {
    if let Some(handle) = self.backup_service_thread.take() {
      match self.backup_service_reset_signal_sender.send(true) {
        Ok(_) => {
          log::info!("Backup service resetting...")
        }
        Err(e) => {
          log::error!("Error resetting backup service: {}", e)
        }
      }
      self.backup_service_thread = Some(handle);
    }
  }
}
