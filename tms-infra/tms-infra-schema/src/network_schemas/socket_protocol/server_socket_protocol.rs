#[derive(serde::Deserialize, serde::Serialize, schemars::JsonSchema, Clone)]
pub struct TmsServerMatchTimerTimeEvent {
  pub time: u32, // time in seconds
}

#[derive(serde::Deserialize, serde::Serialize, schemars::JsonSchema, Clone)]
pub struct TmsServerMatchLoadEvent {
  pub game_match_numbers: Vec<String>, // game match numbers
}

#[derive(serde::Deserialize, serde::Serialize, schemars::JsonSchema, Clone)]
pub enum TmsServerSocketEvent {
  PurgeEvent,

  // timer events
  MatchTimerStartEvent, // start the timer (no message)
  MatchTimerTimeEvent, // time in seconds
  MatchTimerEndgameEvent, // endgame time in seconds
  MatchTimerEndEvent, // end the timer (no message)
  MatchTimerStopEvent, // stop the timer (no message)

  // match events
  MatchLoadEvent, // game match numbers
  MatchUnloadEvent, // unload matches (no message)
}

#[derive(serde::Deserialize, serde::Serialize, schemars::JsonSchema, Clone)]
pub struct TmsServerSocketMessage {
  pub auth_token: String, // auth token for the client (optional for the client to verify the message is from the server)
  pub message_event: TmsServerSocketEvent, // message type, dictates the message structure.
  pub message: Option<String>, // message to be sent to the client (json data, represented by the message type)
}