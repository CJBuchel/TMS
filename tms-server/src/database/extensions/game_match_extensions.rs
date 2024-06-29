pub use echo_tree_rs::core::*;
use tms_infra::*;
use uuid::Uuid;
use crate::database::{Database, ROBOT_GAME_MATCHES};


#[async_trait::async_trait]
pub trait GameMatchExtensions {
  async fn get_game_match(&self, game_match_id: String) -> Option<GameMatch>;
  async fn get_game_match_by_number(&self, number: String) -> Option<(String, GameMatch)>;
  async fn insert_game_match(&self, game_match: GameMatch, game_match_id: Option<String>) -> Result<(), String>;
  async fn remove_game_match(&self, game_match_id: String) -> Result<(), String>;
  async fn set_game_match_complete(&self, game_match_id: String) -> Result<(), String>;
}

#[async_trait::async_trait]
impl GameMatchExtensions for Database {
  async fn get_game_match(&self, game_match_id: String) -> Option<GameMatch> {
    let tree = self.inner.read().await.get_tree(ROBOT_GAME_MATCHES.to_string()).await;
    let game_match = tree.get(&game_match_id).cloned();

    match game_match {
      Some(game_match) => {
        Some(GameMatch::from_json_string(&game_match))
      }
      None => None,
    }
  }

  async fn get_game_match_by_number(&self, number: String) -> Option<(String, GameMatch)> {
    let tree = self.inner.read().await.get_tree(ROBOT_GAME_MATCHES.to_string()).await;
    let game_match = tree.iter().find_map(|(id, game_match)| {
      let game_match = GameMatch::from_json_string(game_match);
      if game_match.match_number == number {
        Some((id.clone(), game_match))
      } else {
        None
      }
    });

    match game_match {
      Some((id, game_match)) => {
        Some((id, game_match))
      }
      None => None,
    }
  }

  async fn insert_game_match(&self, game_match: GameMatch, game_match_id: Option<String>) -> Result<(), String> {
    // check if game_match already exists (using id if provided, otherwise using number)
    let existing_game_match: Option<(String, GameMatch)> = match game_match_id {
      Some(game_match_id) => self.get_game_match(game_match_id.clone()).await.map(|game_match| (game_match_id, game_match)),
      None => self.get_game_match_by_number(game_match.clone().match_number).await,
    };

    match existing_game_match {
      Some((game_match_id, game_match)) => {
        log::warn!("GameMatch already exists: {}, overwriting with insert...", game_match_id);
        self.inner.write().await.insert_entry(ROBOT_GAME_MATCHES.to_string(), game_match_id, game_match.to_json_string()).await;
        Ok(())
      },
      None => {
        self.inner.write().await.insert_entry(ROBOT_GAME_MATCHES.to_string(), Uuid::new_v4().to_string(), game_match.to_json_string()).await;
        Ok(())
      },
    }
  }

  async fn remove_game_match(&self, game_match_id: String) -> Result<(), String> {
    let tree = self.inner.read().await.get_tree(ROBOT_GAME_MATCHES.to_string()).await;
    let game_match = tree.get(&game_match_id).cloned();

    match game_match {
      Some(_) => {
        self.inner.write().await.remove_entry(ROBOT_GAME_MATCHES.to_string(), game_match_id).await;
        Ok(())
      }
      None => {
        Err(format!("GameMatch not found: {}", game_match_id))
      }
    }
  }

  async fn set_game_match_complete(&self, game_match_id: String) -> Result<(), String> {
    let tree = self.inner.read().await.get_tree(ROBOT_GAME_MATCHES.to_string()).await;
    let game_match_str = tree.get(&game_match_id).cloned();

    match game_match_str {
      Some(game_match) => {
        let mut game_match = GameMatch::from_json_string(&game_match);
        game_match.completed = true;
        self.inner.write().await.insert_entry(ROBOT_GAME_MATCHES.to_string(), game_match_id, game_match.to_json_string()).await;
        Ok(())
      }
      None => {
        Err(format!("GameMatch not found: {}", game_match_id))
      }
    }
  }
}