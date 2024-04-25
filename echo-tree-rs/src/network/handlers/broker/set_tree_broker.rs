use log::warn;
use tms_infra::{
  client_socket_protocol::{EchoTreeClientSocketEvent, EchoTreeClientSocketMessage, SetTreeEvent},
  server_socket_protocol::{EchoTreeEventTree, StatusResponseEvent},
};

use crate::{common::{ClientMap, EchoDB, client_echo::ClientEcho, client_access::ClientAccess}, db::managed_tree::ManagedTree};

pub async fn set_tree_broker(uuid: String, msg: EchoTreeClientSocketMessage, clients: &ClientMap, db: &EchoDB) {
  let client = match clients.read().await.get(&uuid) {
    Some(c) => c.clone(),
    None => {
      log::warn!("{}: client not found", uuid);
      return;
    }
  };

  let msg: SetTreeEvent = match serde_json::from_str(&msg.message.unwrap_or("".to_string())) {
    Ok(v) => v,
    Err(e) => {
      log::warn!("{}: {:?}", uuid, e);
      client.respond(StatusResponseEvent {
        status_code: warp::http::StatusCode::BAD_REQUEST.as_u16(),
        from_event: Some(EchoTreeClientSocketEvent::SetTreeEvent),
        message: Some(format!("{:?}", e)),
      });
      return;
    }
  };

  // create list of tree names the client is trying to access
  let tree_names: Vec<String> = msg.trees.iter().map(|(t, _)| t.clone()).collect();
  let unauthorized_tree_names: Vec<String> = client.filter_unauthorized_read_write_trees(tree_names.clone());
  let mut changed_trees: Vec<ManagedTree> = Vec::new();

  // access db and set trees the client has access to
  let mut write_db = db.write().await;
  for (tree_name, tree) in msg.trees {
    if client.has_read_write_access_to_tree(&tree_name) {
      let managed_tree = match write_db.get_tree_map_mut().await.get_tree_mut(tree_name.clone()) {
        Some(t) => t,
        None => {
          warn!("{}: tree not found: {}", uuid, tree_name);
          continue;
        }
      };

      match managed_tree.set_from_hashmap(tree) {
        Ok(_) => {
          changed_trees.push(managed_tree.clone());
          log::debug!("{}: tree set: {}", uuid, tree_name);
        },
        Err(e) => log::error!("{}: error setting tree: {}", uuid, e),
      }
    }
  }

  if !changed_trees.is_empty() {
    let echo_event: Vec<EchoTreeEventTree> = changed_trees.iter().map(|t| {
      EchoTreeEventTree {
        tree_name: t.get_name(),
        tree: t.get_as_hashmap().unwrap_or_default(),
      }
    }).collect();
    clients.read().await.echo_tree(echo_event);
  }

  if unauthorized_tree_names.is_empty() {
    client.respond(StatusResponseEvent {
      status_code: warp::http::StatusCode::OK.as_u16(),
      from_event: Some(EchoTreeClientSocketEvent::SetTreeEvent),
      message: Some("trees set".to_string()),
    });
  } else {
    log::debug!(
      "{}: client does not have access to trees: {:?}",
      uuid,
      unauthorized_tree_names
    );
    client.respond(StatusResponseEvent {
      status_code: warp::http::StatusCode::UNAUTHORIZED.as_u16(),
      from_event: Some(EchoTreeClientSocketEvent::SetTreeEvent),
      message: Some(format!(
        "client does not have access to trees: {:?}",
        unauthorized_tree_names
      )),
    });
  }
}
