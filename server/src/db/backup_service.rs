use std::{time::{SystemTime, UNIX_EPOCH}, path::Path, fs, io::{Read, Write}};

use log::{warn, error};
use tms_utils::schemas::Backup;
use zip::write::FileOptions;

use super::db::TmsDBArc;

pub struct BackupService {
  db_name: String,
  db: TmsDBArc
}

pub type BackupServiceArc = std::sync::Arc<tokio::sync::RwLock<BackupService>>;

pub async fn with_backup_service_write<F, R>(backup_service: &BackupServiceArc, f: F) -> Result<R, &'static str>
where
  F: FnOnce(&mut BackupService) -> R,
{
  let mut guard = backup_service.write().await;
  Ok(f(&mut *guard))
}

impl BackupService {
  pub fn new(db_name: String, db: TmsDBArc) -> Self {
    Self {
      db_name,
      db
    }
  }

  fn check_backups_folder(&self) -> bool {
    // check if it exists
    if !Path::new("backups").exists() {
      match fs::create_dir("backups") {
        Ok(_) => {
          return true;
        },
        Err(_) => {
          error!("Failed to create backups folder");
          return false;
        }
      }
    } else {
      return true;
    }
  }

  async fn get_backup_info(&self) -> (u32, usize, String) {
    let event = match self.db.get_data().await.event.get() {
      Ok(event) => {
        event
      },
      Err(_) => {
        warn!("Failed to get event (backup)");
        None
      }
    };

    // convert name to string (replace spaces with underscores, remove non-alphanumeric characters)
    let event_name = match event.clone() {
      Some(event) => {
        let mut name = event.name.clone();
        name.retain(|c| c.is_alphanumeric());
        name
      },
      None => {
        String::from("")
      }
    };
  
    match event {
      Some(event) => {
        let backup_interval = event.backup_interval;
        let backup_count = event.backup_count;
        (backup_interval, backup_count, event_name)
      },
      None => {
        (0, 0, String::from(""))
      }
    }
  }

  async fn get_backup_times(&self) -> Result<(u64, u64), &'static str> {
    let now = match SystemTime::now().duration_since(UNIX_EPOCH) {
      Ok(now) => {
        now.as_secs()
      },
      Err(_) => {
        error!("Failed to get time since epoch");
        return Err("Failed to get time since epoch");
      }
    };

    let last_backup = match self.db.get_data().await.system_info.get() {
      Ok(info) => {
        match info {
          Some(info) => {
            info.last_backup
          },
          None => {
            error!("No system info (backup)");
            None
          }
        }
      },
      Err(_) => {
        error!("Failed to get system info (backup)");
        return Err("Failed to get system info (backup)");
      }
    };

    match last_backup {
      Some(last_backup) => {
        Ok((now, last_backup))
      },
      None => {
        warn!("No last backup time, setting to current time");
        let mut info = self.db.get_data().await.system_info.get().unwrap().unwrap();
        info.last_backup = Some(now);
        self.db.get_data().await.system_info.set(info).unwrap();
        Ok((now, now))
      }
    }
  }

  async fn should_backup(&self, now: u64, last_backup: u64) -> bool {
    let (backup_interval, count, _) = self.get_backup_info().await;

    if backup_interval == 0 || count == 0 {
      return false;
    }

    // convert from minutes to seconds
    let backup_interval_secs = backup_interval as u64 * 60;

    if now - last_backup >= backup_interval_secs {
      return true;
    } else {
      return false;
    }
  }

  fn create_backup_file(&self, now: u64, event_name: String) -> Result<(), &'static str> {

    let backup_folder = format!("backups/{}_{}_{}.zip", event_name, now, self.db_name);

    // check if the backup folder exists
    self.check_backups_folder();

    let db_folder = Path::new(self.db_name.as_str());
    match fs::File::create(&backup_folder) {
      Ok(output_file) => {
        let mut zip = zip::ZipWriter::new(output_file);
        let options = FileOptions::default()
          .compression_method(zip::CompressionMethod::Stored)
          .unix_permissions(0o755);

        for entry in walkdir::WalkDir::new(db_folder) {
          match entry {
            Ok(entry) => {
              let path = entry.path();
              let name = match path.strip_prefix(db_folder) {
                Ok(name) => {
                  name
                },
                Err(_) => {
                  error!("Failed to strip prefix");
                  continue;
                }
              };

              if path.is_file() {
                zip.start_file(name.to_string_lossy(), options).unwrap();
                let mut f = fs::File::open(path).unwrap();
                let mut buffer = Vec::new();
                f.read_to_end(&mut buffer).unwrap();
                zip.write_all(&buffer).unwrap();
              }
            },

            Err(_) => {
              error!("Failed to read file in db folder");
              continue;
            }
          }
        }

        match zip.finish() {
          Ok(_) => Ok(()),
          Err(_) => {
            error!("Failed to finish backup zip");
            Err("Failed to finish backup zip")
          }
        }
      },
      Err(_) => {
        error!("Failed to create backup folder");
        Err("Failed to create backup folder")
      },
    }
  }

  pub fn get_backup_names(&self) -> Vec<String> {
    let mut backups = Vec::new();
    // check if it exists
    if self.check_backups_folder() {
      match fs::read_dir("backups") {
        Ok(entries) => {
          for entry_result in entries {
            match entry_result {
              Ok(entry) => {
                let path = entry.path();
                let name = path.file_name().unwrap().to_str().unwrap().to_string();
                backups.push(name);
              },
              Err(_) => {
                error!("Failed to read backup folder");
                continue;
              }
            }
          }
        },
        Err(_) => {
          error!("Failed to read backup folder");
        }
      }
    }
    backups
  }

  // get the backups with the time in a pretty format <name, time>
  pub fn get_backups_pretty(&self) -> Vec<Backup> {
    let mut backups = Vec::new();

    // check if it exists
    if self.check_backups_folder() {
      match fs::read_dir("backups") {
        Ok(entries) => {
          for entry_result in entries {
            match entry_result {
              Ok(entry) => {
                let path = entry.path();
                let name = path.file_name().unwrap().to_str().unwrap().to_string();
          
                // convert the time to a pretty format
                match path.metadata() {
                  Ok(metadata) => {
                    let time = match metadata.created() {
                      Ok(time) => {
                        time
                      },
                      Err(_) => {
                        error!("Failed to get backup time");
                        continue;
                      }
                    };

                    let timestamp = match time.duration_since(UNIX_EPOCH) {
                      Ok(timestamp) => {
                        timestamp.as_secs()
                      },
                      Err(_) => {
                        error!("Failed to get backup time");
                        continue;
                      }
                    };

                    let time = match chrono::NaiveDateTime::from_timestamp_opt(timestamp as i64, 0) {
                      Some(time) => {
                        time.format("%Y-%m-%d-%H:%M:%S").to_string()
                      },
                      None => {
                        error!("Failed to convert time to NaiveDateTime");
                        String::from("Failed to convert time to NaiveDateTime")
                      }
                    };
                    // backups.insert(name, time);
                    backups.push(Backup {
                      entry: name,
                      timestamp_pretty: time,
                      timestamp: timestamp as u64
                    });
                  },
                  Err(_) => {
                    error!("Failed to read backup folder");
                    continue;
                  }
                }
              },
              Err(_) => {
                error!("Failed to read backup folder");
                continue;
              }
            }
          }
        },
        
        Err(_) => {
          error!("Failed to read backup folder");
        }
      }
    }


    backups
  }

  pub fn download_backup(&self, backup_name: String) -> Vec<u8> {
    let mut buffer = Vec::new();
    if self.check_backups_folder() {
      let mut file = fs::File::open(format!("backups/{}", backup_name)).unwrap();
      file.read_to_end(&mut buffer).unwrap();
    }
    buffer
  }

  fn delete_old_backups(&self, backup_count: usize) {
    let backups = self.get_backup_names().len();
    if backups > backup_count {
      let oldest_backup = fs::read_dir("backups")
        .unwrap()
        .min_by_key(|res| {
          let file = res.as_ref().unwrap();
          file.metadata().unwrap().created().unwrap()
        })
        .unwrap()
        .unwrap();

      fs::remove_file(oldest_backup.path()).unwrap();
      warn!("Deleted old backups");
    }
  }

  pub async fn upload_backup(&self, backup_name: String, data: Vec<u8>) -> Result<(), &'static str> {
    // delete old backups (make space if needed)
    let (_, backup_count, _) = self.get_backup_info().await;
    self.delete_old_backups(backup_count);

    // upload the backup to folder
    match fs::File::create(format!("backups/{}", backup_name)) {
      Ok(mut file) => {
        match file.write_all(&data) {
          Ok(_) => Ok(()),
          Err(_) => {
            error!("Failed to write backup file");
            return Err("Failed to write backup file");
          }
        }
      },
      Err(_) => {
        error!("Failed to create backup file");
        Err("Failed to create backup file")
      }
    }
  }

  pub async fn upload_restore_backup(&self, backup_name: String, data: Vec<u8>) -> Result<(), &'static str> {
    // upload the backup to folder
    warn!("Uploading backup...");
    self.upload_backup(backup_name.clone(), data).await?;

    // restore using the backup
    warn!("Restoring backup {}...", backup_name);
    self.restore_db(backup_name).await
  }

  pub fn delete_backup(&self, backup: String) {
    if self.check_backups_folder() {
      fs::remove_file(format!("backups/{}", backup)).unwrap();
    }
  }

  
  pub async fn backup_db(&self, force: bool) {
    let (now, last_backup) = match self.get_backup_times().await {
      Ok((now, last_backup)) => {
        (now, last_backup)
      },
      Err(_) => {
        error!("Failed to get backup times");
        return;
      }
    };

    let (_, backup_count, event_name) = self.get_backup_info().await;
   
    if self.should_backup(now, last_backup).await || force {
      warn!("Backing up database...");
      // create backup file
      match self.create_backup_file(now, event_name) {
        Ok(_) => {},
        Err(_) => {
          error!("Failed to create backup, returning...");
          return;
        }
      }
      // delete old backups
      self.delete_old_backups(backup_count);
      warn!("Backup complete");
      // update last backup time
      let mut info = self.db.get_data().await.system_info.get().unwrap().unwrap();
      info.last_backup = Some(now);
      self.db.get_data().await.system_info.set(info).unwrap();
    }
  }

  pub async fn restore_db(&self, backup: String) -> Result<(), &'static str> {
    let db_folder = Path::new(self.db_name.as_str());
    let backup_folder = format!("backups/{}", backup);

    // check if file exists
    if !Path::new(&backup_folder).exists() {
      error!("Backup file does not exist");
      return Err("Backup file does not exist");
    }

    // flush the db
    self.db.flush().await;

    match fs::remove_dir_all(db_folder) {
      Ok(_) => {},
      Err(_) => {
        error!("Failed to remove db folder");
        return Err("Failed to remove db folder");
      }
    };

    let file = match fs::File::open(&Path::new(backup_folder.as_str())) {
      Ok(f) => {
        f
      },
      Err(_) => {
        error!("Failed to open backup file: {}", backup_folder);
        return Err("Failed to open backup file");
      }
    };

    let mut archive = zip::ZipArchive::new(file).unwrap();
    for i in 0..archive.len() {
    let mut file = archive.by_index(i).unwrap();
    let out_path = db_folder.join(file.mangled_name());
      if (&*file.name()).ends_with('/') {
        fs::create_dir_all(&out_path).unwrap();
      } else {
        if let Some(p) = out_path.parent() {
          if !p.exists() {
            fs::create_dir_all(&p).unwrap();
          }
        }
        let mut out_file = fs::File::create(&out_path).unwrap();
        std::io::copy(&mut file, &mut out_file).unwrap();
      }
    }

    // reload the db
    match self.db.reload().await {
      Ok(_) => {
        warn!("Database reloaded");
        Ok(())
      },
      Err(_) => {
        error!("Failed to reload db");
        Err("Failed to reload db")
      }
    }
  }
}
