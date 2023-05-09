use futures::{FutureExt, StreamExt};
use log::{error, warn};
use tms_utils::{security::Security, TmsClients, TmsClient, TmsClientResult, tms_clients_ws_send, schemas::SocketMessage};
use tokio_stream::wrappers::UnboundedReceiverStream;
use warp::{ws::Message, Reply, ws::WebSocket};
use tokio::sync::mpsc;

async fn client_msg(_user_id: String, msg: Message, _clients: TmsClients, security: Security) {
  let message = match msg.to_str() {
    Ok(v) => v,
    Err(_) => return
  };

  let decrypted_message = security.decrypt(message.to_string());

  if message == "ping" || message == "ping\n" {
    return;
  }

  let _socket_message: SocketMessage = serde_json::from_str(decrypted_message.as_str()).unwrap();

  if _socket_message.message == "ping" || _socket_message.message == "ping\n" {
    return;
  }
  // @todo use socket message for something. (Off chance that the client sends a socket message instead of the server)
}

async fn client_connection(ws: WebSocket, user_id: String, clients: TmsClients, mut client: TmsClient, security: Security) {
  let (client_ws_sender, mut client_ws_rcv) = ws.split();
  let (client_sender, client_recv) = mpsc::unbounded_channel();

  let user_id_copy = user_id.clone();
  let client_recv = UnboundedReceiverStream::new(client_recv);

  let shared_clients = clients.clone();
  client.ws_sender = Some(client_sender);
  clients.write().unwrap().insert(user_id.clone(), client);
  warn!("{} connected", user_id.clone());

  let client_list_update = SocketMessage {
    from_id: Some(String::from("")),
    topic: String::from("clients"),
    message: String::from("update")
  };

  tms_clients_ws_send(client_list_update.clone(), shared_clients.clone(), Some(String::from("")));

  tokio::task::spawn(client_recv.forward(client_ws_sender).map(move |result| {
    if let Err(e) = result {
      error!("error sending websocket msg: {}: {}", user_id_copy, e);
    }
  }));

  while let Some(result) = client_ws_rcv.next().await {
    let msg = match result {
      Ok(msg) => msg,
      Err(e) => {
        error!("error receiving message for user id: {}: {}", user_id.clone(), e);
        break;
      }
    };
    client_msg(user_id.clone(), msg, clients.to_owned(), security.clone()).await;
  }

  clients.write().unwrap().remove(&user_id);
  warn!("{} disconnected", user_id.to_owned());
  tms_clients_ws_send(client_list_update.clone(), clients.clone(), Some(String::from("")));
}

pub async fn ws_handler(ws: warp::ws::Ws, user_id: String, clients: TmsClients, security: Security) -> TmsClientResult<impl Reply> {
  let client = clients.read().unwrap().get(&user_id).cloned();
  match client {
    Some(c) => Ok(ws.on_upgrade(move |socket| client_connection(socket, user_id, clients.to_owned(), c, security))),
    None => Err(warp::reject::not_found()),
  }
}