use sled_extensions::{bincode::Tree, DbExt, Db};

use crate::schemas::*;

#[derive(Clone)]
pub struct Database {
  teams: Tree<Team>,
  matches: Tree<GameMatch>,
  judging_sessions: Tree<JudgingSession>,
  users: Tree<User>,
  event: Tree<Event>
}

pub struct TmsDB {
  pub db: Db,
  pub tms_data: Database
}

impl TmsDB {

  pub fn start() -> Self {
    // Create db
    let db = sled_extensions::Config::default()
      .path("tms.kvdb")
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

    Self { db: db, tms_data: tms_data }
  }
}