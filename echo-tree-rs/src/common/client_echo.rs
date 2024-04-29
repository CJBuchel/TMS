use tms_infra::server_socket_protocol::{EchoItemEvent, EchoTreeEvent, EchoTreeEventTree, EchoTreeServerSocketEvent, EchoTreeServerSocketMessage};

use super::{client::Client, ClientHashMap, client_access::ClientAccess};

pub trait ClientEcho {
  fn echo_tree(&self, msg: Vec<EchoTreeEventTree>);
  fn echo_item(&self, msg: EchoItemEvent);
}

impl ClientEcho for Client {
  fn echo_tree(&self, msg: Vec<EchoTreeEventTree>) {
    let filtered_subscribed_trees: Vec<EchoTreeEventTree> = msg
      .iter()
      .filter(|t| self.has_read_access_and_subscribed_to_tree(&t.tree_name))
      .map(|t| t.clone())
      .collect();

    if !filtered_subscribed_trees.is_empty() {
      let echo_message = EchoTreeServerSocketMessage {
        auth_token: self.auth_token.clone(),
        message_event: EchoTreeServerSocketEvent::EchoTreeEvent,
        message: Some(serde_json::to_string(&EchoTreeEvent {
          trees: filtered_subscribed_trees,
        }).unwrap_or_default()),
      };

      let json = serde_json::to_string(&echo_message).unwrap_or_default();
      self.send_message(json);
    } else {
      log::debug!("no trees to echo to client, client trees: {:?}", self.subscribed_trees);
    }
  }

  fn echo_item(&self, msg: EchoItemEvent) {
    if self.has_read_access_and_subscribed_to_tree(&msg.tree_name) {
      let echo_message = EchoTreeServerSocketMessage {
        auth_token: self.auth_token.clone(),
        message_event: EchoTreeServerSocketEvent::EchoItemEvent,
        message: Some(serde_json::to_string(&msg).unwrap_or_default()),
      };

      let json = serde_json::to_string(&echo_message).unwrap_or_default();
      self.send_message(json);
    } else {
      log::debug!("no items to echo to client, client trees: {:?}", self.subscribed_trees);
    }
  }
}

impl ClientEcho for ClientHashMap {
  fn echo_tree(&self, msg: Vec<EchoTreeEventTree>) {
    for (_, client) in self.iter() {
      client.echo_tree(msg.clone());
    }
  }

  fn echo_item(&self, msg: EchoItemEvent) {
    for (_, client) in self.iter() {
      client.echo_item(msg.clone());
    }
  }
}