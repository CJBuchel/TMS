use anyhow::Result;
use database::DataInsert;
use std::collections::HashMap;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::Team,
};

pub const TEAM_TABLE_NAME: &str = "teams";

pub trait TeamRepository {
  fn add(record: &Team) -> Result<(String, Team)>;
  fn get_by_number(team_number: &str) -> Result<HashMap<String, Team>>;
  fn clear() -> Result<()>;
}

impl TeamRepository for Team {
  fn add(record: &Team) -> Result<(String, Team)> {
    let db = get_db()?;
    let table = db.get_table(TEAM_TABLE_NAME);
    let data = DataInsert {
      id: None,
      value: record.clone(),
      search_indexes: vec![record.team_number.clone(), record.name.clone(), record.affiliation.clone()],
    };

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

  fn get_by_number(team_number: &str) -> Result<HashMap<String, Team>> {
    let db = get_db()?;
    let table = db.get_table(TEAM_TABLE_NAME);

    let teams = table.get_by_search_indexes::<Team>(vec![team_number.to_string()])?;

    // filter for exact team number
    let teams: HashMap<String, Team> = teams.into_iter().filter(|(_, team)| team.team_number == team_number).collect();

    Ok(teams)
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(TEAM_TABLE_NAME);
    table.clear()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<Team>::Table)?;

    Ok(())
  }
}
