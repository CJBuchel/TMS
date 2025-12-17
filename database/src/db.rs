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

  pub fn get_table(&self, name: &str) -> Table {
    Table::get_table(name, self.db.clone())
  }
}
