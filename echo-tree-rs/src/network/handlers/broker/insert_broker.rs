use tms_infra::{client_socket_protocol::{EchoTreeClientSocketEvent, EchoTreeClientSocketMessage, InsertEvent}, server_socket_protocol::{EchoItemEvent, StatusResponseEvent}};

use crate::common::{ClientMap, EchoDB, client_echo::ClientEcho, client_access::ClientAccess};


pub async fn insert_broker(uuid: String, msg: EchoTreeClientSocketMessage, clients: &ClientMap, db: &EchoDB) {
  let client = match clients.read().await.get(&uuid) {
    Some(c) => c.clone(),
    None => {
      log::warn!("{}: client not found", uuid);
      return;
    }
  };

  let msg: InsertEvent = match serde_json::from_str(&msg.message.unwrap_or("".to_string())) {
    Ok(v) => v,
    Err(e) => {
      log::warn!("{}: {:?}", uuid, e);
      client.respond(StatusResponseEvent {
        status_code: warp::http::StatusCode::BAD_REQUEST.as_u16(),
        from_event: Some(EchoTreeClientSocketEvent::InsertEvent),
        message: Some(format!("{:?}", e)),
      });
      return;
    }
  };

  // check if client has access to the tree
  if client.has_read_write_access_to_tree(&msg.tree_name) {
    // db access
    let mut write_db = db.write().await;
    let tree = write_db.get_tree_map_mut().await.get_tree_mut(msg.tree_name.clone());
    let res = match tree {
      Some(t) => {
        match t.insert(msg.key.as_bytes(), msg.data.as_bytes()) {
          Ok(r) => r,
          Err(e) => {
            log::warn!("{}: {:?}", uuid, e);
            None
          }
        }
      },
      None => {
        log::debug!("{}: tree not found: {}", uuid, msg.tree_name);
        client.respond(StatusResponseEvent {
          status_code: warp::http::StatusCode::NOT_FOUND.as_u16(),
          from_event: Some(EchoTreeClientSocketEvent::InsertEvent),
          message: Some(format!("tree not found: {}", msg.tree_name)),
        });
        return;
      }
    };

    match res {
      Some(_) => (),
      None => {
        client.respond(StatusResponseEvent {
          status_code: warp::http::StatusCode::INTERNAL_SERVER_ERROR.as_u16(),
          from_event: Some(EchoTreeClientSocketEvent::InsertEvent),
          message: Some("internal server error".to_string()),
        });
        return;
      }
    };

    let echo_event = EchoItemEvent {
      tree_name: msg.tree_name.clone(),
      key: msg.key.clone(),
      data: msg.data.clone(),
    };

    // echo the event to sll subscribed clients
    clients.read().await.echo_item(echo_event);

    // respond to the client success
    client.respond(StatusResponseEvent {
      status_code: warp::http::StatusCode::OK.as_u16(),
      from_event: Some(EchoTreeClientSocketEvent::InsertEvent),
      message: Some(format!("inserted: {} {} {}", msg.tree_name, msg.key, msg.data)),
    });
  } else {
    log::debug!("{}: client does not have access to tree: {}", uuid, msg.tree_name);
    client.respond(StatusResponseEvent {
      status_code: warp::http::StatusCode::UNAUTHORIZED.as_u16(),
      from_event: Some(EchoTreeClientSocketEvent::InsertEvent),
      message: Some(format!("client does not have access to tree: {}", msg.tree_name)),
    });
    return;
  }
}