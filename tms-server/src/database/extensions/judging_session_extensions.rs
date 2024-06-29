use tms_infra::*;

pub use echo_tree_rs::core::*;
use uuid::Uuid;
use crate::database::{Database, JUDGING_SESSIONS};

#[async_trait::async_trait]
pub trait JudgingSessionExtensions {
  async fn get_judging_session(&self, judging_session_id: String) -> Option<JudgingSession>;
  async fn get_judging_session_by_number(&self, number: String) -> Option<(String, JudgingSession)>;
  async fn insert_judging_session(&self, judging_session: JudgingSession, judging_session_id: Option<String>) -> Result<(), String>;
  async fn remove_judging_session(&self, judging_session_id: String) -> Result<(), String>;
}

#[async_trait::async_trait]
impl JudgingSessionExtensions for Database {
  async fn get_judging_session(&self, judging_session_id: String) -> Option<JudgingSession> {
    let tree = self.inner.read().await.get_tree(JUDGING_SESSIONS.to_string()).await;
    let judging_session = tree.get(&judging_session_id).cloned();

    match judging_session {
      Some(judging_session) => {
        Some(JudgingSession::from_json_string(&judging_session))
      }
      None => None,
    }
  }

  async fn get_judging_session_by_number(&self, number: String) -> Option<(String, JudgingSession)> {
    let tree = self.inner.read().await.get_tree(JUDGING_SESSIONS.to_string()).await;
    let judging_session = tree.iter().find_map(|(id, judging_session)| {
      let judging_session = JudgingSession::from_json_string(judging_session);
      if judging_session.session_number == number {
        Some((id.clone(), judging_session))
      } else {
        None
      }
    });

    match judging_session {
      Some((id, judging_session)) => {
        Some((id, judging_session))
      }
      None => None,
    }
  }

  async fn insert_judging_session(&self, judging_session: JudgingSession, judging_session_id: Option<String>) -> Result<(), String> {
    // check if judging_session already exists (using id if provided, otherwise using number)
    let existing_judging_session: Option<(String, JudgingSession)> = match judging_session_id {
      Some(judging_session_id) => self.get_judging_session(judging_session_id.clone()).await.map(|judging_session| (judging_session_id, judging_session)),
      None => self.get_judging_session_by_number(judging_session.clone().session_number).await,
    };

    match existing_judging_session {
      Some((judging_session_id, judging_session)) => {
        log::warn!("JudgingSession already exists: {}, overwriting with insert...", judging_session_id);
        self.inner.write().await.insert_entry(JUDGING_SESSIONS.to_string(), judging_session_id, judging_session.to_json_string()).await;
        Ok(())
      }
      None => {
        self.inner.write().await.insert_entry(JUDGING_SESSIONS.to_string(), Uuid::new_v4().to_string(), judging_session.to_json_string()).await;
        Ok(())
      }
    }
  }

  async fn remove_judging_session(&self, judging_session_id: String) -> Result<(), String> {
    let tree = self.inner.read().await.get_tree(JUDGING_SESSIONS.to_string()).await;
    let judging_session = tree.get(&judging_session_id).cloned();

    match judging_session {
      Some(_) => {
        self.inner.write().await.remove_entry(JUDGING_SESSIONS.to_string(), judging_session_id).await;
        Ok(())
      }
      None => {
        Err("JudgingSession does not exist".to_string())
      }
    }
  }
}