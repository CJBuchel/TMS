use log::debug;
use echo_tree_infra::{client_socket_protocol::{EchoTreeClientSocketEvent, EchoTreeClientSocketMessage, SubscribeEvent}, server_socket_protocol::{EchoTreeEventTree, StatusResponseEvent}};
use crate::common::{client_echo::ClientEcho, ClientMap, EchoDB};

pub async fn subscribe_broker(uuid: String, msg: EchoTreeClientSocketMessage, clients: &ClientMap, db: &EchoDB) {
  
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

  log::info!("{}: subscribe {:?}", uuid, msg.tree_names);

  let new_tree_names: Vec<String> = msg.tree_names.iter().filter(|tree| !client.subscribed_trees.contains(tree)).cloned().collect();
  client.subscribed_trees.extend(new_tree_names);

  let read_db = db.read().await;
  let mut trees: Vec<EchoTreeEventTree> = Vec::new();
  for tree_name in client.clone().subscribed_trees {
    let tree = match read_db.get_tree_map().await.get_tree(tree_name.clone()) {
      Some(v) => v,
      None => {
        debug!("{}: tree not found", uuid);
        continue;
      }
    };

    let tree_map = match tree.get_as_hashmap() {
      Ok(v) => v,
      Err(e) => {
        debug!("{}: {:?}", uuid, e);
        client.respond(StatusResponseEvent {
          status_code: warp::http::StatusCode::INTERNAL_SERVER_ERROR.as_u16(),
          from_event: Some(EchoTreeClientSocketEvent::SubscribeEvent),
          message: Some(format!("{:?}", e)),
        });
        continue;
      }
    };

    trees.push(EchoTreeEventTree {
      tree_name: tree_name.clone(),
      tree: tree_map,
    });
  }

  clients.write().await.insert(uuid.clone(), client.clone());

  // echo the trees to the client
  client.echo_tree(trees);

  client.respond(StatusResponseEvent {
    status_code: warp::http::StatusCode::OK.as_u16(),
    from_event: Some(EchoTreeClientSocketEvent::SubscribeEvent),
    message: Some("subscribed".to_string()),
  });
}