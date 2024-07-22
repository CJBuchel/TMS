use echo_tree_infra::DataSchemeExtensions;

#[derive(serde::Deserialize, serde::Serialize, Clone, JsonSchema)]
pub enum TmsServerMatchTimerState {
  StartCountdown, // start the countdown timer
  Start, // start the timer
  Time, // time in seconds
  Endgame, // endgame time in seconds
  End, // end the timer
  Stop, // stop the timer
  Reload, // reload the timer
}

#[derive(serde::Deserialize, serde::Serialize, Clone, JsonSchema)]
pub struct TmsServerMatchTimerEvent {
  pub time: u32, // time in seconds
  pub state: TmsServerMatchTimerState, // timer state
}

impl Default for TmsServerMatchTimerTimeEvent {
  fn default() -> Self {
    Self { time: 0 }
  }
}

impl DataSchemeExtensions for TmsServerMatchTimerState {}

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

impl DataSchemeExtensions for TmsServerMatchState {}