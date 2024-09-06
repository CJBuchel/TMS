use crate::network::clients::*;
use tms_infra::*;

pub trait ClientGameMatchEvents {
  // publish match events
  fn publish_load_matches(&self, game_match_numbers: Vec<String>);
  fn publish_unload_matches(&self);
  fn publish_ready_matches(&self, game_match_numbers: Vec<String>);
  fn publish_running_matches(&self, game_match_numbers: Vec<String>);
}

impl ClientGameMatchEvents for Client {
  fn publish_load_matches(&self, game_match_numbers: Vec<String>) {
    let msg_payload = TmsServerMatchStateEvent {
      state: TmsServerMatchState::Load,
      game_match_numbers,
    };

    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.to_owned(),
      message_event: TmsServerSocketEvent::MatchStateEvent,
      message: Some(msg_payload.to_json_string()),
    };
    self.publish_message(msg);
  }

  fn publish_unload_matches(&self) {
    let msd_payload = TmsServerMatchStateEvent {
      state: TmsServerMatchState::Unload,
      game_match_numbers: vec![],
    };

    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.to_owned(),
      message_event: TmsServerSocketEvent::MatchStateEvent,
      message: Some(msd_payload.to_json_string()),
    };
    self.publish_message(msg);
  }

  fn publish_ready_matches(&self, game_match_numbers: Vec<String>) {
    let msg_payload = TmsServerMatchStateEvent {
      state: TmsServerMatchState::Ready,
      game_match_numbers,
    };

    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.to_owned(),
      message_event: TmsServerSocketEvent::MatchStateEvent,
      message: Some(msg_payload.to_json_string()),
    };
    self.publish_message(msg);
  }

  fn publish_running_matches(&self, game_match_numbers: Vec<String>) {
    let msg_payload = TmsServerMatchStateEvent {
      state: TmsServerMatchState::Running,
      game_match_numbers,
    };

    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.to_owned(),
      message_event: TmsServerSocketEvent::MatchStateEvent,
      message: Some(msg_payload.to_json_string()),
    };
    self.publish_message(msg);
  }
}

impl ClientGameMatchEvents for ClientHashMap {
  fn publish_load_matches(&self, game_match_numbers: Vec<String>) {
    for client in self.values() {
      client.publish_load_matches(game_match_numbers.to_owned());
    }
  }

  fn publish_unload_matches(&self) {
    for client in self.values() {
      client.publish_unload_matches();
    }
  }

  fn publish_ready_matches(&self, game_match_numbers: Vec<String>) {
    for client in self.values() {
      client.publish_ready_matches(game_match_numbers.to_owned());
    }
  }

  fn publish_running_matches(&self, game_match_numbers: Vec<String>) {
    for client in self.values() {
      client.publish_running_matches(game_match_numbers.to_owned());
    }
  }
}