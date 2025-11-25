use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;

use super::{TmsCategory, TmsDateTime};

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub enum TeamCheckInStatus {
  NotCheckedIn,
  NotPlaying,
  CheckedIn,
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct GameMatchTable {
  pub table: String,
  pub team_number: String,
  pub score_submitted: bool,
  pub check_in_status: TeamCheckInStatus,
}

// State for match queuing,
#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub enum GameMatchQueueStatus {
  QueueingSoon,
  QueuingNow,
  OnDeck,
  Playing,
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct GameMatch {
  pub match_number: String,
  pub start_time: TmsDateTime,
  pub end_time: TmsDateTime,
  pub game_match_tables: Vec<GameMatchTable>,
  pub completed: bool,

  // category
  pub category: TmsCategory,

  // State for match queuing
  pub queue_state: GameMatchQueueStatus,
}

impl Default for GameMatch {
  fn default() -> Self {
    Self {
      match_number: "".to_string(),
      start_time: TmsDateTime::default(),
      end_time: TmsDateTime::default(),
      game_match_tables: Vec::new(),
      completed: false,
      category: TmsCategory::default(),
      queue_state: GameMatchQueueStatus::QueueingSoon,
    }
  }
}

impl DataSchemeExtensions for GameMatch {}
