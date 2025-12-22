use std::collections::HashMap;

use anyhow::Result;
use database::DataInsert;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::User,
};

const USER_TABLE_NAME: &str = "users";

pub trait UserRepository {
  fn add(record: &User) -> Result<(String, User)>;
  fn update(id: &str, record: &User) -> Result<()>;
  fn remove(id: &str) -> Result<()>;
  fn get(id: &str) -> Result<Option<User>>;
  fn get_all() -> Result<HashMap<String, User>>;
  fn get_by_username(username: &str) -> Result<HashMap<String, User>>;
  fn clear() -> Result<()>;
}

impl UserRepository for User {
  fn add(record: &User) -> Result<(String, User)> {
    let db = get_db()?;
    let table = db.get_table(USER_TABLE_NAME);
    let data = DataInsert {
      id: None,
      value: record.clone(),
      search_indexes: vec![record.username.clone()],
    };

    let id = table.insert(data)?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent {
      operation: ChangeOperation::Create,
      id: id.clone(),
      data: Some(record.clone()),
    })?;

    Ok((id, record.clone()))
  }

  fn update(id: &str, record: &User) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(USER_TABLE_NAME);
    let data = DataInsert {
      id: Some(id.to_string()),
      value: record.clone(),
      search_indexes: vec![record.username.clone()],
    };

    table.insert(data)?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent {
      operation: ChangeOperation::Update,
      id: id.to_string(),
      data: Some(record.clone()),
    })?;

    Ok(())
  }

  fn remove(id: &str) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(USER_TABLE_NAME);
    table.remove(id)?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<User> {
      operation: ChangeOperation::Delete,
      id: id.to_string(),
      data: None,
    })?;

    Ok(())
  }

  fn get(id: &str) -> Result<Option<User>> {
    let db = get_db()?;
    let table = db.get_table(USER_TABLE_NAME);
    table.get(id)
  }

  fn get_all() -> Result<HashMap<String, User>> {
    let db = get_db()?;
    let table = db.get_table(USER_TABLE_NAME);
    table.get_all()
  }

  fn get_by_username(username: &str) -> Result<HashMap<String, User>> {
    let db = get_db()?;
    let table = db.get_table(USER_TABLE_NAME);
    table.get_by_search_indexes(vec![username.to_string()])
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(USER_TABLE_NAME);
    table.clear()
  }
}
