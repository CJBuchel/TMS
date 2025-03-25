use async_graphql::{FieldResult, Object, Subscription};
use database::TableBroker;
use tokio_stream::Stream;

use crate::api::RecordChangedAPI;

use super::{model::TournamentConfig, TournamentConfigRepository};

//
// API Types
//

pub struct TournamentConfigAPI(pub TournamentConfig);

#[Object]
impl TournamentConfigAPI {
  async fn event_name(&self) -> &str {
    &self.0.event_name
  }

  async fn backup_interval(&self) -> u32 {
    self.0.backup_interval
  }

  async fn backup_retention(&self) -> u32 {
    self.0.backup_retention
  }

  async fn end_game_timer_trigger(&self) -> u32 {
    self.0.end_game_timer_trigger
  }

  async fn timer_length(&self) -> u32 {
    self.0.timer_length
  }

  async fn season(&self) -> Option<&str> {
    self.0.season.as_deref()
  }
}

//
// Queries
//

#[derive(Default)]
pub struct TournamentConfigQueries;
#[Object]
impl TournamentConfigQueries {
  async fn tournament_config(&self) -> FieldResult<TournamentConfigAPI> {
    let config = match TournamentConfig::get().await {
      Ok(config) => config,
      Err(e) => {
        log::error!("Failed to get tournament config: {}", e);
        return Err(e.into());
      }
    };

    Ok(TournamentConfigAPI(config))
  }
}

//
// Mutations
//
#[derive(Default)]
pub struct TournamentConfigMutations;
#[Object]
impl TournamentConfigMutations {
  pub async fn update_name(&self, event_name: String) -> FieldResult<TournamentConfigAPI> {
    let config = match TournamentConfig::get().await {
      Ok(mut config) => {
        config.event_name = event_name;
        config
      }
      Err(e) => {
        log::error!("Failed to get tournament config: {}", e);
        return Err(e.into());
      }
    };

    let config = match TournamentConfig::update(config).await {
      Ok(config) => config,
      Err(e) => {
        log::error!("Failed to update tournament config: {}", e);
        return Err(e.into());
      }
    };

    Ok(TournamentConfigAPI(config))
  }

  pub async fn update_tournament_config(&self, config: TournamentConfig) -> FieldResult<TournamentConfigAPI> {
    let config = match TournamentConfig::update(config).await {
      Ok(config) => config,
      Err(e) => {
        log::error!("Failed to update tournament config: {}", e);
        return Err(e.into());
      }
    };
    Ok(TournamentConfigAPI(config))
  }
}

//
// Subscriptions
//
#[derive(Default)]
pub struct TournamentConfigSubscriptions;

#[Subscription]
impl TournamentConfigSubscriptions {
  async fn tournament_config_changes(&self) -> impl Stream<Item = RecordChangedAPI<TournamentConfigAPI>> {
    TableBroker::<TournamentConfig>::subscribe_transform(|change| {
      RecordChangedAPI::<TournamentConfigAPI>::new(change.0, change.1.map(TournamentConfigAPI))
    })
  }
}
