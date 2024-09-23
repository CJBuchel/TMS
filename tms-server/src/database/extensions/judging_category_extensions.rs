
use tms_infra::TmsCategory;
pub use echo_tree_rs::core::*;
use tms_infra::*;
use uuid::Uuid;

use crate::database::{Database, JUDGING_CATEGORIES};

#[async_trait::async_trait]
pub trait JudgingCategoryExtensions {
  async fn insert_judging_category(&self, category: TmsCategory, judging_cat_id: Option<String>) -> Result<(), String>;
  async fn get_judging_category(&self, judging_cat_id: String) -> Option<TmsCategory>;
  async fn remove_judging_category(&self, judging_cat_id: String) -> Result<(), String>;
}

#[async_trait::async_trait]
impl JudgingCategoryExtensions for Database {
  async fn insert_judging_category(&self, category: TmsCategory, judging_cat_id: Option<String>) -> Result<(), String> {
    // check if judging category already exists (using id if provided, otherwise using number)
    let existing_judging_category: Option<(String, TmsCategory)> = match judging_cat_id {
      Some(judging_cat_id) => self.get_judging_category(judging_cat_id.clone()).await.map(|judging_cat| (judging_cat_id, judging_cat)),
      None => None,
    };

    match existing_judging_category {
      Some((cat_id, _)) => {
        log::warn!("Judging category already exists: {}, overwriting with insert...", cat_id);
        self.inner.write().await.insert_entry(JUDGING_CATEGORIES.to_string(), cat_id.clone(), category.to_json_string()).await;
      }
      None => {
        self.inner.write().await.insert_entry(JUDGING_CATEGORIES.to_string(), Uuid::new_v4().to_string(), category.to_json_string()).await;
      }
    }

    Ok(())
  }

  async fn get_judging_category(&self, judging_cat_id: String) -> Option<TmsCategory> {
    let tree = self.inner.read().await.get_tree(JUDGING_CATEGORIES.to_string()).await;
    let category = tree.get(&judging_cat_id).cloned();

    match category {
      Some(category) => Some(TmsCategory::from_json_string(&category)),
      None => None,
    }
  }

  async fn remove_judging_category(&self, judging_cat_id: String) -> Result<(), String> {
    self.inner.write().await.remove_entry(JUDGING_CATEGORIES.to_string(), judging_cat_id).await;
    Ok(())
  }
}