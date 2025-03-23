use std::collections::HashMap;

use anyhow::Result;

use crate::core::db::DB;

use super::model::Team;

pub trait TeamRepository {
  async fn add(record: Team) -> Result<(String, Team)>;
  async fn get(key: &String) -> Result<Team>;
  async fn get_all() -> Result<HashMap<String, Team>>;
}

impl TeamRepository for Team {
  async fn add(record: Team) -> Result<(String, Team)> {
    let db = match DB.get() {
      Some(db) => db,
      None => {
        log::warn!("DB not initialized");
        return Err(anyhow::anyhow!("DB not initialized"));
      }
    };

    let table = db.get_table::<Team>().await?;
    let key = table.insert(None, &record)?;

    Ok((key, record))
  }

  async fn get(key: &String) -> Result<Team> {
    let db = match DB.get() {
      Some(db) => db,
      None => {
        log::warn!("DB not initialized");
        return Err(anyhow::anyhow!("DB not initialized"));
      }
    };

    let table = db.get_table::<Team>().await?;
    let record = table.get(key)?;

    let record = match record {
      Some(record) => record,
      None => {
        log::warn!("Record not found");
        Team::default()
      }
    };

    Ok(record)
  }

  async fn get_all() -> Result<HashMap<String, Team>> {
    let db = match DB.get() {
      Some(db) => db,
      None => {
        log::warn!("DB not initialized");
        return Err(anyhow::anyhow!("DB not initialized"));
      }
    };

    let table = db.get_table::<Team>().await?;
    let records = table.get_all()?;
    Ok(records)
  }
}
