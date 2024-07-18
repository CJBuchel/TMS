use schemars::JsonSchema;

use crate::DataSchemeExtensions;


#[derive(serde::Deserialize, serde::Serialize, Clone, JsonSchema)]
pub enum TmsServerSocketEvent {
  PurgeEvent,

  // timer events
  MatchTimerEvent, // (time, start, stop, end, time, endgame, reload)

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

impl DataSchemeExtensions for TmsServerSocketMessage {}