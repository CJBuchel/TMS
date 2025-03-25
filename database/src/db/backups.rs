use std::fs::Metadata;

use anyhow::Result;
use tokio::{
  fs::DirEntry,
  io::{AsyncReadExt, AsyncWriteExt},
};
use tokio_stream::StreamExt;

use crate::db::collection::DatabaseCollection;

use super::Database;

pub trait Backups {
  async fn get_sorted_backup_entries(&self, parent_path: &str) -> Result<Vec<(DirEntry, Metadata)>>;
  async fn _backup_db(&self, backup_path: &str, retain_backups: usize) -> Result<()>;
  async fn _restore_db(&self, backup_path: &str) -> Result<()>;
}

impl Backups for Database {
  /// Get sorted backup entries
  async fn get_sorted_backup_entries(&self, parent_path: &str) -> Result<Vec<(DirEntry, Metadata)>> {
    // create the parent directory if it doesn't exist
    tokio::fs::create_dir_all(parent_path).await?;

    if let Ok(read_dir) = tokio::fs::read_dir(parent_path).await {
      let mut entries = Vec::new();

      // Collect entries with their metadata
      let mut stream = tokio_stream::wrappers::ReadDirStream::new(read_dir);
      while let Some(entry_result) = stream.next().await {
        if let Ok(entry) = entry_result {
          let metadata = tokio::fs::metadata(entry.path()).await?;
          entries.push((entry, metadata));
        }
      }

      // Sort by modified time
      entries.sort_by(|(_, meta_a), (_, meta_b)| {
        let meta_a_modified = match meta_a.modified() {
          Ok(modified) => modified,
          Err(e) => {
            log::warn!("Failed to get modified time for file: {:?}, error {:?}", meta_a, e);
            return std::cmp::Ordering::Equal;
          }
        };

        let meta_b_modified = match meta_b.modified() {
          Ok(modified) => modified,
          Err(e) => {
            log::warn!("Failed to get modified time for file: {:?}, error {:?}", meta_b, e);
            return std::cmp::Ordering::Equal;
          }
        };

        meta_a_modified.cmp(&meta_b_modified)
      });

      return Ok(entries);
    }

    Ok(vec![])
  }

  /// Backup the database to a file
  async fn _backup_db(&self, backup_path: &str, retain_backups: usize) -> Result<()> {
    log::warn!("Backing up database to: {}", backup_path);

    // create the parent directory if it doesn't exist
    if let Some(parent_path) = std::path::Path::new(backup_path).parent() {
      tokio::fs::create_dir_all(parent_path).await?;

      // remove old backups (based on retain_backups)
      if retain_backups > 0 {
        let entries = self.get_sorted_backup_entries(parent_path.to_str().unwrap()).await?;

        // Remove oldest files beyond retention limit
        for (entry, _) in entries.iter().take(entries.len().saturating_sub(retain_backups)) {
          tokio::fs::remove_file(entry.path()).await?;
        }
      }
    }

    // create a new backup
    let file = tokio::fs::File::create(backup_path).await?;
    let mut encoder = async_compression::tokio::write::GzipEncoder::new(tokio::io::BufWriter::new(file));

    // export the sled db
    let backup_data = self.get_inner_db().export();
    let backup_data = DatabaseCollection::new(backup_data);

    encoder.write_all(&backup_data.to_bytes()?).await?;
    encoder.shutdown().await?;

    log::info!("Created database backup: {}", backup_path);

    Ok(())
  }

  /// Restore the database from a backup file
  async fn _restore_db(&self, backup_path: &str) -> Result<()> {
    log::warn!("Restoring database from: {}", backup_path);

    // check if the file exists
    if !std::path::Path::new(backup_path).exists() {
      log::error!("Backup file does not exist: {}", backup_path);
      return Err(anyhow::anyhow!("Backup file does not exist"));
    }

    // clear the database
    self.clear_tables().await?;

    // open the backup file
    let file = tokio::fs::File::open(backup_path).await?;
    let mut decoder = async_compression::tokio::bufread::GzipDecoder::new(tokio::io::BufReader::new(file));

    // read the backup data
    let mut backup_data = Vec::new();
    decoder.read_to_end(&mut backup_data).await?;

    // convert the backup data to a sled db
    let backup_data = DatabaseCollection::from_bytes(backup_data)?;
    let import_data = backup_data.get();

    // import the backup data (THIS CAN PANIC)
    self.get_inner_db().import(import_data);

    log::info!("Restored database from: {}", backup_path);

    Ok(())
  }
}
