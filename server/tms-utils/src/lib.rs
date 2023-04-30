pub mod security;

use rocket::{http::Status, serde::json::Json};
use security::encrypt;
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
pub type TmsEncryptedRouteResponse<E> = Result<(Status, String), E>; // always responds with a string.
pub type TmsRouteResponse<T,E> = Result<(Status, Json<T>), E>;

pub fn tms_client_send_response<T: Serialize>(message: T, clients: TmsClients, origin_id: Option<String>) {
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
    return Ok((Status::Ok, Json({})))
  };

  // Respond with a custom status
  ($status:expr) => {
    return Ok(($status, Json({})))
  };

  // Respond with both custom status and data
  ($status:expr, $data:expr) => {
    return Ok(($status, Json($data)))
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
      warn!("Integrity Check on Client: {}", $uuid);
      let client_key: String = $clients.read().unwrap().get(&$uuid).unwrap().key.to_owned();
      TmsRespond!($status, $data, client_key);
    } else {
      // Err()
      TmsRespond!(Status::BadRequest, $data, "".to_string());
    }
  };
}