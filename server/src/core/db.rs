// Database init using once_cell

use anyhow::Result;
use database::Database;
use once_cell::sync::OnceCell;

use crate::features::{Team, TeamRepository, User, UserRepository};

pub static DB: OnceCell<Database> = OnceCell::new();

async fn db_data_init() -> Result<()> {
  log::info!("Initializing DB data");

  log::info!("Creating test team");
  let t = Team {
    name: "Test Team".to_string(),
    ..Team::default()
  };

  match Team::add(&t).await {
    Ok((_, _)) => log::info!("Team added"),
    Err(e) => log::error!("Failed to add team: {}", e),
  }

  match User::get_by_username(&"admin".to_string()).await {
    Ok(users) => {
      if users.is_empty() {
        log::info!("Creating Admin user");

        let admin = User {
          username: "admin".to_string(),
          password: "admin".to_string(),
          ..User::default()
        };

        match User::add(&admin).await {
          Ok((_, _)) => log::info!("Admin user added"),
          Err(e) => log::error!("Failed to add admin user: {}", e),
        }
      } else {
        log::info!("Admin user already exists");
      }
    }
    Err(e) => log::error!("Failed to get admin user: {}", e),
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
