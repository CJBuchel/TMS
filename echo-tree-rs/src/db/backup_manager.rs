use std::io::{BufWriter, Read, Write};
use super::db::Database;

const INTERNAL_ARCHIVE_NAME: &str = "backup.bin"; // never change this...

#[derive(serde::Serialize, serde::Deserialize)]
struct SerializableData {
  collection_type: Vec<u8>,
  collection_name: Vec<u8>,
  collection_iter: Vec<Vec<Vec<u8>>>, // collected iterator data
}

#[derive(serde::Serialize, serde::Deserialize)]
struct SerializableBackup {
  data: Vec<SerializableData>,
}

impl Default for SerializableBackup {
  fn default() -> Self {
    SerializableBackup { data: Vec::new() }
  }
}

impl SerializableBackup {
  fn new(data: Vec<(Vec<u8>, Vec<u8>, impl Iterator<Item = Vec<Vec<u8>>> + 'static)>) -> Self {
    let serialized_data: Vec<SerializableData> = data.into_iter().map(|(collection_type, collection_name, collection_iter)| {
      // Directly collect the iterator data into the required format
      let collection_iter: Vec<Vec<Vec<u8>>> = collection_iter.collect();
      SerializableData { collection_type, collection_name, collection_iter }
    }).collect();

    SerializableBackup { data: serialized_data }
  }

  fn from_serialized_bincode(serialized_data: Vec<u8>) -> Self {
    bincode::deserialize(&serialized_data).unwrap_or_default()
  }

  fn get(&self) -> Vec<(Vec<u8>, Vec<u8>, impl Iterator<Item = Vec<Vec<u8>>>)> {
    self.data.iter().map(|sd| {
      let collection_type = sd.collection_type.clone();
      let collection_name = sd.collection_name.clone();

      let collection_iter = sd.collection_iter.clone().into_iter().map(move |item| item);
      (collection_type, collection_name, Box::new(collection_iter) as Box<dyn Iterator<Item = Vec<Vec<u8>>>>)
    }).collect()
  }

  fn get_serialized_bincode(&self) -> Vec<u8> {
    bincode::serialize(&self).unwrap_or_default()
  }
}

pub trait BackupManager {
  async fn get_backup_file_names(&self, backup_path: &str) -> zip::result::ZipResult<Vec<String>>;
  async fn backup_db(&self, backup_path: &str, retain_backups: usize) -> zip::result::ZipResult<()>;
  async fn restore_db(&mut self, backup_path: &str) -> zip::result::ZipResult<()>;
}

impl BackupManager for Database {
  async fn get_backup_file_names(&self, backup_path: &str) -> zip::result::ZipResult<Vec<String>> {
    let mut backups = Vec::new();

    if let Ok(entries) = std::fs::read_dir(backup_path) {
      for entry in entries {
        if let Ok(entry) = entry {
          if let Some(file_name) = entry.file_name().to_str() {
            if file_name.ends_with(".zip") {
              backups.push(file_name.to_string());
            }
          }
        }
      }
    }

    Ok(backups)
  }

  async fn backup_db(&self, backup_path: &str, retain_backups: usize) -> zip::result::ZipResult<()> {
    log::warn!("EchoTree backing up...");

    if let Some(parent_path) = std::path::Path::new(backup_path).parent() {
      std::fs::create_dir_all(parent_path)?;

      // remove old backups (based on database retain)
      if retain_backups > 0 { // 0 means retain all backups
        if let Ok(entries) = std::fs::read_dir(parent_path) {
          let mut entries: Vec<_> = entries
            .map(|res| res.map(|e| e.path()))
            .collect::<Result<_, _>>()?;
  
          entries.sort_unstable();
          while entries.len() >= retain_backups {
            if let Some(oldest) = entries.first() {
              std::fs::remove_file(oldest)?;
              entries.remove(0);
            }
          }
        }
      }
    }

    let file = std::fs::File::create(backup_path)?;
    let mut zip = zip::ZipWriter::new(BufWriter::new(file));
    
    let backup_data = self.get_inner_db().await.export();
    let backup_data = SerializableBackup::new(backup_data);

    let options = zip::write::FileOptions::default().compression_method(zip::CompressionMethod::Stored).unix_permissions(0o755);
    zip.start_file(INTERNAL_ARCHIVE_NAME, options)?;
    zip.write_all(&backup_data.get_serialized_bincode())?;

    zip.finish()?;
    log::info!("EchoTree backup complete");

    Ok(())
  }

  async fn restore_db(&mut self, backup_path: &str) -> zip::result::ZipResult<()> {
    log::warn!("EchoTree restoring...");

    // check if file exists
    if !std::path::Path::new(backup_path).exists() {
      log::error!("Backup file does not exist: {}", backup_path);
      return Err(zip::result::ZipError::FileNotFound);
    }

    // clear database
    self.clear().await;

    let file = std::fs::File::open(backup_path)?;
    let mut zip = zip::ZipArchive::new(file)?;

    let mut backup_file = zip.by_name(INTERNAL_ARCHIVE_NAME)?;
    let mut serialized_data = Vec::new();
    backup_file.read_to_end(&mut serialized_data)?;

    let serializable_data = SerializableBackup::from_serialized_bincode(serialized_data);
    let import_data = serializable_data.get();

    self.get_inner_db().await.import(import_data);

    log::info!("EchoTree restore complete");
    Ok(())
  }
}
