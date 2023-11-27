use log::{warn, error};

use serde::{Serialize, Deserialize, de::DeserializeOwned};
use sled_extensions::{bincode::Tree, DbExt, Db};
use tms_utils::schemas::{Team, GameMatch, JudgingSession, User, Event, create_user, APILink};

use super::item::Item;

#[derive(Deserialize, Serialize, Clone)]
pub struct SystemInfo {
  pub version: String,
  pub last_backup: Option<u64>,
}

#[derive(Clone)]
pub struct Database {
  pub teams: Tree<Team>,
  pub matches: Tree<GameMatch>,
  pub judging_sessions: Tree<JudgingSession>,
  pub users: Tree<User>,
  pub api_link: Item<APILink>,
  pub event: Item<Event>, // there is only one event, so make it singular (optional just in case of data flow problems)
  pub system_info: Item<SystemInfo>
}

pub trait RequestDatabase {
  type Data: Clone + Serialize + DeserializeOwned;
  type Error;
}

// #[derive(Clone)]
pub struct TmsDB {
  pub db_path: String,
  db: tokio::sync::RwLock<Db>,
  tms_data: tokio::sync::RwLock<Database>
}

pub type TmsDBArc = std::sync::Arc<TmsDB>;

impl TmsDB {
  fn new_db(db_path: String) -> Db {
    // sled db
    let db = sled_extensions::Config::default()
      .path(db_path.clone())
      .open()
      .expect("Failed to open TSM Database");

    db
  }

  fn new_tms_data(db: &Db) -> Database {
    // database data
    let tms_data = Database {
      teams: db.open_bincode_tree("teams").expect("Failed to open team tree"),
      matches: db.open_bincode_tree("matches").expect("Failed to open match tree"),
      judging_sessions: db.open_bincode_tree("judging_sessions").expect("Failed to open judging session tree"),
      users: db.open_bincode_tree("users").expect("Failed to open user tree"),
      api_link: Item::new(db.clone(), "api_link"),
      event: Item::new(db.clone(), "event"),
      system_info: Item::new(db.clone(), "system_info")
    };

    tms_data
  }

  pub fn new(db_path: String) -> TmsDB {
    // sled db
    let db = Self::new_db(db_path.clone());
    let tms_data = Self::new_tms_data(&db);
    // return
    Self { 
      db: tokio::sync::RwLock::new(db), 
      tms_data: tokio::sync::RwLock::new(tms_data), 
      db_path
    }
  }

  // setup data structures and populate with initial data if need be
  pub async fn setup_database(&self) {
    match self.tms_data.read().await.system_info.get().unwrap() {
      Some(info) => {
        if info.version != std::env::var("VERSION").unwrap_or(String::from("0.0.0")) {
          error!("Version Mismatch: {} != {}, this may cause issues", info.version, std::env::var("VERSION").unwrap_or(String::from("0.0.0")));
        }
      },
      None => {
        warn!("No System Info, generating...");
        let _ = self.tms_data.read().await.system_info.set(SystemInfo {
          version: std::env::var("VERSION").unwrap_or(String::from("0.0.0")),
          last_backup: None
        });
      }
    }

    // Create event if it doesn't exist
    match self.tms_data.read().await.event.get().unwrap() {
      Some(event) => warn!("Event Exists: {}", event.name),
      None => {
        warn!("No Event, generating...");
        let _ = self.tms_data.read().await.event.set(Event::new());
      }
    }

    // Create admin user
    let mut new_admin = create_user();
    new_admin.username = String::from("admin");
    new_admin.password = String::from("password");
    new_admin.permissions.admin = true;

    // Check if admin is present, if not add one
    match self.tms_data.read().await.users.get(String::from("admin")).unwrap() {
      Some(user) => warn!("Admin Exists: [{}, {}]", user.username, user.password),
      None => {
        warn!("No Admin, generating...");
        let _ = self.tms_data.read().await.users.insert(new_admin.username.as_bytes(), new_admin.clone());
      }
    }
  }

  pub async fn flush(&self) {
    self.db.read().await.flush().expect("Failed to flush database");
  }

  // Start the db and return the object
  pub async fn start(&self) {
    // Create db
    warn!("Starting TMS Database");
    self.flush().await;
    self.setup_database().await;
  }

  // reload the database
  pub async fn reload(&self) -> Result<(), String> {
    // flush and close
    self.flush().await;

    // replace with new db
    let db = Self::new_db(self.db_path.clone());
    let tms_data = Self::new_tms_data(&db);

    // replace
    *self.db.write().await = db;
    *self.tms_data.write().await = tms_data;
    
    // setup and reinitialize
    self.setup_database().await;

    Ok(())
  }

  pub async fn purge(&self) {
    let guard = self.tms_data.read().await;
    let _ = guard.teams.clear();
    let _ = guard.matches.clear();
    let _ = guard.judging_sessions.clear();
    let _ = guard.users.clear();
    let _ = guard.event.clear();
    let _ = guard.api_link.clear();
  }

  pub async fn get_data(&self) -> tokio::sync::RwLockReadGuard<'_, Database> {
    self.tms_data.read().await
  }
}