// Database init using once_cell

use anyhow::Result;
use database::Database;
use once_cell::sync::OnceCell;

pub static DB: OnceCell<Database> = OnceCell::new();

pub fn initialize_db(db_path: &str) -> Result<()> {
  // check if DB is already set
  if DB.get().is_some() {
    log::warn!("DB already initialized");
    Ok(())
  } else {
    log::info!("Initializing DB");
    let db = Database::new(db_path.to_string())?;
    DB.set(db).map_err(|_| anyhow::anyhow!("Failed to set DB"))?;
    Ok(())
  }
}
