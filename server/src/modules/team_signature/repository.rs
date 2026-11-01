use anyhow::Result;
use database::DataInsert;

use crate::{
  core::{db::get_db, events::ChangeEvent},
  generated::db::TeamSignature,
};

const TEAM_SIGNATURE_TABLE_NAME: &str = "team_signatures";

/// Signatures are keyed by match + table so a team re-signing replaces its previous signature.
pub fn signature_key(match_id: &str, table_id: &str) -> String {
  format!("{}:{}", match_id, table_id)
}

pub trait TeamSignatureRepository {
  fn set(record: &TeamSignature) -> Result<()>;
  fn get(match_id: &str, table_id: &str) -> Result<Option<TeamSignature>>;
  fn clear() -> Result<()>;
}

impl TeamSignatureRepository for TeamSignature {
  fn set(record: &TeamSignature) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(TEAM_SIGNATURE_TABLE_NAME);
    let data = DataInsert {
      id: Some(signature_key(&record.match_id, &record.table_id)),
      value: record.clone(),
      search_indexes: vec![],
    };
    table.insert(data)?;
    Ok(())
  }

  fn get(match_id: &str, table_id: &str) -> Result<Option<TeamSignature>> {
    let db = get_db()?;
    let table = db.get_table(TEAM_SIGNATURE_TABLE_NAME);
    table.get::<TeamSignature>(&signature_key(match_id, table_id))
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(TEAM_SIGNATURE_TABLE_NAME);
    table.clear()?;

    if let Some(event_bus) = crate::core::events::EVENT_BUS.get() {
      event_bus.publish(ChangeEvent::<TeamSignature>::Table)?;
    }
    Ok(())
  }
}
