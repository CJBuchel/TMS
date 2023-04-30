use std::borrow::Borrow;

use sled_extensions::{bincode::Tree, DbExt, Db};

use crate::schemas::*;

#[derive(Clone)]
pub struct Database {
  pub teams: Tree<Team>,
  pub matches: Tree<GameMatch>,
  pub judging_sessions: Tree<JudgingSession>,
  pub users: Tree<User>,
  pub event: Tree<Event>
}

pub trait AccessDatabase {
  type Data: Clone;
  type Error;
  fn db_get(&self, key: String) -> Result<Self::Data, Self::Error>;
  fn db_set(&self, key: String, data: Self::Data) -> Result<Self::Data, Self::Error>;
  fn db_add(&self, data: Self::Data) -> Result<Self::Data, Self::Error>;
}

#[derive(Clone)]
pub struct TmsDB {
  pub db: Db,
  pub tms_data: Database
}

impl TmsDB {
  // Start the db and return the object
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

  // Get the raw sled database
  pub async fn get_db(&self) -> &Db {
    return &self.db.borrow();
  }

  // Get the tms database
  pub async fn get_tms_data(&self) -> &Database {
    return &self.tms_data.borrow();
  }
}