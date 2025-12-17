use std::collections::HashMap;

use anyhow::Result;
use database::DataInsert;

use crate::{core::db::get_db, generated::db::User};

const USER_TABLE_NAME: &str = "users";

pub trait UserRepository {
  fn add(record: &User) -> Result<(String, User)>;
  fn update(id: &str, record: &User) -> Result<()>;
  fn remove(id: &str) -> Result<()>;
  fn get(id: &str) -> Result<Option<User>>;
  fn get_all() -> Result<HashMap<String, User>>;
  fn get_by_username(username: &str) -> Result<HashMap<String, User>>;
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
    Ok(())
  }

  fn remove(id: &str) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(USER_TABLE_NAME);
    table.remove(id)
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
}
