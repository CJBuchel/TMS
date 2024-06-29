use crate::database::*;
pub use echo_tree_rs::core::*;
use tms_infra::*;

#[async_trait::async_trait]
pub trait TournamentConfigExtensions {
  async fn get_tournament_name(&self) -> Option<String>;
  async fn set_tournament_name(&mut self, name: String);

  async fn get_tournament_timer_length(&self) -> Option<u32>;
  async fn set_tournament_timer_length(&mut self, timer_length: u32);

  async fn get_tournament_endgame_timer_length(&self) -> Option<u32>;
  async fn set_tournament_endgame_timer_length(&mut self, timer_length: u32);

  async fn get_tournament_season(&self) -> Option<String>;
  async fn set_tournament_season(&mut self, season: String);

  async fn get_tournament_backup_interval(&self) -> Option<u32>;
  async fn set_tournament_backup_interval(&mut self, interval: u32);

  async fn get_tournament_retain_backups(&self) -> Option<u32>;
  async fn set_tournament_retain_backups(&mut self, retain_backups: u32);

  async fn purge(&mut self);
}

#[async_trait::async_trait]
impl TournamentConfigExtensions for Database {

  async fn get_tournament_name(&self) -> Option<String> {
    let config = self.inner.read().await.get_tree(TOURNAMENT_CONFIG.to_string()).await.get("config").cloned();
    match config {
      Some(config) => {
        let config = TournamentConfig::from_json_string(&config);
        Some(config.name)
      },
      None => None
    }
  }

  async fn set_tournament_name(&mut self, name: String) {
    let existing_config = self.inner.read().await.get_tree(TOURNAMENT_CONFIG.to_string()).await.get("config").cloned();
    match existing_config {
      Some(config) => {
        let mut config = TournamentConfig::from_json_string(&config);
        config.name = name;
        self.inner.write().await.insert_entry(TOURNAMENT_CONFIG.to_string(), "config".to_string(), config.to_json_string()).await;
      },
      None => {
        let config = TournamentConfig {
          name,
          ..Default::default()
        };
        self.inner.write().await.insert_entry(TOURNAMENT_CONFIG.to_string(), "config".to_string(), config.to_json_string()).await;
      }
    }
  }

  async fn get_tournament_timer_length(&self) -> Option<u32> {
    let config = self.inner.read().await.get_tree(TOURNAMENT_CONFIG.to_string()).await.get("config").cloned();
    match config {
      Some(config) => {
        let config = TournamentConfig::from_json_string(&config);
        Some(config.timer_length)
      },
      None => None
    }
  }

  async fn set_tournament_timer_length(&mut self, timer_length: u32) {
    let existing_config = self.inner.read().await.get_tree(TOURNAMENT_CONFIG.to_string()).await.get("config").cloned();
    match existing_config {
      Some(config) => {
        let mut config = TournamentConfig::from_json_string(&config);
        config.timer_length = timer_length;
        self.inner.write().await.insert_entry(TOURNAMENT_CONFIG.to_string(), "config".to_string(), config.to_json_string()).await;
      },
      None => {
        let config = TournamentConfig {
          timer_length,
          ..Default::default()
        };
        self.inner.write().await.insert_entry(TOURNAMENT_CONFIG.to_string(), "config".to_string(), config.to_json_string()).await;
      }
    }
  }

  async fn get_tournament_endgame_timer_length(&self) -> Option<u32> {
    let config = self.inner.read().await.get_tree(TOURNAMENT_CONFIG.to_string()).await.get("config").cloned();
    match config {
      Some(config) => {
        let config = TournamentConfig::from_json_string(&config);
        Some(config.end_game_timer_length)
      },
      None => None
    }
  }

  async fn set_tournament_endgame_timer_length(&mut self, timer_length: u32) {
    let existing_config = self.inner.read().await.get_tree(TOURNAMENT_CONFIG.to_string()).await.get("config").cloned();
    match existing_config {
      Some(config) => {
        let mut config = TournamentConfig::from_json_string(&config);
        config.end_game_timer_length = timer_length;
        self.inner.write().await.insert_entry(TOURNAMENT_CONFIG.to_string(), "config".to_string(), config.to_json_string()).await;
      },
      None => {
        let config = TournamentConfig {
          end_game_timer_length: timer_length,
          ..Default::default()
        };
        self.inner.write().await.insert_entry(TOURNAMENT_CONFIG.to_string(), "config".to_string(), config.to_json_string()).await;
      }
    }
  }

  async fn get_tournament_season(&self) -> Option<String> {
    let config = self.inner.read().await.get_tree(TOURNAMENT_CONFIG.to_string()).await.get("config").cloned();
    match config {
      Some(config) => {
        let config = TournamentConfig::from_json_string(&config);
        Some(config.season)
      },
      None => None
    }
  }

  async fn set_tournament_season(&mut self, season: String) {
    let existing_config = self.inner.read().await.get_tree(TOURNAMENT_CONFIG.to_string()).await.get("config").cloned();
    match existing_config {
      Some(config) => {
        let mut config = TournamentConfig::from_json_string(&config);
        config.season = season;
        self.inner.write().await.insert_entry(TOURNAMENT_CONFIG.to_string(), "config".to_string(), config.to_json_string()).await;
      },
      None => {
        let config = TournamentConfig {
          season,
          ..Default::default()
        };
        self.inner.write().await.insert_entry(TOURNAMENT_CONFIG.to_string(), "config".to_string(), config.to_json_string()).await;
      }
    }
  }

  async fn get_tournament_backup_interval(&self) -> Option<u32> {
    let config = self.inner.read().await.get_tree(TOURNAMENT_CONFIG.to_string()).await.get("config").cloned();
    match config {
      Some(config) => {
        let config = TournamentConfig::from_json_string(&config);
        Some(config.backup_interval)
      },
      None => None
    }
  }

  async fn set_tournament_backup_interval(&mut self, interval: u32) {
    let existing_config = self.inner.read().await.get_tree(TOURNAMENT_CONFIG.to_string()).await.get("config").cloned();
    match existing_config {
      Some(config) => {
        let mut config = TournamentConfig::from_json_string(&config);
        config.backup_interval = interval;
        self.inner.write().await.insert_entry(TOURNAMENT_CONFIG.to_string(), "config".to_string(), config.to_json_string()).await;
      },
      None => {
        let config = TournamentConfig {
          backup_interval: interval,
          ..Default::default()
        };
        self.inner.write().await.insert_entry(TOURNAMENT_CONFIG.to_string(), "config".to_string(), config.to_json_string()).await;
      }
    }

    // reset backup service
    self.reset_backup_service();
  }

  async fn get_tournament_retain_backups(&self) -> Option<u32> {
    let config = self.inner.read().await.get_tree(TOURNAMENT_CONFIG.to_string()).await.get("config").cloned();
    match config {
      Some(config) => {
        let config = TournamentConfig::from_json_string(&config);
        Some(config.retain_backups)
      },
      None => None
    }
  }

  async fn set_tournament_retain_backups(&mut self, retain_backups: u32) {
    let existing_config = self.inner.read().await.get_tree(TOURNAMENT_CONFIG.to_string()).await.get("config").cloned();
    match existing_config {
      Some(config) => {
        let mut config = TournamentConfig::from_json_string(&config);
        config.retain_backups = retain_backups;
        self.inner.write().await.insert_entry(TOURNAMENT_CONFIG.to_string(), "config".to_string(), config.to_json_string()).await;
      },
      None => {
        let config = TournamentConfig {
          retain_backups,
          ..Default::default()
        };
        self.inner.write().await.insert_entry(TOURNAMENT_CONFIG.to_string(), "config".to_string(), config.to_json_string()).await;
      }
    }
  }

  async fn purge(&mut self) {
    // clear the database
    self.inner.write().await.clear().await;

    // add the trees and roles again
    self.create_trees().await;
    self.create_roles().await;
  }
}