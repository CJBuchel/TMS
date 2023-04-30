pub mod security;

use rocket::{http::Status, serde::json::Json};
use security::Security;
use serde::{Serialize};
use std::{sync::{RwLock, Arc}, collections::HashMap};
use tokio::sync::mpsc;
use warp::{ws::Message, Rejection};

// Clients structure
#[derive(Clone)]
pub struct TmsClient {
  pub user_id: String, // the uuid for the client (client generated)
  pub key: String, // public key for this client
  pub ws_sender: Option<mpsc::UnboundedSender<std::result::Result<Message, warp::Error>>> // socket sender used for dispatching messages
}

pub type TmsClientResult<T> = std::result::Result<T, Rejection>;
pub type TmsClients = Arc<RwLock<HashMap<String, TmsClient>>>;
pub fn new_clients_map() -> TmsClients {
  return Arc::new(RwLock::new(HashMap::new()));
}

// Route response for clients
pub type TmsRouteResponse<T,E> = Result<(Status, Json<T>), E>;

pub fn tms_client_send_response<T: Serialize>(message: T, clients: TmsClients, security: Security, origin_id: Option<String>) {
  // let mut clients_collection = clients.read().unwrap().iter();
  clients
    .read()
    .unwrap()
    .iter()
    .filter(|(_, client)| match origin_id.clone() {
      Some(v) => client.user_id != v, // if origin id is supplied, check for it and don't match the origin
      None => true // if no origin id is supplied, just match all
    })
    .for_each(|(_, client)| {
      if let Some(sender) = &client.ws_sender {
        let j = serde_json::to_string(&message).unwrap();
        let encrypted_j = security.encrypt(j);
        let _ = sender.send(Ok(Message::text(encrypted_j.clone())));
      }
    });
}

/// Converts the request message to a json format (uses serde)
/// # Example
/// ```edition2021
/// let security: Security = sec; // uses TMS Security
/// let message: String = m;
/// let my_message: SocketMessage = TmsRequest(message, security)
#[macro_export]
macro_rules! TmsRequest {
  ($message:expr) => {
    serde_json::from_str($message.as_str()).unwrap()
  };

  ($message:expr, $security:expr) => {
    serde_json::from_str($security.decrypt($message).as_str()).unwrap()
  };
}

#[macro_export]
macro_rules! TmsRespond {
  () => {
    return Ok((Status::Ok, Json({})))
  };

  ($status:expr) => {
    return Ok(($status, Json({})))
  };

  ($status:expr, $data:expr) => {
    return Ok(($status, Json($data)))
  }
}