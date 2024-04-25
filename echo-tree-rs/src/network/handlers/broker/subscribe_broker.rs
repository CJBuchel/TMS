use log::debug;
use tms_infra::{client_socket_protocol::{EchoTreeClientSocketEvent, EchoTreeClientSocketMessage, SubscribeEvent}, server_socket_protocol::StatusResponseEvent};
use crate::common::ClientMap;

pub async fn subscribe_broker(uuid: String, msg: EchoTreeClientSocketMessage, clients: &ClientMap) {
  
  let mut client = match clients.read().await.get(&uuid).cloned() {
    Some(c) => c,
    None => {
      debug!("{}: client not found", uuid);
      return;
    }
  };
  
  let msg: SubscribeEvent = match serde_json::from_str(&msg.message.unwrap_or("".to_string())) {
    Ok(v) => v,
    Err(e) => {
      debug!("{}: {:?}", uuid, e);
      client.respond(StatusResponseEvent {
        status_code: warp::http::StatusCode::BAD_REQUEST.as_u16(),
        from_event: Some(EchoTreeClientSocketEvent::SubscribeEvent),
        message: Some(format!("{:?}", e)),
      });
      return;
    }
  };

  let new_tree_names: Vec<String> = msg.tree_names.iter().filter(|tree| !client.subscribed_trees.contains(tree)).cloned().collect();
  client.subscribed_trees.extend(new_tree_names);

  clients.write().await.insert(uuid.clone(), client.clone());

  client.respond(StatusResponseEvent {
    status_code: warp::http::StatusCode::OK.as_u16(),
    from_event: Some(EchoTreeClientSocketEvent::SubscribeEvent),
    message: Some("subscribed".to_string()),
  });
}