use std::collections::HashMap;

use anyhow::Result;
use tokio::sync::RwLock;

use super::{record::Record, table::Table};

pub struct Database {
  db: sled::Db, // sled is an embedded thread safe db already
  // tables: DashMap<String, Table>, // DashMap is a thread-safe hashmap, allowing concurrent reads and writes to the tables
  tables: RwLock<HashMap<String, Table>>,
}

impl Database {
  /// Create a new database
  pub fn new(name: String) -> Result<Self> {
    log::info!("Opening database: {}", name);
    let db = sled::open(name)?;
    Ok(Self {
      db,
      // tables: DashMap::new(),
      tables: RwLock::new(HashMap::new()),
    })
  }

  /// Get the inner sled database
  pub fn get_inner_db(&self) -> &sled::Db {
    &self.db
  }

  /// Get or create a table for a record type
  pub async fn get_table<R: Record + 'static>(&self) -> Result<Table> {
    let table_name = R::table_name();

    // tru just read lock
    {
      let tables = self.tables.read().await;
      if tables.contains_key(table_name) {
        let table = match tables.get(table_name) {
          Some(table) => table,
          None => return Err(anyhow::anyhow!("Table not found")),
        };
        return Ok(table.clone());
      }
    }

    let mut tables = self.tables.write().await;
    // Check again after acquiring write lock (in case another thread created it)
    if !tables.contains_key(table_name) {
      let table = Table::open::<R>(&self.db)?;
      tables.insert(table_name.to_string(), table.clone());
      Ok(table)
    } else {
      Err(anyhow::anyhow!("Table not found"))
    }
  }

  /// Clear all the tables in the database
  pub async fn clear_tables(&self) -> Result<()> {
    for table in self.tables.read().await.values() {
      table.clear()?;
    }
    Ok(())
  }
}
