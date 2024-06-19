
#[derive(serde::Deserialize, serde::Serialize, schemars::JsonSchema, Clone)]
pub enum TmsServerSocketEvent {
  PurgeEvent,
}

#[derive(serde::Deserialize, serde::Serialize, schemars::JsonSchema, Clone)]
pub struct TmsServerSocketMessage {
  pub auth_token: String, // auth token for the client (optional for the client to verify the message is from the server)
  pub message_event: TmsServerSocketEvent, // message type, dictates the message structure.
  pub message: Option<String>, // message to be sent to the client (json data, represented by the message type)
}