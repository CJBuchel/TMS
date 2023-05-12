use log::warn;

use serde::{Serialize, de::DeserializeOwned};
use sled_extensions::{bincode::Tree, DbExt, Db};
use tms_utils::schemas::{Team, GameMatch, JudgingSession, User, Event, create_user};

#[derive(Clone)]
pub struct Database {
  pub teams: Tree<Team>,
  pub matches: Tree<GameMatch>,
  pub judging_sessions: Tree<JudgingSession>,
  pub users: Tree<User>,
  pub event: Tree<Event>
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

impl TmsDB {
  // Start the db and return the object
  pub fn start(db_path: String) -> Self {
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
      event: db.open_bincode_tree("events").expect("Failed to open event tree")
    };

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

    Self { db, tms_data}
  } 
}