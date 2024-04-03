use database::SharedDatabase;
use futures::{FutureExt, StreamExt};
use crate::{client::Client, filters::Unauthorized, ClientMap};

async fn client_msg(uuid: String, msg: warp::filters::ws::Message, clients: &ClientMap, db: &SharedDatabase) {
  log::debug!("{}: message: {:?}", uuid, msg);
}

async fn client_connection(ws: warp::ws::WebSocket, uuid: String, clients: ClientMap, mut client: Client, db: SharedDatabase) {
  let (client_ws_tx, mut client_ws_rx) = ws.split();
  let (client_sender, client_receiver) = tokio::sync::mpsc::unbounded_channel();
  
  // spawn messaging task
  let client_receiver = tokio_stream::wrappers::UnboundedReceiverStream::new(client_receiver);
  tokio::task::spawn(client_receiver.forward(client_ws_tx).map(|result| {
    if let Err(e) = result {
      log::error!("websocket send error: {}", e);
    }
  }));

  client.sender = Some(client_sender.clone());
  clients.write().await.insert(uuid.clone(), client);

  log::info!("{} connected, client count: {}", uuid, clients.read().await.len());

  // start ping task (used for continuous network checks)
  let ping_uuid = uuid.clone();
  let ping_task = tokio::spawn(async move {
    loop {
      tokio::time::sleep(tokio::time::Duration::from_secs(10)).await;
      log::debug!("{}: client ping", ping_uuid);
      let ping_m = warp::filters::ws::Message::ping("");
      if client_sender.send(Ok(ping_m)).is_err() {
        log::warn!("{}: client ping failed, breaking task...", ping_uuid);
        break;
      }
    }
  });

  // start message handling loop
  while let Some(result) = client_ws_rx.next().await {
    let msg = match result {
      Ok(msg) => {
        if msg.is_close() {
          break;
        } else if msg.is_pong() {
          log::debug!("{}: client pong", uuid);
          continue;
        } else {
          msg
        }
      },
      Err(e) => {
        log::error!("{}: websocket error: {}", uuid, e);
        break;
      }
    };

    client_msg(uuid.clone(), msg, &clients, &db).await;
  }

  ping_task.abort();
  clients.write().await.remove(&uuid);
  log::info!("{} disconnected, client count: {}", uuid, clients.read().await.len());
}

pub async fn websocket_handler(ws: warp::ws::Ws, uuid: String, clients: ClientMap, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let client_id = uuid.clone();
  let client = clients.read().await.get(&client_id).cloned();
  match client {
    Some(client) => {
      Ok(ws.on_upgrade(move |socket| client_connection(socket, uuid, clients, client, db)))
    },
    None => {
      log::warn!("Client not found: {}", client_id);
      Err(warp::reject::custom(Unauthorized))
    }
  }
}