use std::borrow::Borrow;

use local_ip_address::local_ip;
use uuid::Uuid;
use warp::{http::StatusCode, reply::json, ws::Message, Reply};

use crate::schemas::*;

use super::{network::{Clients, Result, Client}, ws::client_connection, security::{Security, encrypt}};

pub async fn publish_handler(body: SocketMessage, clients: Clients) -> Result<impl Reply> {
  clients
    .read()
    .unwrap()
    .iter()
    .filter(|(_, client)| match body.from_id.clone() {
      Some(v) => client.user_id != v, // stops server from sending message to the client that sent the origin message
      None => true
    })
    .for_each(|(_, client)| {
      if let Some(sender) = &client.sender {
        let j = serde_json::to_string(&body).unwrap();
        let encrypted_j:String = encrypt(client.key.to_owned(), j);
        let _ = sender.send(Ok(Message::text(encrypted_j.clone())));
      }
    });

  Ok(StatusCode::OK)
}

pub async fn register_client(id: String, user_id: String, key: String, clients: Clients) {
  clients.write().unwrap().insert(
    id.clone(),
    Client {
      user_id: user_id,
      key,
      sender: None
    },
  );
}

pub async fn register_handler(body: RegisterRequest, clients: Clients, public_key: Vec<u8>) ->  Result<impl Reply> {
  let user_id = body.user_id.clone();
  let uuid = Uuid::new_v4().as_simple().to_string();

  register_client(uuid.clone(), user_id.clone(), body.key.clone(), clients).await;

  println!("Registered Client {}", user_id);
  println!("Public Key {}", body.key);
  let server_ip = local_ip().unwrap();
  Ok(json(&RegisterResponse {
    url: format!("ws://{:?}:2121/ws/{}", server_ip, uuid),
    key: String::from_utf8(public_key).unwrap()
  }))
}

pub async fn unregister_handler(id: String, clients: Clients) -> Result<impl Reply> {
  clients.write().unwrap().remove(&id);
  println!("Unregistered Client {}", id);
  Ok(StatusCode::OK)
}

pub async fn ws_handler(ws: warp::ws::Ws, id: String, clients: Clients, security: Security) -> Result<impl Reply> {
  let client = clients.read().unwrap().get(&id).cloned();
  match client {
    Some(c) => Ok(ws.on_upgrade(move |socket| client_connection(socket, id, clients, c, security))),
    None => Err(warp::reject::not_found()),
  }
}

pub async fn pulse_handler() -> Result<impl Reply> {
  Ok(StatusCode::OK)
}