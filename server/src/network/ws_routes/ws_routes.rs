use futures::{FutureExt, StreamExt};
use log::{info, error, warn};
use tokio_stream::wrappers::UnboundedReceiverStream;
use warp::{ws::Message, Reply, ws::WebSocket};
use tokio::sync::mpsc;
use crate::network::clients::ClientResult;
use crate::schemas::*;

use crate::network::{security::{Security, decrypt_local}, clients::{Clients, Client}};

async fn client_msg(private_id: String, msg: Message, clients: Clients, security: Security) {
  let message = match msg.to_str() {
    Ok(v) => v,
    Err(_) => return
  };

  let decrypted_message = decrypt_local(security, message.to_string());

  if message == "ping" || message == "ping\n" {
    return;
  }

  let socket_message: SocketMessage = serde_json::from_str(decrypted_message.as_str()).unwrap();
  // @todo use socket message for something. (Off change that the client sends a socket message instead of the server)
}

async fn client_connection(ws: WebSocket, private_id: String, clients: Clients, mut client: Client, security: Security) {
  let (client_ws_sender, mut client_ws_rcv) = ws.split();
  let (client_sender, client_recv) = mpsc::unbounded_channel();

  let client_recv = UnboundedReceiverStream::new(client_recv);
  tokio::task::spawn(client_recv.forward(client_ws_sender).map(|result| {
    if let Err(e) = result {
      error!("error sending websocket msg: {}", e);
    }
  }));

  client.ws_sender = Some(client_sender);
  clients.write().unwrap().insert(private_id.clone(), client);

  info!("{} connected", private_id);

  while let Some(result) = client_ws_rcv.next().await {
    let msg = match result {
      Ok(msg) => msg,
      Err(e) => {
        error!("error receiving message for private id: {}: {}", private_id.clone(), e);
        break;
      }
    };
    client_msg(private_id.clone(), msg, clients.to_owned(), security.clone()).await;
  }

  clients.write().unwrap().remove(&private_id);
  warn!("{} disconnected", private_id.to_owned());
}

pub async fn ws_handler(ws: warp::ws::Ws, private_id: String, clients: Clients, security: Security) -> ClientResult<impl Reply> {
  let client = clients.read().unwrap().get(&private_id).cloned();
  match client {
    Some(c) => Ok(ws.on_upgrade(move |socket| client_connection(socket, private_id, clients.to_owned(), c, security))),
    None => Err(warp::reject::not_found()),
  }
}