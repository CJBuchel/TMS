use std::collections::HashMap;

use schemars::JsonSchema;

use super::client_socket_protocol::EchoTreeClientSocketEvent;

#[derive(serde::Deserialize, serde::Serialize, JsonSchema, Clone)]
pub struct EchoTreeEventTree {
  pub tree_name: String, // tree name
  pub tree: HashMap<String, String>, // (k, v)
}

#[derive(serde::Deserialize, serde::Serialize, JsonSchema, Clone)]
pub struct EchoTreeEvent {
  pub trees: Vec<EchoTreeEventTree>, // trees
}


#[derive(serde::Deserialize, serde::Serialize, JsonSchema, Clone)]
pub struct EchoItemEvent {
  pub tree_name: String, // tree name
  pub key: String, // key name
  pub data: String, // data
}

#[derive(serde::Deserialize, serde::Serialize, JsonSchema)]
pub struct StatusResponseEvent {
  pub status_code: u16, // error code (should be http status code)
  pub from_event: Option<EchoTreeClientSocketEvent>, // what the response is from (i.e, response from SetEvent)
  pub message: Option<String>, // error message
}

/**
 * Echo Tree Event
 * dictates the message structure, i.e:
 * - PingEvent: (no message)
 * - EchoTreeEvent: trees, data
 * - EchoItemEvent: tree, key, data
 *   etc...
 */
#[derive(serde::Deserialize, serde::Serialize, JsonSchema)]
pub enum EchoTreeServerSocketEvent {
  // echo events
  EchoTreeEvent, // trees, data
  EchoItemEvent, // tree, key, data
  
  // option events
  StatusResponseEvent, // status code, message
}


/**
 * Echo Tree Server Socket Message
 * message to be sent to the client (json data, represented by the event type)
 */
#[derive(serde::Deserialize, serde::Serialize, JsonSchema)]
pub struct EchoTreeServerSocketMessage {
  pub auth_token: String, // auth token for the client (optional for the client to verify the message is from the server)
  pub message_event: EchoTreeServerSocketEvent, // message type, dictates the message structure.
  pub message: Option<String>, // message to be sent to the client (json data, represented by the message type)
}