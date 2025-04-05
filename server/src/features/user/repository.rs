use std::collections::HashMap;

use anyhow::Result;

use crate::core::db::DB;

use super::model::User;

pub trait UserRepository {
  async fn add(record: &User) -> Result<(String, User)>;
  async fn remove(key: &String) -> Result<()>;
  async fn get(key: &String) -> Result<Option<User>>;
  async fn get_all() -> Result<HashMap<String, User>>;
  async fn get_by_username(username: &String) -> Result<HashMap<String, User>>;
}

impl UserRepository for User {
  async fn add(record: &User) -> Result<(String, User)> {
    let db = match DB.get() {
      Some(db) => db,
      None => {
        log::warn!("DB not initialized");
        return Err(anyhow::anyhow!("DB not initialized"));
      }
    };

    let table = db.get_table::<User>().await?;
    let key = table.insert(None, record)?;

    Ok((key, record.clone()))
  }

  async fn remove(key: &String) -> Result<()> {
    let db = match DB.get() {
      Some(db) => db,
      None => {
        log::warn!("DB not initialized");
        return Err(anyhow::anyhow!("DB not initialized"));
      }
    };

    let table = db.get_table::<User>().await?;
    table.remove::<User>(&key)?;

    Ok(())
  }

  async fn get(key: &String) -> Result<Option<User>> {
    let db = match DB.get() {
      Some(db) => db,
      None => {
        log::warn!("DB not initialized");
        return Err(anyhow::anyhow!("DB not initialized"));
      }
    };

    let table = db.get_table::<User>().await?;
    let record = table.get(key)?;
    Ok(record)
  }

  async fn get_all() -> Result<HashMap<String, User>> {
    let db = match DB.get() {
      Some(db) => db,
      None => {
        log::warn!("DB not initialized");
        return Err(anyhow::anyhow!("DB not initialized"));
      }
    };

    let table = db.get_table::<User>().await?;
    let records = table.get_all::<User>()?;
    Ok(records)
  }

  async fn get_by_username(username: &String) -> Result<HashMap<String, User>> {
    let db = match DB.get() {
      Some(db) => db,
      None => {
        log::warn!("DB not initialized");
        return Err(anyhow::anyhow!("DB not initialized"));
      }
    };

    let table = db.get_table::<User>().await?;
    let record = table.get_by_index(username)?;
    Ok(record)
  }
}
