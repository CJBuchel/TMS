use super::MatchService;


#[async_trait::async_trait]
pub trait GameMatchSubServer {
  async fn clear_loaded_game_matches(&self);
  async fn add_loaded_game_matches(&self, game_match_number: Vec<String>);
  async fn get_loaded_game_matches(&self) -> Vec<String>;
}

#[async_trait::async_trait]
impl GameMatchSubServer for MatchService {
  async fn clear_loaded_game_matches(&self) {
    self.loaded_game_matches.write().await.clear();
  }

  async fn add_loaded_game_matches(&self, game_match_number: Vec<String>) {
    let mut loaded_game_matches = self.loaded_game_matches.write().await;
    loaded_game_matches.extend(game_match_number.clone());
  }

  async fn get_loaded_game_matches(&self) -> Vec<String> {
    self.loaded_game_matches.read().await.clone()
  }
}