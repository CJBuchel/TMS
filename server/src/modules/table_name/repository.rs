use anyhow::Result;
use database::DataInsert;
use std::collections::HashMap;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::TableName,
};

pub const TABLE_TABLE_NAME: &str = "table_names";

pub trait TableRepository {
  fn add(record: &TableName) -> Result<(String, TableName)>;
  fn get_by_name(table_name: &str) -> Result<HashMap<String, TableName>>;
  fn clear() -> Result<()>;
}

impl TableRepository for TableName {
  fn add(record: &TableName) -> Result<(String, TableName)> {
    let db = get_db()?;
    let table = db.get_table(TABLE_TABLE_NAME);
    let data = DataInsert { id: None, value: record.clone(), search_indexes: vec![record.table_name.clone()] };

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

  fn get_by_name(table_name: &str) -> Result<HashMap<String, TableName>> {
    let db = get_db()?;
    let table = db.get_table(TABLE_TABLE_NAME);

    let tables = table.get_by_search_indexes::<TableName>(vec![table_name.to_string()])?;

    // filter for exact table name
    let tables: HashMap<String, TableName> = tables.into_iter().filter(|(_, t)| t.table_name == table_name).collect();

    Ok(tables)
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(TABLE_TABLE_NAME);
    table.clear()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<TableName>::Table)?;

    Ok(())
  }
}
