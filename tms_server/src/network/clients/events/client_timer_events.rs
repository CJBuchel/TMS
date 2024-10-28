use crate::network::clients::*;
use tms_infra::*;

pub trait ClientTimerEvents {
  // publish timer events
  fn publish_start_countdown(&self);
  fn publish_start_timer(&self);
  fn publish_time_timer(&self, time: u32);
  fn publish_endgame_timer(&self);
  fn publish_end_timer(&self);
  fn publish_stop_timer(&self);
  fn publish_reload_timer(&self);
}

impl ClientTimerEvents for Client {
  fn publish_start_countdown(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.to_owned(),
      message_event: TmsServerSocketEvent::MatchTimerEvent,
      message: Some(
        TmsServerMatchTimerEvent {
          state: TmsServerMatchTimerState::StartWithCountdown,
          ..Default::default()
        }
        .to_json_string(),
      ),
    };
    self.publish_message(msg);
  }

  fn publish_start_timer(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.to_owned(),
      message_event: TmsServerSocketEvent::MatchTimerEvent,
      message: Some(
        TmsServerMatchTimerEvent {
          state: TmsServerMatchTimerState::Start,
          ..Default::default()
        }
        .to_json_string(),
      ),
    };
    self.publish_message(msg);
  }

  fn publish_time_timer(&self, time: u32) {
    let msg_payload = TmsServerMatchTimerEvent {
      time: Some(time),
      state: TmsServerMatchTimerState::Time,
    };

    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.to_owned(),
      message_event: TmsServerSocketEvent::MatchTimerEvent,
      message: Some(msg_payload.to_json_string()),
    };
    self.publish_message(msg);
  }

  fn publish_endgame_timer(&self) {
    let msg_payload = TmsServerMatchTimerEvent {
      time: None,
      state: TmsServerMatchTimerState::Endgame,
    };

    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.to_owned(),
      message_event: TmsServerSocketEvent::MatchTimerEvent,
      message: Some(msg_payload.to_json_string()),
    };
    self.publish_message(msg);
  }

  fn publish_end_timer(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.to_owned(),
      message_event: TmsServerSocketEvent::MatchTimerEvent,
      message: Some(
        TmsServerMatchTimerEvent {
          state: TmsServerMatchTimerState::End,
          ..Default::default()
        }
        .to_json_string(),
      ),
    };
    self.publish_message(msg);
  }

  fn publish_stop_timer(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.to_owned(),
      message_event: TmsServerSocketEvent::MatchTimerEvent,
      message: Some(
        TmsServerMatchTimerEvent {
          state: TmsServerMatchTimerState::Stop,
          ..Default::default()
        }
        .to_json_string(),
      ),
    };
    self.publish_message(msg);
  }

  fn publish_reload_timer(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.to_owned(),
      message_event: TmsServerSocketEvent::MatchTimerEvent,
      message: Some(
        TmsServerMatchTimerEvent {
          state: TmsServerMatchTimerState::Reload,
          ..Default::default()
        }
        .to_json_string(),
      ),
    };
    self.publish_message(msg);
  }
}

impl ClientTimerEvents for ClientHashMap {
  fn publish_start_countdown(&self) {
    for client in self.values() {
      client.publish_start_countdown();
    }
  }

  fn publish_start_timer(&self) {
    for client in self.values() {
      client.publish_start_timer();
    }
  }

  fn publish_time_timer(&self, time: u32) {
    for client in self.values() {
      client.publish_time_timer(time);
    }
  }

  fn publish_endgame_timer(&self) {
    for client in self.values() {
      client.publish_endgame_timer();
    }
  }

  fn publish_end_timer(&self) {
    for client in self.values() {
      client.publish_end_timer();
    }
  }

  fn publish_stop_timer(&self) {
    for client in self.values() {
      client.publish_stop_timer();
    }
  }

  fn publish_reload_timer(&self) {
    for client in self.values() {
      client.publish_reload_timer();
    }
  }
}