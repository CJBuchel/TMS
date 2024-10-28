use echo_tree_infra::{client_socket_protocol::{ChecksumEvent, EchoTreeClientSocketEvent, EchoTreeClientSocketMessage}, server_socket_protocol::{EchoTreeEventTree, StatusResponseEvent}};

use crate::common::{client_echo::ClientEcho, client_access::ClientAccess, ClientMap, EchoDB};


pub async fn checksum_broker(uuid: String, msg: EchoTreeClientSocketMessage, clients: &ClientMap, db: &EchoDB) {
  let client = match clients.read().await.get(&uuid) {
    Some(c) => c.clone(),
    None => {
      log::warn!("{}: client not found", uuid);
      return;
    }
  };
  
  let msg: ChecksumEvent = match serde_json::from_str(&msg.message.unwrap_or("".to_string())) {
    Ok(v) => v,
    Err(e) => {
      log::error!("{}: {:?}", uuid, e);
      client.respond(StatusResponseEvent {
        status_code: warp::http::StatusCode::BAD_REQUEST.as_u16(),
        from_event: Some(EchoTreeClientSocketEvent::ChecksumEvent),
        message: Some(format!("{:?}", e)),
      });
      return;
    }
  };

  // check the checksums against the db trees
  let read_db = db.read().await;

  let mut new_client_trees: Vec<EchoTreeEventTree> = Vec::new();
  for (tree_name, checksum) in &msg.tree_checksums {
    if let Some(tree) = read_db.get_tree_map().await.get_tree(tree_name.to_string()) {

      // only check the checksum if the client has read access and is subscribed to the tree
      if client.has_read_access_and_subscribed_to_tree(tree_name) {
        if tree.get_checksum() != *checksum {

          let tree_name = tree.get_name();

          log::warn!("client {}: tree [{}] checksum mismatch: {} != {}", uuid, tree_name, tree.get_checksum(), checksum);

          if let Some(tree_hashmap) = tree.get_as_hashmap().ok() {
            new_client_trees.push(EchoTreeEventTree {
              tree_name: tree_name.clone(),
              tree: tree_hashmap,
            });
          }
        }
      } else {
        log::trace!("client {}: no read access or not subscribed to tree: {}, yet tried checksum", uuid, tree_name);
      }
    }
  }

  // echo the new trees to the client
  if !new_client_trees.is_empty() {
    client.echo_tree(new_client_trees);
  }

  client.respond(StatusResponseEvent {
    status_code: warp::http::StatusCode::OK.as_u16(),
    from_event: Some(EchoTreeClientSocketEvent::ChecksumEvent),
    message: Some("checksums checked".to_string()),
  });
}