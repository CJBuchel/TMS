use futures::{FutureExt, StreamExt};
use log::{error, warn};
use tms_utils::{security::Security, TmsClients, TmsClient, TmsClientResult, tms_clients_ws_send, network_schemas::SocketMessage, with_clients_write, with_clients_read};
use tokio_stream::wrappers::UnboundedReceiverStream;
use warp::{ws::Message, Reply, ws::WebSocket};
use tokio::sync::mpsc;

use crate::{network::ws_routes::game_routes::validate_questions_route, event_service::TmsEventServiceArc};
async fn client_msg(
  user_id: String, 
  msg: Message, 
  clients: TmsClients, 
  security: Security,
  tms_event_service: TmsEventServiceArc,
) {
  let message = match msg.to_str() {
    Ok(v) => v,
    Err(_) => return
  };

  let decrypted_message = security.decrypt(message.to_string());

  if message == "ping" || message == "ping\n" {
    return;
  }

  let _socket_message: SocketMessage = serde_json::from_str(decrypted_message.as_str()).unwrap();

  if _socket_message.message == "ping".to_string() || _socket_message.message == "ping\n".to_string() {
    return;
  }

  // validation system
  if _socket_message.topic == "validation" {
    warn!("validation message received from: {}", user_id.clone());
    validate_questions_route(_socket_message.message, tms_event_service, clients, user_id.clone()).await;
  }

  warn!("Finished processing message");

  // @todo use socket message for something. (Off chance that the client sends a socket message instead of the server)
}

async fn client_connection(
  ws: WebSocket, 
  user_id: String, 
  clients: TmsClients, 
  mut client: TmsClient, 
  security: Security,
  tms_event_service: TmsEventServiceArc,
) {
  let (client_ws_sender, mut client_ws_rcv) = ws.split();
  let (client_sender, client_recv) = mpsc::unbounded_channel();

  let user_id_copy = user_id.clone();
  let client_recv = UnboundedReceiverStream::new(client_recv);

  let shared_clients = clients.clone();
  client.ws_sender = Some(client_sender);
  let _ = with_clients_write(&clients, |client_map| {
    client_map.insert(user_id.clone(), client);
  }).await;
  warn!("{} connected", user_id.clone());

  let client_list_update = SocketMessage {
    from_id: Some(String::from("")),
    topic: String::from("clients"),
    sub_topic: String::from("update"),
    message: String::from(""),
  };

  tms_clients_ws_send(client_list_update.clone(), shared_clients.clone(), Some(String::from(""))).await;

  tokio::task::spawn(client_recv.forward(client_ws_sender).map(move |result| {
    if let Err(e) = result {
      error!("error sending websocket msg: {}: {}", user_id_copy, e);
    }
  }));

  while let Some(result) = client_ws_rcv.next().await {
    let msg = match result {
      Ok(msg) => {
        warn!("Message received");
        msg
      },
      Err(e) => {
        error!("error receiving message for user id: {}: {}", user_id.clone(), e);
        break;
      }
    };


    tokio::spawn(client_msg(user_id.clone(), msg, clients.clone(), security.clone(), tms_event_service.clone()));
  }

  let _ = with_clients_write(&clients, |client_map| {
    client_map.remove(&user_id);
  }).await;
  warn!("{} disconnected", user_id.to_owned());
  let _ = tms_clients_ws_send(client_list_update.clone(), clients.clone(), Some(String::from("")));
}

pub async fn ws_handler(
  ws: warp::ws::Ws, 
  user_id: String, 
  clients: TmsClients, 
  security: Security, 
  tms_event_service: TmsEventServiceArc,
) -> TmsClientResult<impl Reply> {
  let result = with_clients_read(&clients, |client_map| {
    client_map.get(&user_id).cloned()
  }).await;

  match result {
    Ok(res) => {
      match res {
        Some(c) => Ok(ws.on_upgrade(move |socket| client_connection(socket, user_id, clients.clone(), c, security, tms_event_service))),
        None => Err(warp::reject::not_found()),
      }
    },
    Err(_) => {
      error!("failed to get clients lock");
      Err(warp::reject::not_found())
    }
  }
}