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

/// Default admin password used when no password is specified
pub const DEFAULT_ADMIN_USERNAME: &str = "admin";
pub const DEFAULT_ADMIN_PASSWORD: &str = "admin";

/// Recreate the admin user with the default password
/// This is used when resetting the system (e.g., tournament deletion)
pub fn recreate_default_admin() -> Result<()> {
  log::info!("Recreating admin user with default password");

  let admin = User {
    username: "admin".to_string(),
    password: DEFAULT_ADMIN_PASSWORD.to_string(),
    roles: vec![Role::Admin as i32],
  };

  User::add(&admin)?;
  Ok(())
}

fn db_data_init(config: &TmsConfig) -> Result<()> {
  log::info!("Initializing DB Data");

  // Create or update admin user
  let mut users = User::get_by_username("admin")?;
  if users.is_empty() {
    // No admin user exists - create one
    let password = config.admin_password.as_deref().unwrap_or(DEFAULT_ADMIN_PASSWORD);

    log::info!(
      "Creating Admin user with {} password",
      if config.admin_password.is_some() { "provided" } else { "default" }
    );

    let admin = User { username: "admin".to_string(), password: password.to_string(), roles: vec![Role::Admin as i32] };

    User::add(&admin)?;
  } else if let Some(new_password) = &config.admin_password {
    // Admin user exists and a password was explicitly provided - update it
    log::info!("Updating Admin password to provided value");
    let Some((id, user)) = users.iter_mut().next() else {
      return Err(anyhow::anyhow!("Failed to get admin user"));
    };
    user.password.clone_from(new_password);
    User::update(id, user)?;
  } else {
    // Admin user exists but no password provided - leave existing password unchanged
    log::info!("Admin user exists, keeping existing password");
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
