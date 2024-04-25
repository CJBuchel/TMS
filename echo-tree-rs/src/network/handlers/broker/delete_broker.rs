use tms_infra::{client_socket_protocol::{DeleteEvent, EchoTreeClientSocketEvent, EchoTreeClientSocketMessage}, server_socket_protocol::{EchoItemEvent, StatusResponseEvent}};

use crate::common::{ClientMap, EchoDB, client_echo::ClientEcho, client_access::ClientAccess};


pub async fn delete_broker(uuid: String, msg: EchoTreeClientSocketMessage, clients: &ClientMap, db: &EchoDB) {
  let client = match clients.read().await.get(&uuid) {
    Some(c) => c.clone(),
    None => {
      log::warn!("{}: client not found", uuid);
      return;
    }
  };

  let msg: DeleteEvent = match serde_json::from_str(&msg.message.unwrap_or("".to_string())) {
    Ok(v) => v,
    Err(e) => {
      log::warn!("{}: {:?}", uuid, e);
      client.respond(StatusResponseEvent {
        status_code: warp::http::StatusCode::BAD_REQUEST.as_u16(),
        from_event: Some(EchoTreeClientSocketEvent::DeleteEvent),
        message: Some(format!("{:?}", e)),
      });
      return;
    }
  };

  // create list of un accessible tree names the client is trying to access
  let unauthorized_tree_names: Vec<String> = client.filter_unauthorized_read_write_trees(msg.tree_items.iter().map(|(t, _)| t.clone()).collect());
  let mut changed_items: Vec<EchoItemEvent> = Vec::new();
  
  let mut write_db = db.write().await;
  for (tree_name, key) in msg.tree_items {
    if client.has_read_write_access_to_tree(&tree_name) {
      let managed_tree = match write_db.get_tree_map_mut().await.get_tree_mut(tree_name.clone()) {
        Some(t) => t,
        None => {
          log::warn!("{}: tree not found: {}", uuid, tree_name);
          continue;
        }
      };

      match managed_tree.remove(key.as_bytes()) {
        Ok(_) => {
          let echo_item_event = EchoItemEvent {
            tree_name: tree_name.clone(),
            key: key.clone(),
            data: "".to_string(),
          };
          changed_items.push(echo_item_event);
          log::debug!("{}: tree item deleted: {}", uuid, key);
        },
        Err(e) => log::error!("{}: error deleting tree item: {}", uuid, e),
      }
    }
  }

  // echo the event to sll subscribed clients
  if !changed_items.is_empty() {
    for msg in changed_items {
      clients.read().await.echo_item(msg)
    }
  }

  if unauthorized_tree_names.is_empty() {
    client.respond(StatusResponseEvent {
      status_code: warp::http::StatusCode::OK.as_u16(),
      from_event: Some(EchoTreeClientSocketEvent::DeleteEvent),
      message: Some("ok".to_string()),
    });
  } else {
    log::debug!("{}: client does not have access to trees: {:?}", uuid, unauthorized_tree_names);
    client.respond(StatusResponseEvent {
      status_code: warp::http::StatusCode::UNAUTHORIZED.as_u16(),
      from_event: Some(EchoTreeClientSocketEvent::DeleteEvent),
      message: Some(format!("client does not have access to trees: {:?}", unauthorized_tree_names)),
    });
  }
}