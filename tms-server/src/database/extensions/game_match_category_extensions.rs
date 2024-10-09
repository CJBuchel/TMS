use tms_infra::TmsCategory;
pub use echo_tree_rs::core::*;
use tms_infra::*;
use uuid::Uuid;

use crate::database::{Database, ROBOT_GAME_CATEGORIES};

#[async_trait::async_trait]
pub trait GameMatchCategoryExtensions {
  async fn insert_game_match_category(&self, category: TmsCategory, game_match_cat_id: Option<String>) -> Result<(), String>;
  async fn get_game_match_category(&self, game_match_cat_id: String) -> Option<TmsCategory>;
  async fn remove_game_match_category(&self, game_match_cat_id: String) -> Result<(), String>;
}

#[async_trait::async_trait]
impl GameMatchCategoryExtensions for Database {
  async fn insert_game_match_category(&self, category: TmsCategory, game_match_cat_id: Option<String>) -> Result<(), String> {
    // check if game_match already exists (using id if provided, otherwise using number)
    let existing_game_match_category: Option<(String, TmsCategory)> = match game_match_cat_id {
      Some(game_match_cat_id) => self.get_game_match_category(game_match_cat_id.clone()).await.map(|game_match_cat| (game_match_cat_id, game_match_cat)),
      None => None,
    };

    match existing_game_match_category {
      Some((cat_id, _)) => {
        log::warn!("GameMatch category already exists: {}, overwriting with insert...", cat_id);
        self.inner.write().await.insert_entry(ROBOT_GAME_CATEGORIES.to_string(), cat_id.clone(), category.to_json_string()).await;
        Ok(())
      }
      None => {
        self.inner.write().await.insert_entry(ROBOT_GAME_CATEGORIES.to_string(), Uuid::new_v4().to_string(), category.to_json_string()).await;
        Ok(())
      }
    }
  }

  async fn get_game_match_category(&self, game_match_cat_id: String) -> Option<TmsCategory> {
    let tree = self.inner.read().await.get_tree(ROBOT_GAME_CATEGORIES.to_string()).await;
    let category = tree.get(&game_match_cat_id).cloned();

    match category {
      Some(category) => Some(TmsCategory::from_json_string(&category)),
      None => None,
    }
  }

  async fn remove_game_match_category(&self, game_match_cat_id: String) -> Result<(), String> {
    self.inner.write().await.remove_entry(ROBOT_GAME_CATEGORIES.to_string(), game_match_cat_id).await;
    Ok(())
  }
}