use futures::{FutureExt, StreamExt};
use tokio::sync::mpsc;
use tokio_stream::wrappers::UnboundedReceiverStream;
use warp::ws::{Message, WebSocket};


use crate::{schemas::{SocketMessage}, network::{handler::{unregister_handler, publish_handler}, security::{decrypt, encrypt, decrypt_local}}};

use super::{network::{Client, Clients}, security::Security};

async fn client_msg(id: &str, msg: Message, clients: &Clients, security: Security) {
  let message = match msg.to_str() {
    Ok(v) => v,
    Err(_) => return
  };
  let decrypted_message = decrypt_local(security.clone(), message.to_string());

  if message == "ping" || message == "ping\n" {
    return;
  }

  let socket_message: SocketMessage = serde_json::from_str(decrypted_message.as_str()).unwrap();
  publish_handler(socket_message, clients.clone()).await.unwrap();
}

pub async fn client_connection(ws: WebSocket, id: String, clients: Clients, mut client: Client, security: Security) {
  let (client_ws_sender, mut client_ws_rcv) = ws.split();
  let (client_sender, client_recv) = mpsc::unbounded_channel();

  let client_recv = UnboundedReceiverStream::new(client_recv);
  tokio::task::spawn(client_recv.forward(client_ws_sender).map(|result| {
    if let Err(e) = result {
      eprintln!("error sending websocket msg: {}", e);
    }
  }));

  client.sender = Some(client_sender);
  clients.write().unwrap().insert(id.clone(), client);

  println!("{} connected", id);

  while let Some(result) = client_ws_rcv.next().await {
    let msg = match result {
      Ok(msg) => msg,
      Err(e) => {
        eprintln!("error receiving as message for id: {}): {}", id.clone(), e);
        break;
      }
    };

    client_msg(&id, msg, &clients, security.clone()).await;
  }

  // clients.write().unwrap().remove(&id);
  unregister_handler(id.to_owned(), clients).await.unwrap();
  println!("{} disconnected", id.to_owned());
}