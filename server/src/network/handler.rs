use local_ip_address::local_ip;
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use warp::{http::StatusCode, reply::json, ws::Message, Reply};

use crate::schemas::*;

use super::{network::{Clients, Result, Client}, ws::client_connection};

pub async fn publish_handler(body: SocketEvent, clients: Clients) -> Result<impl Reply> {
  clients
    .read()
    .unwrap()
    .iter()
    .filter(|(_, client)| match body.user_id.clone() {
      Some(v) => client.user_id == v,
      None => true
    })
    .filter(|(_, client)| client.topics.contains(&body.topic))
    .for_each(|(_, client)| {
      if let Some(sender) = &client.sender {
        let _ = sender.send(Ok(Message::text(body.message.clone())));
      }
    });

  Ok(StatusCode::OK)
}

pub async fn register_client(id: String, user_id: String, clients: Clients) {
  clients.write().unwrap().insert(
    id,
    Client {
      user_id,
      topics: vec![String::from("event")],
      sender: None
    },
  );
}

pub async fn register_handler(body: RegisterRequest, clients: Clients) ->  Result<impl Reply> {
  let user_id = body.user_id.clone();
  let uuid = Uuid::new_v4().as_simple().to_string();

  register_client(uuid.clone(), user_id, clients).await;

  println!("Registered Client {}", body.user_id);
  let server_ip = local_ip().unwrap();
  Ok(json(&RegisterResponse {
    url: format!("ws://{:?}:2121/ws/{}", server_ip, uuid)
  }))
}

pub async fn unregister_handler(id: String, clients: Clients) -> Result<impl Reply> {
  clients.write().unwrap().remove(&id);
  println!("Unregistered Client {}", id);
  Ok(StatusCode::OK)
}

pub async fn ws_handler(ws: warp::ws::Ws, id: String, clients: Clients) -> Result<impl Reply> {
  let client = clients.read().unwrap().get(&id).cloned();
  match client {
    Some(c) => Ok(ws.on_upgrade(move |socket| client_connection(socket, id, clients, c))),
    None => Err(warp::reject::not_found()),
  }
}

pub async fn health_handler() -> Result<impl Reply> {
  Ok(StatusCode::OK)
}