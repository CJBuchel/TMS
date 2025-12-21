use anyhow::Result;
use database::DataInsert;
use std::collections::HashMap;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::JudgingSession,
};

const JUDGING_SESSION_TABLE_NAME: &str = "judging_sessions";

pub trait JudgingSessionRepository {
  fn add(record: &JudgingSession) -> Result<(String, JudgingSession)>;
  fn get_by_session_number(session_number: &str) -> Result<HashMap<String, JudgingSession>>;
}

impl JudgingSessionRepository for JudgingSession {
  fn add(record: &JudgingSession) -> Result<(String, JudgingSession)> {
    let db = get_db()?;
    let table = db.get_table(JUDGING_SESSION_TABLE_NAME);
    let data = DataInsert {
      id: None,
      value: record.clone(),
      search_indexes: vec![record.session_number.clone()],
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

  fn get_by_session_number(session_number: &str) -> Result<HashMap<String, JudgingSession>> {
    let db = get_db()?;
    let table = db.get_table(JUDGING_SESSION_TABLE_NAME);

    let sessions = table.get_by_search_indexes::<JudgingSession>(vec![session_number.to_string()])?;

    // filter for exact session number
    let sessions: HashMap<String, JudgingSession> = sessions
      .into_iter()
      .filter(|(_, session)| session.session_number == session_number)
      .collect();

    Ok(sessions)
  }
}
