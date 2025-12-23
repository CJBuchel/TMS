use anyhow::Result;
use database::DataInsert;
use std::collections::HashMap;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::GameMatch,
};

pub const GAME_MATCH_TABLE_NAME: &str = "matches";

pub trait GameMatchRepository {
  fn add(record: &GameMatch) -> Result<(String, GameMatch)>;
  fn get(id: &str) -> Result<Option<GameMatch>>;
  fn get_all() -> Result<HashMap<String, GameMatch>>;
  fn get_by_match_number(match_number: &str) -> Result<HashMap<String, GameMatch>>;
  fn clear() -> Result<()>;
}

impl GameMatchRepository for GameMatch {
  fn add(record: &GameMatch) -> Result<(String, GameMatch)> {
    let db = get_db()?;
    let table = db.get_table(GAME_MATCH_TABLE_NAME);
    let data = DataInsert { id: None, value: record.clone(), search_indexes: vec![record.match_number.clone()] };

    let id = table.insert(data)?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::Record {
      operation: ChangeOperation::Create,
      id: id.clone(),
      data: Some(record.clone()),
    })?;

    Ok((id, record.clone()))
  }

  fn get(id: &str) -> Result<Option<GameMatch>> {
    let db = get_db()?;
    let table = db.get_table(GAME_MATCH_TABLE_NAME);
    let game_match = table.get::<GameMatch>(id)?;
    Ok(game_match)
  }

  fn get_all() -> Result<HashMap<String, GameMatch>> {
    let db = get_db()?;
    let table = db.get_table(GAME_MATCH_TABLE_NAME);
    let matches = table.get_all::<GameMatch>()?;
    Ok(matches)
  }

  fn get_by_match_number(match_number: &str) -> Result<HashMap<String, GameMatch>> {
    let db = get_db()?;
    let table = db.get_table(GAME_MATCH_TABLE_NAME);

    let matches = table.get_by_search_indexes::<GameMatch>(vec![match_number.to_string()])?;

    // filter for exact match number
    let matches: HashMap<String, GameMatch> =
      matches.into_iter().filter(|(_, game_match)| game_match.match_number == match_number).collect();

    Ok(matches)
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(GAME_MATCH_TABLE_NAME);
    table.clear()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<GameMatch>::Table)?;

    Ok(())
  }
}
