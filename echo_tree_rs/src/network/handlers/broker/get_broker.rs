use echo_tree_infra::{client_socket_protocol::{EchoTreeClientSocketEvent, EchoTreeClientSocketMessage, GetEvent}, server_socket_protocol::{EchoItemEvent, StatusResponseEvent}};

use crate::common::{client_echo::ClientEcho, ClientMap, EchoDB, client_access::ClientAccess};

pub async fn get_broker(uuid: String, msg: EchoTreeClientSocketMessage, clients: &ClientMap, db: &EchoDB) {
  let client = match clients.read().await.get(&uuid) {
    Some(c) => c.clone(),
    None => {
      log::warn!("{}: client not found", uuid);
      return;
    }
  };

  let msg: GetEvent = match serde_json::from_str(&msg.message.unwrap_or("".to_string())) {
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

  // check if client has access to the tree
  if client.has_read_access_to_tree(&msg.tree_name) {
    // db access
    let read_db = db.read().await;
    // let res = read_db.get(msg.tree_name.clone(), msg.key.clone()).await;

    let res = match read_db.get_tree_map().await.get_tree(msg.tree_name.clone()) {
      Some(t) => {
        match t.get(msg.key.as_bytes()) {
          Ok(r) => r,
          Err(e) => {
            log::warn!("{}: {:?}", uuid, e);
            None
          }
        }
      },
      None => None,
    };

    let res = match res {
      Some(r) => String::from_utf8(r.to_vec()).unwrap_or_default(),
      None => {
        client.respond(StatusResponseEvent {
          status_code: warp::http::StatusCode::NOT_FOUND.as_u16(),
          from_event: Some(EchoTreeClientSocketEvent::GetEvent),
          message: Some("not found".to_string()),
        });
        return;
      }
    };
    
    let echo_event = EchoItemEvent {
      tree_name: msg.tree_name,
      key: msg.key,
      data: Some(res),
    };

    client.echo_item(echo_event);

    client.respond(StatusResponseEvent {
      status_code: warp::http::StatusCode::OK.as_u16(),
      from_event: Some(EchoTreeClientSocketEvent::GetEvent),
      message: Some("ok".to_string()),
    });

  } else {
    log::debug!("{}: client does not have access to tree: {}", uuid, msg.tree_name);
    client.respond(StatusResponseEvent {
      status_code: warp::http::StatusCode::UNAUTHORIZED.as_u16(),
      from_event: Some(EchoTreeClientSocketEvent::GetEvent),
      message: Some(format!("client does not have access to tree: {}", msg.tree_name)),
    });
    return;
  }
}