use std::{time::{SystemTime, UNIX_EPOCH}, path::Path, fs, io::{Read, Write}};

use log::{warn, error};
use zip::write::FileOptions;

use super::db::TmsDB;

pub struct BackupService {
  db_name: String,
  db: std::sync::Arc<TmsDB>
}

impl BackupService {
  pub fn new(db_name: String, db: std::sync::Arc<TmsDB>) -> Self {
    Self {
      db_name,
      db
    }
  }

  fn get_backup_info(&self) -> (u32, usize) {
    let event = match self.db.tms_data.event.get() {
      Ok(event) => {
        event
      },
      Err(_) => {
        warn!("Failed to get event (backup)");
        None
      }
    };
  
    match event {
      Some(event) => {
        let backup_interval = event.backup_interval;
        let backup_count = event.backup_count;
        (backup_interval, backup_count)
      },
      None => {
        (0, 0)
      }
    }
  }

  fn get_backup_times(&self) -> Result<(u64, u64), &'static str> {
    let now = match SystemTime::now().duration_since(UNIX_EPOCH) {
      Ok(now) => {
        now.as_secs()
      },
      Err(_) => {
        error!("Failed to get time since epoch");
        return Err("Failed to get time since epoch");
      }
    };

    let last_backup = match self.db.tms_data.system_info.get() {
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
        let mut info = self.db.tms_data.system_info.get().unwrap().unwrap();
        info.last_backup = Some(now);
        self.db.tms_data.system_info.set(info).unwrap();
        Ok((now, now))
      }
    }
  }

  fn should_backup(&self, now: u64, last_backup: u64) -> bool {
    let (backup_interval, count) = self.get_backup_info();

    if backup_interval == 0 || count == 0 {
      return false;
    }

    if now - last_backup >= backup_interval as u64 {
      return true;
    } else {
      return false;
    }
  }

  fn create_backup_file(&self, now: u64) -> Result<(), &'static str> {
    let backup_folder = format!("backups/{}_{}.zip", self.db_name, now);

    // check if the backup folder exists
    if !Path::new("backups").exists() {
      fs::create_dir("backups").unwrap();
    }

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


  fn delete_old_backups(&self, backup_count: usize) {
    let backups = fs::read_dir("backups").unwrap().count();
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
  
  pub fn backup_db(&self) {
    let (now, last_backup) = match self.get_backup_times() {
      Ok((now, last_backup)) => {
        (now, last_backup)
      },
      Err(_) => {
        error!("Failed to get backup times");
        return;
      }
    };

    let (_, backup_count) = self.get_backup_info();
   
    if self.should_backup(now, last_backup) {
      warn!("Backing up database...");
      // create backup file
      match self.create_backup_file(now) {
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
      let mut info = self.db.tms_data.system_info.get().unwrap().unwrap();
      info.last_backup = Some(now);
      self.db.tms_data.system_info.set(info).unwrap();
    } else {
      warn!("Skipping backup");
    }
  }

  pub fn restore_db(&self, backup_folder: &str) {
    let db_folder = Path::new(self.db_name.as_str());
    fs::remove_dir_all(db_folder).unwrap();
    let file = fs::File::open(&Path::new(backup_folder)).unwrap();
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
  }
}
