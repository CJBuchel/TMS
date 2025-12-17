use anyhow::Result;
use database::Database;
use once_cell::sync::OnceCell;
use tonic::Status;

use crate::{
  TmsConfig,
  generated::{common::Role, db::User},
  modules::user::UserRepository,
};

static DB: OnceCell<Database> = OnceCell::new();

fn db_data_init(config: &TmsConfig) -> Result<()> {
  log::info!("Initializing DB Data");

  // Create Users
  let mut users = User::get_by_username("admin")?;
  if users.is_empty() {
    log::info!("Creating Admin user");
    let admin = User {
      username: "admin".to_string(),
      password: config.admin_password.clone(),
      roles: vec![Role::Admin as i32],
    };

    User::add(&admin)?;
  } else {
    // Update admin user password
    log::info!("Updating Admin password");
    let Some((id, user)) = users.iter_mut().next() else {
      return Err(anyhow::anyhow!("Failed to get admin user"));
    };
    user.password.clone_from(&config.admin_password);
    User::update(id, user)?;
  }

  Ok(())
}

pub fn init_db(config: &TmsConfig) -> Result<()> {
  // check if DB is already set
  if DB.get().is_some() {
    log::warn!("DB already initialized");
  } else {
    log::info!("Initializing DB");
    let db = Database::new(config.db_path.clone())?;
    DB.set(db).map_err(|_| anyhow::anyhow!("Failed to set DB"))?;
  }

  match db_data_init(config) {
    Ok(()) => log::info!("DB data initialized"),
    Err(e) => log::error!("Failed to initialize DB data: {}", e),
  }

  Ok(())
}

pub fn get_db() -> Result<&'static Database> {
  DB.get().ok_or_else(|| {
    log::error!("DB not initialized");
    anyhow::anyhow!("Database connection not available")
  })
}

pub fn get_tonic_db() -> Result<&'static Database, Status> {
  DB.get().ok_or_else(|| {
    log::error!("DB not initialized");
    Status::internal("Database connection not available")
  })
}
