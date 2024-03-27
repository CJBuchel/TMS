pub mod security;
pub mod schemas;
pub mod network_schemas;
use std::{time::SystemTime, collections::HashMap};

pub use fll_games::schemas::*;

use log::error;
use network_schemas::SocketMessage;
use rocket::{http::Status, serde::json::Json, State};
use schemas::Permissions;
use security::encrypt;
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
pub type TmsClients = std::sync::Arc<tokio::sync::RwLock<HashMap<String, TmsClient>>>;
pub fn new_clients_map() -> TmsClients {
  return std::sync::Arc::new(tokio::sync::RwLock::new(HashMap::new()));
}

pub async fn with_clients_write<F, R>(clients: &TmsClients, f: F) -> Result<R, &'static str>
where
  F: FnOnce(&mut HashMap<String, TmsClient>) -> R,
{
  let mut guard = clients.write().await;
  Ok(f(&mut *guard))
}

pub async fn with_clients_read<F, R>(clients: &TmsClients, f: F) -> Result<R, &'static str>
where
  F: FnOnce(&HashMap<String, TmsClient>) -> R,
{
  let guard = clients.read().await;
  Ok(f(&*guard))
}

// Route response for clients
pub type TmsRouteResponse<E> = Result<(Status, String), E>; // always responds with a string.
pub type TmsRouteResponseNoEncryption<T,E> = Result<(Status, Json<T>), E>; // responds with a status, and an encrypted message

/// Sends a message to every client, optionally with an origin id (stops a message to the original client)
pub async fn tms_clients_ws_send(message: SocketMessage, clients: TmsClients, origin_id: Option<String>) {
  let result = with_clients_read(&clients, |clients_map| {
    clients_map.clone()
  }).await;

  match result {
    Ok(map) => {
      map.iter()
      .filter(|(_, client)| match origin_id.clone() {
        Some(v) => client.user_id != v, // if origin id is supplied, check for it and don't match the origin
        None => true // if no origin id is supplied, just match all
      })
      .for_each(|(_, client)| {
        let sender = match &client.ws_sender {
          Some(v) => v,
          None => return,
        };
        let m = serde_json::to_string(&message).unwrap();
        let encrypted_m = encrypt(client.key.clone(), m);
        let sender = sender.clone();
        let _ = sender.send(Ok(Message::text(encrypted_m.clone())));
      });
    },
    Err(_) => {
      error!("failed to get clients lock");
    }
  }
}
/// sends message to a single client, optionally with an origin id
pub async fn tms_client_ws_send(message: SocketMessage, clients: TmsClients, target_id: String, origin_id: Option<String>) {
  let result = with_clients_read(&clients, |clients_map| {
    clients_map.clone()
  }).await;

  match result {
    Ok(map) => {
      map.iter()
      .filter(|(_, client)| match origin_id.clone() {
        Some(v) => client.user_id != v, // if origin id is supplied, check for it and don't match the origin
        None => true // if no origin id is supplied, just match all
      })
      .filter(|(_, client)| match target_id.clone() {
        v if v == client.user_id => true,
        _ => false,
      })
      .for_each(|(_, client)| {
        let sender = match &client.ws_sender {
          Some(v) => v,
          None => return,
        };
        let m = serde_json::to_string(&message).unwrap();
        let encrypted_m = encrypt(client.key.clone(), m);
        let sender = sender.clone();
        let _ = sender.send(Ok(Message::text(encrypted_m.clone())));
      });
    },
    Err(_) => {
      error!("failed to get clients lock");
    }
  }
}

pub async fn check_auth(clients: &State<TmsClients>, uuid: String, auth_token: String) -> (bool, Option<TmsClient>) {
  let result = with_clients_read(&clients, |clients_map| {
    clients_map.clone()
  }).await;

  match result {
    Ok(map) => {
      if map.contains_key(&uuid) {
        let client = map.get(&uuid).unwrap().clone();
        if client.auth_token == auth_token {
          return (true, Some(client));
        }
      }
    },
    Err(_) => {
      error!("failed to get clients lock");
    }
  }

  return (false, None);
}

pub async fn check_permissions(clients: &State<TmsClients>, uuid: String, auth_token: String, permissions: Permissions) -> bool {
  let auth = check_auth(clients, uuid, auth_token).await;

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

#[macro_export]
macro_rules! TmsSocketRequest {
  ($message:expr) => {
    serde_json::from_str($message.as_str())
  };

  ($message:expr, $security:expr) => {
    serde_json::from_str($security.decrypt($message).as_str())
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
  ($status:expr, $data:expr, $client_map:expr, $uuid:expr) => {
    if $client_map.contains_key(&$uuid) {
      let client_key: String = $client_map.get(&$uuid).unwrap().key.to_owned();
      TmsRespond!($status, $data, client_key);
    } else {
      // Err()
      TmsRespond!(Status::BadRequest, $data, "".to_string());
    }
  };
}