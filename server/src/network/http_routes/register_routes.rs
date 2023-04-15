use std::borrow::Borrow;

use local_ip_address::linux::local_ip;
use rocket::*;
use rocket::State;
use rocket::{http::Status, response::Responder};
use rocket::serde::json::{Json};
use uuid::Uuid;

use crate::network::clients::{Clients, Client};
use crate::schemas::*;

fn register_client(private_id: String, user_id: String, key: String, clients: &Clients) {
  clients.write().unwrap().insert(
    private_id.clone(),
    Client {
      user_id,
      key,
      ws_sender: None
    },
  );
}

#[put("/register", data = "<register_request>")]
pub fn register(clients: &State<Clients>, s_public_key: &State<Vec<u8>>, register_request: Json<RegisterRequest>) -> Result<Json<RegisterResponse>, ()> {
  let user_id = register_request.user_id.clone();
  let private_id = Uuid::new_v4().as_simple().to_string();

  register_client(private_id.to_owned(), user_id.to_owned(), register_request.key.to_owned(), clients.to_owned());

  println!("Registered Client {}", user_id);
  println!("Public Key: {}", register_request.key);

  let server_ip = local_ip().unwrap();
  Ok(Json(RegisterResponse {
    url: format!("ws://{:?}:2121/ws/{}", server_ip, private_id),
    key: String::from_utf8(s_public_key.to_vec()).unwrap(),
  }))
}