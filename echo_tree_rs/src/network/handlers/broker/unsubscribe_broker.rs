use log::debug;
use echo_tree_infra::{client_socket_protocol::{EchoTreeClientSocketEvent, EchoTreeClientSocketMessage, UnsubscribeEvent}, server_socket_protocol::StatusResponseEvent};
use crate::common::ClientMap;

pub async fn unsubscribe_broker(uuid:String, msg: EchoTreeClientSocketMessage, clients: &ClientMap) {
  let mut client = match clients.read().await.get(&uuid).cloned() {
    Some(c) => c,
    None => {
      debug!("{}: client not found", uuid);
      return;
    }
  };

  let msg: UnsubscribeEvent = match serde_json::from_str(&msg.message.unwrap_or("".to_string())) {
    Ok(v) => v,
    Err(e) => {
      debug!("{}: {:?}", uuid, e);
      client.respond(StatusResponseEvent {
        status_code: warp::http::StatusCode::BAD_REQUEST.as_u16(),
        from_event: Some(EchoTreeClientSocketEvent::UnsubscribeEvent),
        message: Some(format!("{:?}", e)),
      });
      return;
    }
  };

  log::debug!("{}: unsubscribe {:?}", uuid, msg.tree_names);

  // remove only the trees the client has
  let new_tree_names: Vec<String> = msg.tree_names.iter().filter(|tree| client.subscribed_trees.contains(tree)).cloned().collect();
  client.subscribed_trees.retain(|t| !new_tree_names.contains(t));

  clients.write().await.insert(uuid.clone(), client.clone());

  client.respond(StatusResponseEvent {
    status_code: warp::http::StatusCode::OK.as_u16(),
    from_event: Some(EchoTreeClientSocketEvent::UnsubscribeEvent),
    message: Some("unsubscribed".to_string()),
  });
}