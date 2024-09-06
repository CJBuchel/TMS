use crate::database::{Database, ROBOT_GAME_SCORES};
pub use echo_tree_rs::core::*;
use tms_infra::*;
use uuid::Uuid;


#[async_trait::async_trait]
pub trait GameScoreSheetExtensions {
  async fn get_game_score_sheet(&self, game_score_sheet_id: String) -> Option<GameScoreSheet>;
  async fn insert_game_score_sheet(&self, game_score_sheet: GameScoreSheet, game_score_sheet_id: Option<String>) -> Result<(), String>;
  async fn remove_game_score_sheet(&self, game_score_sheet_id: String) -> Result<(), String>;
}

#[async_trait::async_trait]
impl GameScoreSheetExtensions for Database {
  async fn get_game_score_sheet(&self, game_score_sheet_id: String) -> Option<GameScoreSheet> {
    let tree = self.inner.read().await.get_tree(ROBOT_GAME_SCORES.to_string()).await;
    let game_score_sheet = tree.get(&game_score_sheet_id).cloned();

    match game_score_sheet {
      Some(game_score_sheet) => Some(GameScoreSheet::from_json_string(&game_score_sheet)),
      None => None,
    }
  }

  async fn insert_game_score_sheet(&self, game_score_sheet: GameScoreSheet, game_score_sheet_id: Option<String>) -> Result<(), String> {
    // check if game_score_sheet already exists (using id if provided, otherwise using number)
    let existing_game_score_sheet: Option<(String, GameScoreSheet)> = match game_score_sheet_id {
      Some(game_score_sheet_id) => self.get_game_score_sheet(game_score_sheet_id.clone()).await.map(|game_score_sheet| (game_score_sheet_id, game_score_sheet)),
      None => None,
    };

    match existing_game_score_sheet {
      Some((game_score_sheet_id, _)) => {
        log::warn!("GameScoreSheet already exists: {}, overwriting with insert...", game_score_sheet_id);
        self.inner.write().await.insert_entry(ROBOT_GAME_SCORES.to_string(), game_score_sheet_id, game_score_sheet.to_json_string()).await;
        Ok(())
      }
      None => {
        self.inner.write().await.insert_entry(ROBOT_GAME_SCORES.to_string(), Uuid::new_v4().to_string(), game_score_sheet.to_json_string()).await;
        Ok(())
      }
    }
  }

  async fn remove_game_score_sheet(&self, game_score_sheet_id: String) -> Result<(), String> {
    let tree = self.inner.read().await.get_tree(ROBOT_GAME_SCORES.to_string()).await;
    let game_score_sheet = tree.get(&game_score_sheet_id).cloned();

    match game_score_sheet {
      Some(_) => {
        self.inner.write().await.remove_entry(ROBOT_GAME_SCORES.to_string(), game_score_sheet_id).await;
        Ok(())
      }
      None => {
        log::warn!("GameScoreSheet does not exist: {}", game_score_sheet_id);
        Err(format!("GameScoreSheet does not exist: {}", game_score_sheet_id))
      }
    }
  }
}