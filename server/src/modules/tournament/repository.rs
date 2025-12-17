use anyhow::Result;
use database::DataInsert;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::Tournament,
};

const TOURNAMENT_TABLE_NAME: &str = "tournament";
const TOURNAMENT_KEY: &str = "tournament";

pub trait TournamentRepository {
  fn set(record: &Tournament) -> Result<()>;
  fn get() -> Tournament;
}

impl TournamentRepository for Tournament {
  fn set(record: &Tournament) -> Result<()> {
    let db = get_db()?;

    let table = db.get_table(TOURNAMENT_TABLE_NAME);

    let data = DataInsert {
      id: Some(TOURNAMENT_KEY.to_string()),
      value: record.clone(), // Rust infers Tournament from this
      search_indexes: vec![],
    };

    match table.insert(data) {
      Ok(_) => {
        log::info!("Tournament settings updated");
      }
      Err(e) => {
        log::error!("Failed to update tournament");
        return Err(e);
      }
    }

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not available"));
    };

    event_bus.publish(ChangeEvent {
      operation: ChangeOperation::Update,
      id: TOURNAMENT_KEY.to_string(),
      data: Some(record.clone()),
    })?;

    Ok(())
  }

  fn get() -> Tournament {
    let Ok(db) = get_db() else {
      return Tournament::default();
    };

    let table = db.get_table(TOURNAMENT_TABLE_NAME);

    match table.get(TOURNAMENT_KEY) {
      Ok(Some(record)) => record,
      Ok(None) => Tournament::default(),
      Err(e) => {
        log::warn!("Failed to retrieve tournament: {}", e);
        Tournament::default()
      }
    }
  }
}
