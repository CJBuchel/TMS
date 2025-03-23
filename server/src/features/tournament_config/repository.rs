use anyhow::Result;

use crate::core::db::DB;

use super::model::TournamentConfig;

const CONFIG_KEY: &str = "config";

pub trait TournamentConfigRepository {
  async fn update(record: TournamentConfig) -> Result<TournamentConfig>;
  async fn get() -> Result<TournamentConfig>;
}

impl TournamentConfigRepository for TournamentConfig {
  async fn update(record: TournamentConfig) -> Result<TournamentConfig> {
    let db = match DB.get() {
      Some(db) => db,
      None => {
        log::warn!("DB not initialized");
        return Err(anyhow::anyhow!("DB not initialized"));
      }
    };

    let table = db.get_table::<TournamentConfig>().await?;
    table.insert(Some(&CONFIG_KEY.to_string()), &record)?;

    Ok(record)
  }

  async fn get() -> Result<TournamentConfig> {
    let db = match DB.get() {
      Some(db) => db,
      None => {
        log::warn!("DB not initialized");
        return Err(anyhow::anyhow!("DB not initialized"));
      }
    };

    let table = db.get_table::<TournamentConfig>().await?;
    let record = table.get(&CONFIG_KEY.to_string())?;

    let record = match record {
      Some(record) => record,
      None => {
        log::warn!("Config not found, creating default...");
        let config = TournamentConfig::default();
        table.insert(Some(&CONFIG_KEY.to_string()), &config)?;
        config
      }
    };

    Ok(record)
  }
}
