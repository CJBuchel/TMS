use async_graphql::Object;

use super::model::TournamentConfig;

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
