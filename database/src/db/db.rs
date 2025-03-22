use anyhow::{Ok, Result};
use dashmap::DashMap;
use dashmap::mapref::one::Ref;

use super::{record::Record, table::Table};

pub struct Database {
  db: sled::Db,                   // sled is an embedded thread safe db already
  tables: DashMap<String, Table>, // DashMap is a thread-safe hashmap, allowing concurrent reads and writes to the tables
}

impl Database {
  /// Create a new database
  pub fn new(name: String) -> Result<Self> {
    log::info!("Opening database: {}", name);
    let db = sled::open(name)?;
    Ok(Self {
      db,
      tables: DashMap::new(),
    })
  }

  pub fn get_or_create_table<R: Record + 'static>(&self) -> Result<Ref<'_, String, Table>> {
    let table_name = R::table_name();

    if !self.tables.contains_key(table_name) {
      let table = Table::open::<R>(&self.db)?;
      self.tables.insert(table_name.to_string(), table);
    }

    let table = match self.tables.get(table_name) {
      Some(table) => table,
      None => return Err(anyhow::anyhow!("Table not found")),
    };

    Ok(table)
  }

  /// Clear all the tables in the database
  pub fn clear_tables(&self) -> Result<()> {
    for table in self.tables.iter() {
      table.clear()?;
    }
    Ok(())
  }
}
