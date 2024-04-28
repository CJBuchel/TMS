use crate::database::{Database, TOURNAMENT_CONFIG};
pub use echo_tree_rs::core::*;
use tms_infra::{DataSchemeExtensions, TournamentConfig};

#[async_trait::async_trait]
pub trait TournamentConfigExtensions {
  async fn get_tournament_name(&self) -> Option<String>;
  async fn set_tournament_name(&mut self, name: String);
}

#[async_trait::async_trait]
impl TournamentConfigExtensions for Database {

  async fn get_tournament_name(&self) -> Option<String> {
    let config = self.inner.read().await.get_tree(TOURNAMENT_CONFIG.to_string()).await.get("config").cloned();
    match config {
      Some(config) => {
        let config = TournamentConfig::from_json(&config);
        Some(config.name)
      },
      None => None
    }
  }

  async fn set_tournament_name(&mut self, name: String) {
    let existing_config = self.inner.read().await.get_tree(TOURNAMENT_CONFIG.to_string()).await.get("config").cloned();
    match existing_config {
      Some(config) => {
        let mut config = TournamentConfig::from_json(&config);
        config.name = name;
        self.inner.write().await.insert_entry(TOURNAMENT_CONFIG.to_string(), "config".to_string(), config.to_json()).await;
      },
      None => {
        let config = TournamentConfig {
          name,
          ..Default::default()
        };
        self.inner.write().await.insert_entry(TOURNAMENT_CONFIG.to_string(), "config".to_string(), config.to_json()).await;
      }
    }
  }
}