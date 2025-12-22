use anyhow::Result;
use database::DataInsert;
use std::collections::HashMap;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::PodName,
};

const POD_TABLE_NAME: &str = "pod_names";

pub trait PodRepository {
  fn add(record: &PodName) -> Result<(String, PodName)>;
  fn get_by_name(pod_name: &str) -> Result<HashMap<String, PodName>>;
  fn clear() -> Result<()>;
}

impl PodRepository for PodName {
  fn add(record: &PodName) -> Result<(String, PodName)> {
    let db = get_db()?;
    let table = db.get_table(POD_TABLE_NAME);
    let data = DataInsert {
      id: None,
      value: record.clone(),
      search_indexes: vec![record.pod_name.clone()],
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

  fn get_by_name(pod_name: &str) -> Result<HashMap<String, PodName>> {
    let db = get_db()?;
    let table = db.get_table(POD_TABLE_NAME);

    let pods = table.get_by_search_indexes::<PodName>(vec![pod_name.to_string()])?;

    // filter for exact pod name
    let pods: HashMap<String, PodName> = pods.into_iter().filter(|(_, pod)| pod.pod_name == pod_name).collect();

    Ok(pods)
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(POD_TABLE_NAME);
    table.clear()
  }
}
