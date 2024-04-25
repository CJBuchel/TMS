use tms_infra::{client_socket_protocol::{EchoTreeClientSocketEvent, EchoTreeClientSocketMessage, GetTreeEvent}, server_socket_protocol::{EchoTreeEventTree, StatusResponseEvent}};

use crate::common::{client_echo::ClientEcho, ClientMap, EchoDB, client_access::ClientAccess};


pub async fn get_tree_broker(uuid: String, msg: EchoTreeClientSocketMessage, clients: &ClientMap, db: &EchoDB) {
  let client = match clients.read().await.get(&uuid) {
    Some(c) => c.clone(),
    None => {
      log::warn!("{}: client not found", uuid);
      return;
    }
  };

  let msg: GetTreeEvent = match serde_json::from_str(&msg.message.unwrap_or("".to_string())) {
    Ok(v) => v,
    Err(e) => {
      log::warn!("{}: {:?}", uuid, e);
      client.respond(StatusResponseEvent {
        status_code: warp::http::StatusCode::BAD_REQUEST.as_u16(),
        from_event: Some(EchoTreeClientSocketEvent::GetEvent),
        message: Some(format!("{:?}", e)),
      });
      return;
    }
  };

  // filter for accessible trees
  let accessible_trees = client.filter_read_accessible_trees(msg.tree_names);
  
  // get the trees
  let read_db = db.read().await;
  let mut trees: Vec<EchoTreeEventTree> = Vec::new();

  for t in accessible_trees {
    let tree = match read_db.get_tree_map().await.get_tree(t.clone()) {
      Some(v) => v,
      None => {
        log::warn!("{}: tree not found", uuid);
        continue;
      }
    };

    let tree_map = match tree.get_as_hashmap() {
      Ok(v) => v,
      Err(e) => {
        log::warn!("{}: {:?}", uuid, e);
        client.respond(StatusResponseEvent {
          status_code: warp::http::StatusCode::INTERNAL_SERVER_ERROR.as_u16(),
          from_event: Some(EchoTreeClientSocketEvent::GetEvent),
          message: Some(format!("{:?}", e)),
        });
        continue;
      }
    };

    trees.push(EchoTreeEventTree {
      tree_name: t.clone(),
      tree: tree_map,
    });
  }

  client.echo_tree(trees);

  client.respond(StatusResponseEvent {
    status_code: warp::http::StatusCode::OK.as_u16(),
    from_event: Some(EchoTreeClientSocketEvent::GetEvent),
    message: None,
  });
}