

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

#[derive(Clone)]
pub struct TmsDB {
  pub db: Db,
  pub tms_data: Database
}

pub type TmsDBArc = std::sync::Arc<std::sync::RwLock<TmsDB>>; // specifically just to update the from the backup thread (doesn't technically need this)

impl TmsDB {
  // Start the db and return the object
  pub fn start(db_path: String) -> TmsDBArc {
    // Create db
    let db = sled_extensions::Config::default()
      .path(db_path)
      .open()
      .expect("Failed to open TSM Database");
  

    // Setup
    let tms_data = Database {
      teams: db.open_bincode_tree("teams").expect("Failed to open team tree"),
      matches: db.open_bincode_tree("matches").expect("Failed to open match tree"),
      judging_sessions: db.open_bincode_tree("judging_sessions").expect("Failed to open judging session tree"),
      users: db.open_bincode_tree("users").expect("Failed to open user tree"),
      api_link: Item::new(db.clone(), "api_link"),
      event: Item::new(db.clone(), "event"),
      system_info: Item::new(db.clone(), "system_info")
    };

    match tms_data.system_info.get().unwrap() {
      Some(info) => {
        if info.version != std::env::var("VERSION").unwrap_or(String::from("0.0.0")) {
          error!("Version Mismatch: {} != {}, this may causes issues", info.version, std::env::var("VERSION").unwrap_or(String::from("0.0.0")));
        }
      },
      None => {
        warn!("No System Info, generating...");
        let _ = tms_data.system_info.set(SystemInfo {
          version: std::env::var("VERSION").unwrap_or(String::from("0.0.0")),
          last_backup: None
        });
      }
    }

    // Create event if it doesn't exist
    match tms_data.event.get().unwrap() {
      Some(event) => warn!("Event Exists: {}", event.name),
      None => {
        warn!("No Event, generating...");
        let _ = tms_data.event.set(Event::new());
      }
    }

    // Create admin user
    let mut new_admin = create_user();
    new_admin.username = String::from("admin");
    new_admin.password = String::from("password");
    new_admin.permissions.admin = true;

    // Check if admin is present, if not add one
    match tms_data.users.get(String::from("admin")).unwrap() {
      Some(user) => warn!("Admin Exists: [{}, {}]", user.username, user.password),
      None => {
        warn!("No Admin, generating...");
        let _ = tms_data.users.insert(new_admin.username.as_bytes(), new_admin.clone());
      }
    }

    let db = Self { db, tms_data};
    return std::sync::Arc::new(std::sync::RwLock::new(db));
  }

  pub fn flush(&self) {
    self.db.flush().expect("Failed to flush database");
  }

  pub fn setup_default(&self) {
    // Setup
    let tms_data = Database {
      teams: self.db.open_bincode_tree("teams").expect("Failed to open team tree"),
      matches: self.db.open_bincode_tree("matches").expect("Failed to open match tree"),
      judging_sessions: self.db.open_bincode_tree("judging_sessions").expect("Failed to open judging session tree"),
      users: self.db.open_bincode_tree("users").expect("Failed to open user tree"),
      event: Item::new(self.db.clone(), "event"),
      api_link: Item::new(self.db.clone(), "api_link"),

      // this shouldn't be purged. (I think... don't remember)
      system_info: Item::new(self.db.clone(), "system_info")
    };

    match tms_data.system_info.get().unwrap() {
      Some(info) => {
        if info.version != std::env::var("VERSION").unwrap_or(String::from("0.0.0")) {
          error!("Version Mismatch: {} != {}, this may cause issues", info.version, std::env::var("VERSION").unwrap_or(String::from("0.0.0")));
        }
      },
      None => {
        warn!("No System Info, generating...");
        let _ = tms_data.system_info.set(SystemInfo {
          version: std::env::var("VERSION").unwrap_or(String::from("0.0.0")),
          last_backup: None
        });
      }
    }

    // Create event if it doesn't exist
    match tms_data.event.get().unwrap() {
      Some(event) => warn!("Event Exists: {}", event.name),
      None => {
        warn!("No Event, generating...");
        let _ = tms_data.event.set(Event::new());
      }
    }

    // Create admin user
    let mut new_admin = create_user();
    new_admin.username = String::from("admin");
    new_admin.password = String::from("password");
    new_admin.permissions.admin = true;

    // Check if admin is present, if not add one
    match tms_data.users.get(String::from("admin")).unwrap() {
      Some(user) => warn!("Admin Exists: [{}, {}]", user.username, user.password),
      None => {
        warn!("No Admin, generating...");
        let _ = tms_data.users.insert(new_admin.username.as_bytes(), new_admin.clone());
      }
    }
  }

  pub fn purge(&self) -> sled_extensions::Result<()> {
    self.tms_data.teams.clear()
      .and_then(|_| self.tms_data.matches.clear())
      .and_then(|_| self.tms_data.judging_sessions.clear())
      .and_then(|_| self.tms_data.users.clear())
      .and_then(|_| self.tms_data.event.clear())
      .and_then(|_| self.tms_data.api_link.clear())
  }
}