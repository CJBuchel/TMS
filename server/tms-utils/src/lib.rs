pub mod security;
pub mod schemas;
pub mod network_schemas;

use log::warn;
use rocket::{http::Status, serde::json::Json, State};
use schemas::Permissions;
use security::encrypt;
use serde::{Serialize};
use std::{sync::{RwLock, Arc}, collections::HashMap, time::SystemTime};
use tokio::sync::mpsc;
use warp::{ws::Message, Rejection};

// Clients structure
#[derive(Clone)]
pub struct TmsClient {
  pub user_id: String, // the uuid for the client (client generated)
  pub key: String, // public key for this client
  pub auth_token: String, // is this client authorized with a user
  pub permissions: Permissions, // set of permissions for this client
  pub last_timestamp: SystemTime, // timestamp of last message
  pub ws_sender: Option<mpsc::UnboundedSender<std::result::Result<Message, warp::Error>>> // socket sender used for dispatching messages
}

pub type TmsClientResult<T> = std::result::Result<T, Rejection>;
pub type TmsClients = Arc<RwLock<HashMap<String, TmsClient>>>;
pub fn new_clients_map() -> TmsClients {
  return Arc::new(RwLock::new(HashMap::new()));
}

pub fn with_clients_write<F, R>(clients: &TmsClients, f: F) -> Result<R, &'static str>
where
  F: FnOnce(&mut HashMap<String, TmsClient>) -> R,
{
  match clients.write() {
    Ok(mut guard) => Ok(f(&mut *guard)),
    Err(poisoned) => {
      warn!("The Clients Lock was Poisoned. Recovering...");
      let mut guard = poisoned.into_inner();
      Ok(f(&mut *guard))
    },
  }
}

// Route response for clients
pub type TmsRouteResponse<E> = Result<(Status, String), E>; // always responds with a string.
pub type TmsRouteResponseNoEncryption<T,E> = Result<(Status, Json<T>), E>; // responds with a status, and an encrypted message

/// Sends a message to every client, optionally with an origin id (stops a message to the original client)
pub fn tms_clients_ws_send<T: Serialize>(message: T, clients: TmsClients, origin_id: Option<String>) {
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
        let m = serde_json::to_string(&message).unwrap();
        let encrypted_m = encrypt(client.key.clone(), m);
        let _ = sender.send(Ok(Message::text(encrypted_m.clone())));
      }
    });
}

pub fn check_auth(clients: &State<TmsClients>, uuid: String, auth_token: String) -> (bool, Option<TmsClient>) {
  if clients.read().unwrap().contains_key(&uuid) {
    let client = clients.read().unwrap().get(&uuid).unwrap().clone();
    if client.auth_token == auth_token {
      return (true, Some(client));
    }
  }
  return (false, None);
}

pub fn check_permissions(clients: &State<TmsClients>, uuid: String, auth_token: String, permissions: Permissions) -> bool {
  let auth = check_auth(clients, uuid, auth_token);

  if auth.0 {
    let client = auth.1.unwrap();
    if client.permissions.admin {
      return true;
    } else if client.permissions.head_referee.unwrap_or(false) && permissions.head_referee.unwrap_or(false) {
      return true;
    } else if client.permissions.referee.unwrap_or(false) && permissions.referee.unwrap_or(false) {
      return true;
    } else if client.permissions.judge_advisor.unwrap_or(false) && permissions.judge_advisor.unwrap_or(false) {
      return true;
    } else if client.permissions.judge.unwrap_or(false) && permissions.judge.unwrap_or(false) {
      return true;
    }
  }

  return false; // if fall through
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


/// Provides returner for OK, either in json format or in string for encrypted
/// # Example
/// ```edition2021
/// let security: Security = sec; // uses TMS Security
/// let message: IntegrityMessage = TmsRequest!(message, security);
/// TmsRespond(); // respond with defaults, returns Ok(Status::Ok)
/// TmsRespond(Status::Ok); responds with Ok(custom status)
/// TmsRespond(Status::Ok, my_json_message); // responds with json message
/// TmsRespond(Status::Ok, my_json_message, key); // responds with an encrypted version of the json
/// TmsRespond(Status::Ok, my_json_message, clients, uuid); // responds with the encrypted message using clients and uuid to find the key
#[macro_export]
macro_rules! TmsRespond {

  // Respond with default ok
  () => {
    return Ok((Status::Ok, String::from("")))
  };

  // Respond with a custom status
  ($status:expr) => {
    return Ok(($status, String::from("")))
  };

  // Respond with both custom status and data
  ($status:expr, $data:expr) => {
    return Ok(($status, $data))
  };

  // Respond with custom status and data encrypted with key
  ($status:expr, $data:expr, $key:expr) => {
    let m: String = serde_json::to_string(&$data).unwrap();
    let enc_m: String = encrypt($key, m);
    return Ok(($status, enc_m))
  };

  // Respond with custom status and data encrypted using clients and client uuid
  ($status:expr, $data:expr, $clients:expr, $uuid:expr) => {
    if $clients.read().unwrap().contains_key(&$uuid) {
      let client_key: String = $clients.read().unwrap().get(&$uuid).unwrap().key.to_owned();
      TmsRespond!($status, $data, client_key);
    } else {
      // Err()
      TmsRespond!(Status::BadRequest, $data, "".to_string());
    }
  };
}

