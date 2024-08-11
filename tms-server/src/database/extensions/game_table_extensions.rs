use tms_infra::*;

pub use echo_tree_rs::core::*;
use uuid::Uuid;
use crate::database::{Database, ROBOT_GAME_TABLES};


#[async_trait::async_trait]
pub trait GameTableExtensions {
  async fn get_game_table(&self, game_table_id: String) -> Option<String>;
  async fn get_game_table_by_name(&self, name: String) -> Option<(String, String)>;
  async fn insert_game_table(&self, game_table: String, game_table_id: Option<String>) -> Result<(), String>;
  async fn remove_game_table(&self, game_table_id: String) -> Result<(), String>;
}

#[async_trait::async_trait]
impl GameTableExtensions for Database {
  async fn get_game_table(&self, game_table_id: String) -> Option<String> {
    let tree = self.inner.read().await.get_tree(ROBOT_GAME_TABLES.to_string()).await;
    let game_table = tree.get(&game_table_id).cloned();

    match game_table {
      Some(game_table) => {
        Some(GameTable::from_json_string(&game_table).table_name)
      }
      None => None,
    }
  }

  async fn get_game_table_by_name(&self, name: String) -> Option<(String, String)> {
    let tree = self.inner.read().await.get_tree(ROBOT_GAME_TABLES.to_string()).await;
    let game_table = tree.iter().find_map(|(id, game_table)| {
      let game_table = GameTable::from_json_string(game_table);
      if game_table.table_name == name {
        Some((id.clone(), game_table))
      } else {
        None
      }
    });

    match game_table {
      Some((id, game_table)) => {
        Some((id, game_table.table_name))
      }
      None => None,
    }
  }

  async fn insert_game_table(&self, game_table: String, game_table_id: Option<String>) -> Result<(), String> {
    // check if game_table already exists (using id if provided, otherwise using name)
    let existing_game_table: Option<(String, String)> = match game_table_id {
      Some(game_table_id) => self.get_game_table(game_table_id.clone()).await.map(|game_table| (game_table_id, game_table)),
      None => self.get_game_table_by_name(game_table.clone()).await,
    };

    match existing_game_table {
      Some((game_table_id, _)) => {
        log::warn!("GameTable already exists: {}, overwriting with insert...", game_table_id);
        let game_table = GameTable {
          table_name: game_table,
        };
        self.inner.write().await.insert_entry(ROBOT_GAME_TABLES.to_string(), game_table_id, game_table.to_json_string()).await;
        Ok(())
      }
      None => {
        let game_table = GameTable {
          table_name: game_table,
        };
        self.inner.write().await.insert_entry(ROBOT_GAME_TABLES.to_string(), Uuid::new_v4().to_string(), game_table.to_json_string()).await;
        Ok(())
      }
    }
  }

  async fn remove_game_table(&self, game_table_id: String) -> Result<(), String> {
    let tree = self.inner.read().await.get_tree(ROBOT_GAME_TABLES.to_string()).await;
    let game_table = tree.get(&game_table_id).cloned();

    match game_table {
      Some(_) => {
        self.inner.write().await.remove_entry(ROBOT_GAME_TABLES.to_string(), game_table_id).await;
        Ok(())
      }
      None => Err("GameTable not found".to_string()),
    }
  }
}