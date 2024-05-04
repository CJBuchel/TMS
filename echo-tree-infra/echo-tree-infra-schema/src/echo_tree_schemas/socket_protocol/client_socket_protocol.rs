use std::collections::HashMap;

use schemars::JsonSchema;

#[derive(serde::Deserialize, serde::Serialize, JsonSchema)]
pub struct ChecksumEvent {
  pub tree_checksums: HashMap<String, u32>, // tree name, checksum
}

#[derive(serde::Deserialize, serde::Serialize, JsonSchema)]
pub struct InsertEvent {
  pub tree_name: String, // tree name
  pub key: String, // key name
  pub data: String, // data
}

#[derive(serde::Deserialize, serde::Serialize, JsonSchema)]
pub struct GetEvent {
  pub tree_name: String, // tree name
  pub key: String, // key name
}

#[derive(serde::Deserialize, serde::Serialize, JsonSchema)]
pub struct DeleteEvent {
  pub tree_items: HashMap<String, String>, // tree name, key
}

#[derive(serde::Deserialize, serde::Serialize, JsonSchema)]
pub struct SetTreeEvent {
  pub trees: HashMap<String, HashMap<String, String>>, // tree name, (k, v)
}

#[derive(serde::Deserialize, serde::Serialize, JsonSchema)]
pub struct GetTreeEvent {
  pub tree_names: Vec<String>, // trees
}

#[derive(serde::Deserialize, serde::Serialize, JsonSchema)]
pub struct SubscribeEvent {
  pub tree_names: Vec<String>, // tree names
}

#[derive(serde::Deserialize, serde::Serialize, JsonSchema)]
pub struct UnsubscribeEvent {
  pub tree_names: Vec<String>, // tree names
}

/**
 * Echo Tree Client Socket Event
 * dictates the message structure, i.e:
 * - PingEvent: (no message)
 * - ChecksumEvent: tree names, checksums
 * - SetEvent: tree, key, data
 * - GetEvent: tree, key
 *   etc...
 */
#[derive(serde::Deserialize, serde::Serialize, JsonSchema)]
pub enum EchoTreeClientSocketEvent {
  // option events
  ChecksumEvent, // tree names, checksums

  // data item events
  InsertEvent, // tree, key, data
  GetEvent, // tree, key
  DeleteEvent, // trees, keys
  // data tree events
  SetTreeEvent, // trees, data
  GetTreeEvent, // trees

  // subscription events
  SubscribeEvent, // tree name
  UnsubscribeEvent, // tree name
}


/**
 * Echo Tree Client Socket Message
 * message to be sent to the server (json data, represented by the event type)
 */
#[derive(serde::Deserialize, serde::Serialize, JsonSchema)]
pub struct EchoTreeClientSocketMessage {
  pub auth_token: String, // auth token for the client (optional for the client to verify the message is from the server)
  pub message_event: EchoTreeClientSocketEvent, // message type, dictates the message structure.
  pub message: Option<String>, // message to be sent to the client (json data, represented by the message type)
}