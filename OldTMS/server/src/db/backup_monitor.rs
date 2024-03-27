use log::warn;

use super::backup_service::BackupServiceArc;


pub struct BackupMonitor {
  backup_service: BackupServiceArc,
}

impl BackupMonitor {
  pub fn new(backup_service: BackupServiceArc) -> Self {
    Self {
      backup_service
    }
  }

  pub async fn start(&self) {
    warn!("Starting Backup Service");
    loop {
      tokio::select! {
        _ = tokio::time::sleep(tokio::time::Duration::from_secs(60)) => {
          self.backup_service.read().await.backup_db(false).await;
        },

        // ctrl-c
        _ = tokio::signal::ctrl_c() => {
          warn!("Stopping Backup Service");
          break;
        }
      }
    }
  }
}