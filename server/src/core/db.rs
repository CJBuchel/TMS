// Database init using once_cell

use anyhow::Result;
use database::Database;
use once_cell::sync::OnceCell;

use crate::features::{Team, TeamRepository};

pub static DB: OnceCell<Database> = OnceCell::new();

async fn db_data_init() -> Result<()> {
  log::info!("Initializing DB data");
  let t = Team {
    name: "Test Team".to_string(),
    ..Team::default()
  };

  match Team::add(t).await {
    Ok((_, _)) => log::info!("Team added"),
    Err(e) => log::error!("Failed to add team: {}", e),
  }

  Ok(())
}

pub async fn initialize_db(db_path: &str) -> Result<()> {
  // check if DB is already set
  if DB.get().is_some() {
    log::warn!("DB already initialized");
  } else {
    log::info!("Initializing DB");
    let db = Database::new(db_path.to_string())?;
    DB.set(db).map_err(|_| anyhow::anyhow!("Failed to set DB"))?;
  }

  // Initialize the data
  match db_data_init().await {
    Ok(_) => log::info!("DB data initialized"),
    Err(e) => log::error!("Failed to initialize DB data: {}", e),
  }

  Ok(())
}
