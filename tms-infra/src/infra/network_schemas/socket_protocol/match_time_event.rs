use schemars::JsonSchema;

use crate::DataSchemeExtensions;

#[derive(serde::Deserialize, serde::Serialize, Clone, JsonSchema)]

pub enum TmsServerMatchTimerState {
  StartWithCountdown, // start with countdown
  Start,              // start timer
  Stop,               // stop/abort
  End,                // end of the timer event
  Time,               // generic time event
  Endgame,            // endgame event
  Reload,             // reload timer event
}

#[derive(serde::Deserialize, serde::Serialize, Clone, JsonSchema)]
pub struct TmsServerMatchTimerEvent {
  pub time: Option<u32>,               // time in seconds
  pub state: TmsServerMatchTimerState, // timer state
}

impl Default for TmsServerMatchTimerEvent {
  fn default() -> Self {
    Self {
      time: None,
      state: TmsServerMatchTimerState::Stop,
    }
  }
}

impl DataSchemeExtensions for TmsServerMatchTimerEvent {}
