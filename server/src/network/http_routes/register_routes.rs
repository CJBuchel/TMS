use local_ip_address::local_ip;
use ::log::{warn, info};
use rocket::*;
use rocket::State;
use rocket::http::Status;
use rocket::serde::json::{Json};

use crate::network::clients::{Clients, Client};
use crate::schemas::*;

fn register_client(user_id: String, key: String, clients: Clients) {
  clients.write().unwrap().insert(
    user_id.clone(),
    Client {
      user_id,
      key,
      ws_sender: None
    },
  );
}

fn unregister_client(user_id: String, clients: Clients) {
  clients.write().unwrap().remove(&user_id);
  warn!("Unregistered Client {}", user_id);
}

#[post("/register", data = "<register_request>")]
pub fn register_route(clients: &State<Clients>, s_public_key: &State<Vec<u8>>, ws_port: &State<u16>, register_request: Json<RegisterRequest>) -> Result<Json<RegisterResponse>, ()> {
  let user_id = register_request.user_id.clone();
  let server_ip = local_ip().unwrap();

  if clients.read().unwrap().contains_key(&user_id) {
    return Ok(Json(RegisterResponse {
      key: String::from_utf8(s_public_key.to_vec()).unwrap(),
      url: format!("ws://{:?}:{}/ws/{}", server_ip, ws_port, user_id)
    }));
  }

  register_client(user_id.to_owned(), register_request.key.to_owned(), clients.inner().clone());

  info!("Registered New Client: {}", user_id);
  Ok(Json(RegisterResponse {
    key: String::from_utf8(s_public_key.to_vec()).unwrap(),
    url: format!("ws://{:?}:{}/ws/{}", server_ip, ws_port, user_id)
  }))
}

#[delete("/register/<user_id>")]
pub fn unregister_route(clients: &State<Clients>, user_id: String) -> Result<Status, Status> {
  unregister_client(user_id, clients.inner().clone());
  Ok(Status::Ok)
}