use tms_infra::{TmsServerSocketEvent, TmsServerSocketMessage};

use super::{client::Client, ClientHashMap};

pub trait ClientPublish {
  // publish raw message
  fn publish_message(&self, msg: TmsServerSocketMessage);

  // publish specific methods
  fn publish_purge(&self);
}

impl ClientPublish for Client {
  fn publish_message(&self, msg: TmsServerSocketMessage) {
    let json = serde_json::to_string(&msg).unwrap_or_default();
    self.send_message(json);
  }

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
  fn publish_message(&self, msg: TmsServerSocketMessage) {
    for (_, client) in self.iter() {
      client.publish_message(msg.clone());
    }
  }

  fn publish_purge(&self) {
    for (_, client) in self.iter() {
      client.publish_purge();
    }
  }
}