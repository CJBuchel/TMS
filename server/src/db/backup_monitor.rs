use log::warn;

use super::backup_service::{BackupService, BackupServiceArc};


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
    warn!("Starting backup monitor service");
    loop {
      tokio::select! {
        _ = tokio::time::sleep(tokio::time::Duration::from_secs(60)) => {
          self.backup_service.backup_db(false);
        },

        // ctrl-c
        _ = tokio::signal::ctrl_c() => {
          warn!("Stopping backup service");
          break;
        }
      }
    }
  }
}