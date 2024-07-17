use schemars::JsonSchema;

use crate::DataSchemeExtensions;

#[derive(serde::Deserialize, serde::Serialize, Clone, JsonSchema)]
pub struct TmsServerMatchTimerTimeEvent {
  pub time: u32, // time in seconds
}

impl Default for TmsServerMatchTimerTimeEvent {
  fn default() -> Self {
    Self { time: 0 }
  }
}

#[derive(serde::Deserialize, serde::Serialize, Clone, JsonSchema)]
pub enum TmsServerMatchState {
  Running, // match running
  Ready, // loaded, ready to start
  Load, // loaded match
  Unload, // unload event, remove matches
}

#[derive(serde::Deserialize, serde::Serialize, Clone, JsonSchema)]
pub struct TmsServerMatchStateEvent {
  pub state: TmsServerMatchState, // match state
  pub game_match_tables: Vec<(String, bool)>, // game tables (table, ready/not ready)
  pub game_match_numbers: Vec<String>, // game match numbers
}

impl Default for TmsServerMatchStateEvent {
  fn default() -> Self {
    Self { 
      state: TmsServerMatchState::Load,
      game_match_tables: vec![],
      game_match_numbers: vec![] 
    }
  }
}

#[derive(serde::Deserialize, serde::Serialize, Clone, JsonSchema)]
pub enum TmsServerSocketEvent {
  PurgeEvent,

  // timer events
  MatchTimerStartCountdownEvent, // start the countdown timer (no message)
  MatchTimerStartEvent, // start the timer (no message)
  MatchTimerTimeEvent, // time in seconds
  MatchTimerEndgameEvent, // endgame time in seconds
  MatchTimerEndEvent, // end the timer (no message)
  MatchTimerStopEvent, // stop the timer (no message)
  MatchTimerReloadEvent, // reload the timer (no message)

  // match events
  MatchStateEvent, // (running, ready, load, unload, table_ready vec, game match numbers)
}

#[derive(serde::Deserialize, serde::Serialize, Clone, JsonSchema)]
pub struct TmsServerSocketMessage {
  pub auth_token: String, // auth token for the client (optional for the client to verify the message is from the server)
  pub message_event: TmsServerSocketEvent, // message type, dictates the message structure.
  pub message: Option<String>, // message to be sent to the client (json data, represented by the message type)
}

impl Default for TmsServerSocketMessage {
  fn default() -> Self {
    Self {
      auth_token: "".to_string(),
      message_event: TmsServerSocketEvent::PurgeEvent,
      message: None,
    }
  }
}

impl DataSchemeExtensions for TmsServerMatchTimerTimeEvent {}
impl DataSchemeExtensions for TmsServerMatchStateEvent {}
impl DataSchemeExtensions for TmsServerSocketMessage {}