
use crate::network::clients::*;
use tms_infra::*;

pub trait ClientGameTableEvents {
  // publish table events
  fn publish_not_ready_signal(&self, table: String, team_number: String);
  fn publish_ready_signal(&self, table: String, team_number: String);
}

impl ClientGameTableEvents for Client {
  fn publish_not_ready_signal(&self, table: String, team_number: String) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.to_owned(),
      message_event: TmsServerSocketEvent::TableStateEvent,
      message: Some(
        TmsServerTableStateEvent {
          table,
          team_number,
        }
        .to_json_string(),
      ),
    };
    self.publish_message(msg);
  }

  fn publish_ready_signal(&self, table: String, team_number: String) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.to_owned(),
      message_event: TmsServerSocketEvent::TableStateEvent,
      message: Some(
        TmsServerTableStateEvent {
          table,
          team_number,
        }
        .to_json_string(),
      ),
    };
    self.publish_message(msg);
  }
}

impl ClientGameTableEvents for ClientHashMap {
  fn publish_not_ready_signal(&self, table: String, team_number: String) {
    for client in self.values() {
      client.publish_not_ready_signal(table.to_owned(), team_number.to_owned());
    }
  }

  fn publish_ready_signal(&self, table: String, team_number: String) {
    for client in self.values() {
      client.publish_ready_signal(table.to_owned(), team_number.to_owned());
    }
  }
}