use anyhow::Result;
use database::DataInsert;
use rand::Rng;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::{Season, Tournament},
};

const TOURNAMENT_TABLE_NAME: &str = "tournament";
const TOURNAMENT_KEY: &str = "tournament";

fn create_default_tournament() -> Tournament {
  const CHARSET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  let mut rng = rand::rng();

  let event_key: String = (0..10)
    .map(|_| {
      let idx = rng.random_range(0..CHARSET.len());
      CHARSET[idx] as char
    })
    .collect();

  Tournament {
    event_key,
    season: Season::Season2025 as i32,
    ..Default::default()
  }
}

pub trait TournamentRepository {
  fn set(record: &Tournament) -> Result<()>;
  fn get() -> Tournament;
  fn clear() -> Result<()>;
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
      return create_default_tournament();
    };

    let table = db.get_table(TOURNAMENT_TABLE_NAME);

    match table.get(TOURNAMENT_KEY) {
      Ok(Some(record)) => record,
      Ok(None) => create_default_tournament(),
      Err(e) => {
        log::warn!("Failed to retrieve tournament: {}", e);
        create_default_tournament()
      }
    }
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(TOURNAMENT_TABLE_NAME);
    table.clear()
  }
}
