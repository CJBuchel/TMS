use tms_infra::{TmsServerSocketEvent, TmsServerSocketMessage};

use super::{client::Client, ClientHashMap};

pub trait ClientPublish {
  // publish raw message
  fn publish_message(&self, msg: TmsServerSocketMessage);

  // publish specific methods
  fn publish_purge(&self);
}

impl ClientPublish for Client {
  //
  // Generic
  //
  fn publish_message(&self, msg: TmsServerSocketMessage) {
    let json = serde_json::to_string(&msg).unwrap_or_default();
    self.send_message(json);
  }

  //
  // Config
  //
  fn publish_purge(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::PurgeEvent,
      message: None,
    };
    self.publish_message(msg);
  }
}

impl ClientPublish for ClientHashMap {
  //
  // Generic
  //
  fn publish_message(&self, msg: TmsServerSocketMessage) {
    for client in self.values() {
      client.publish_message(msg.clone());
    }
  }

  //
  // Configs
  //
  fn publish_purge(&self) {
    for client in self.values() {
      client.publish_purge();
    }
  }
}