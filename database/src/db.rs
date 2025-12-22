use anyhow::Result;

use crate::Table;

pub struct Database {
  db: sled::Db,
}

impl Database {
  /// Open a new database at the given path.
  pub fn new(path: String) -> Result<Self> {
    log::info!("Opening database: {}", path);
    let db = match sled::open(path) {
      Ok(db) => db,
      Err(e) => {
        log::error!("Failed to open database: {}", e);
        return Err(anyhow::anyhow!(e));
      }
    };
    Ok(Self { db })
  }

  /// Get a table from the database. (Creates if it doesn't exist)
  pub fn get_table(&self, name: &str) -> Table {
    Table::get_table(name, self.db.clone())
  }

  /// Deletes all records in the database
  pub fn clear(&self) -> Result<()> {
    match self.db.clear() {
      Ok(()) => Ok(()),
      Err(e) => {
        log::error!("Failed to clear database: {}", e);
        Err(anyhow::anyhow!(e))
      }
    }
  }
}
