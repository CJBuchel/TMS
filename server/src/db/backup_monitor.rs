use log::warn;

use super::backups::BackupService;


pub struct BackupMonitor {
  backup_service: std::sync::Arc<std::sync::Mutex<BackupService>>,
}

impl BackupMonitor {
  pub fn new(backup_service: std::sync::Arc<std::sync::Mutex<BackupService>>) -> Self {
    Self {
      backup_service
    }
  }

  pub async fn start(&self) {
    warn!("Starting backup monitor (will check every 60 seconds)");
    loop {
      tokio::select! {
        _ = tokio::time::sleep(tokio::time::Duration::from_secs(60)) => {
          let backup_service = self.backup_service.clone();
          let guard: std::sync::MutexGuard<'_, BackupService> = backup_service.lock().unwrap();
          guard.backup_db();
        },

        // ctrl-c
        _ = tokio::signal::ctrl_c() => {
          warn!("Stopping backup monitor");
          break;
        }
      }
    }
  }
}