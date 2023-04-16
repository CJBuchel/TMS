use rocket::{*, http::Status};
use warp::ws::Message;

use crate::network::{security::{Security, decrypt_local, encrypt}, clients::Clients};
use crate::schemas::*;

#[post("/publish", data = "<message>")]
pub fn publish_route(security: &State<Security>, clients: &State<Clients>, message: String) -> Result<Status, ()> {
  let decrypted_message = decrypt_local(security.inner().clone(), message);
  let socket_message: SocketMessage = serde_json::from_str(decrypted_message.as_str()).unwrap();

  clients
    .read()
    .unwrap()
    .iter()
    .filter(|(_, client)| match socket_message.from_id.clone() {
      Some(v) => client.user_id != v,
      None => true
    })
    .for_each(|(_, client)| {
      if let Some(sender) = &client.ws_sender {
        let j = serde_json::to_string(&socket_message).unwrap();
        let encrypted_j = encrypt(client.key.to_owned(), j);
        let _ = sender.send(Ok(Message::text(encrypted_j.clone())));
      }
    });
  Ok(Status::Accepted)
}