
use std::{result, borrow::Borrow};

use futures::{FutureExt, StreamExt};
use serde::Deserialize;
use serde_json::from_str;
use tokio::sync::mpsc;
use tokio_stream::wrappers::UnboundedReceiverStream;
use warp::ws::{Message, WebSocket};

use crate::network::handler::unregister_handler;

use super::network::{Client, Clients};
#[derive(Deserialize, Debug)]
pub struct TopicRequest {
  topics: Vec<String>
}

async fn client_msg(id: &str, msg: Message, clients: &Clients) {
  println!("received message from {}: {:?}", id, msg);
  let message = match msg.to_str() {
    Ok(v) => v,
    Err(_) => return
  };

  if message == "ping" || message == "ping\n" {
    return;
  }

  let topics_req: TopicRequest = match from_str(&message) {
    Ok(v) => v,
    Err(e) => {
      eprintln!("error while parsing message to topcs request: {}", e);
      return;
    }
  };

  let mut locked = clients.write().unwrap();
  if let Some(v) = locked.get_mut(id) {
    v.topics = topics_req.topics;
  }
}

pub async fn client_connection(ws: WebSocket, id: String, clients: Clients, mut client: Client) {
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

    client_msg(&id, msg, &clients).await;
  }

  // clients.write().unwrap().remove(&id);
  unregister_handler(id.to_owned(), clients).await.unwrap();
  println!("{} disconnected", id.to_owned());
}