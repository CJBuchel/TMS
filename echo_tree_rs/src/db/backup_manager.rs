use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio_stream::StreamExt;

use super::db::Database;

// const INTERNAL_ARCHIVE_NAME: &str = "backup.bin"; // never change this...

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
  fn new(data: Vec<(Vec<u8>, Vec<u8>, impl Iterator<Item = Vec<Vec<u8>>> + Send)>) -> Self {
    let serialized_data: Vec<SerializableData> = data
      .into_iter()
      .map(|(collection_type, collection_name, collection_iter)| SerializableData {
        collection_type,
        collection_name,
        collection_iter: collection_iter.collect(),
      })
      .collect();

    SerializableBackup { data: serialized_data }
  }

  fn from_serialized_bincode(serialized_data: Vec<u8>) -> Self {
    bincode::deserialize(&serialized_data).unwrap_or_default()
  }

  fn get(&self) -> Vec<(Vec<u8>, Vec<u8>, impl Iterator<Item = Vec<Vec<u8>>> + Send)> {
    self
      .data
      .iter()
      .map(|sd| {
        let collection_type = sd.collection_type.clone();
        let collection_name = sd.collection_name.clone();
        let collection_iter = sd.collection_iter.clone().into_iter();
        (collection_type, collection_name, collection_iter)
      })
      .collect()
  }

  fn get_serialized_bincode(&self) -> Vec<u8> {
    bincode::serialize(&self).unwrap_or_default()
  }
}

pub trait BackupManager {
  async fn get_backup_file_names(&self, backup_path: &str) -> Result<Vec<String>, Box<dyn std::error::Error>>;
  async fn backup_db(&self, backup_path: &str, retain_backups: usize) -> Result<(), Box<dyn std::error::Error>>;
  async fn restore_db(&mut self, backup_path: &str) -> Result<(), Box<dyn std::error::Error>>;
}

impl BackupManager for Database {
  async fn get_backup_file_names(&self, backup_path: &str) -> Result<Vec<String>, Box<dyn std::error::Error>> {
    let mut backups = Vec::new();

    if let Ok(read_dir) = tokio::fs::read_dir(backup_path).await {
      let mut entries = tokio_stream::wrappers::ReadDirStream::new(read_dir).collect::<Result<Vec<_>, _>>().await?;
      entries.sort_unstable_by_key(|entry| entry.file_name());

      for entry in entries {
        if let Some(file_name) = entry.file_name().to_str() {
          if file_name.ends_with(".zip") || file_name.ends_with(".gz") {
            backups.push(file_name.to_string());
          }
        }
      }
    }

    Ok(backups)
  }

  async fn backup_db(&self, backup_path: &str, retain_backups: usize) -> Result<(), Box<dyn std::error::Error>> {
    log::warn!("EchoTree backing up...");

    if let Some(parent_path) = std::path::Path::new(backup_path).parent() {
      tokio::fs::create_dir_all(parent_path).await?;

      // remove old backups (based on database retain)
      if retain_backups > 0 {
        // 0 means retain all backups
        if let Ok(read_dir) = tokio::fs::read_dir(parent_path).await {
          let mut entries = tokio_stream::wrappers::ReadDirStream::new(read_dir).collect::<Result<Vec<_>, _>>().await?;
          entries.sort_unstable_by_key(|entry| entry.file_name());

          while entries.len() >= retain_backups {
            if let Some(oldest) = entries.first() {
              tokio::fs::remove_file(oldest.path()).await?;
              entries.remove(0);
            }
          }
        }
      }
    }

    let file = tokio::fs::File::create(backup_path).await?;
    let mut encoder = async_compression::tokio::write::GzipEncoder::new(tokio::io::BufWriter::new(file));

    let backup_data = self.get_inner_db().await.export();
    let backup_data = SerializableBackup::new(backup_data);

    encoder.write_all(&backup_data.get_serialized_bincode()).await?;
    encoder.shutdown().await?;

    log::info!("EchoTree backup complete");

    Ok(())
  }

  async fn restore_db(&mut self, backup_path: &str) -> Result<(), Box<dyn std::error::Error>> {
    log::warn!("EchoTree restoring...");

    // check if file exists
    if !std::path::Path::new(backup_path).exists() {
      log::error!("Backup file does not exist: {}", backup_path);
      return Err(Box::new(std::io::Error::new(std::io::ErrorKind::NotFound, "Backup file not found")));
    }

    // clear database
    self.clear().await;

    let file = tokio::fs::File::open(backup_path).await?;
    let mut decoder = async_compression::tokio::bufread::GzipDecoder::new(tokio::io::BufReader::new(file));

    let mut serialized_data = Vec::new();
    decoder.read_to_end(&mut serialized_data).await?;

    let serializable_data = SerializableBackup::from_serialized_bincode(serialized_data);
    let import_data = serializable_data.get();

    self.get_inner_db().await.import(import_data);

    log::info!("EchoTree restore complete");
    Ok(())
  }
}
