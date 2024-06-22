use tms_infra::{TmsServerSocketEvent, TmsServerSocketMessage};

use super::{client::Client, ClientHashMap};

pub trait ClientPublish {
  // publish raw message
  fn publish_message(&self, msg: TmsServerSocketMessage);

  // publish specific methods
  fn publish_purge(&self);

  // publish timer events
  fn publish_start_countdown(&self);
  fn publish_start_timer(&self);
  fn publish_time_timer(&self, time: u32);
  fn publish_endgame_timer(&self, endgame_time: u32);
  fn publish_end_timer(&self);
  fn publish_stop_timer(&self);
  fn publish_reload_timer(&self);

  // publish match events
  fn publish_load_matches(&self, game_match_numbers: Vec<String>);
  fn publish_unload_matches(&self);
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

  //
  // Timer
  //
  fn publish_start_countdown(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchTimerStartCountdownEvent,
      message: None,
    };
    self.publish_message(msg);
  }

  fn publish_start_timer(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchTimerStartEvent,
      message: None,
    };
    self.publish_message(msg);
  }

  fn publish_time_timer(&self, time: u32) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchTimerTimeEvent,
      message: Some(time.to_string()),
    };
    self.publish_message(msg);
  }

  fn publish_endgame_timer(&self, endgame_time: u32) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchTimerEndgameEvent,
      message: Some(endgame_time.to_string()),
    };
    self.publish_message(msg);
  }

  fn publish_end_timer(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchTimerEndEvent,
      message: None,
    };
    self.publish_message(msg);
  }

  fn publish_stop_timer(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchTimerStopEvent,
      message: None,
    };
    self.publish_message(msg);
  }

  fn publish_reload_timer(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchTimerReloadEvent,
      message: None,
    };
    self.publish_message(msg);
  }

  //
  // Matches
  //
  fn publish_load_matches(&self, game_match_numbers: Vec<String>) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchLoadEvent,
      message: Some(serde_json::to_string(&game_match_numbers).unwrap_or_default()),
    };
    self.publish_message(msg);
  }

  fn publish_unload_matches(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchUnloadEvent,
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

  //
  // Timer
  //
  fn publish_start_countdown(&self) {
    for client in self.values() {
      client.publish_start_countdown();
    }
  }

  fn publish_end_timer(&self) {
    for client in self.values() {
      client.publish_end_timer();
    }
  }

  fn publish_endgame_timer(&self, endgame_time: u32) {
    for client in self.values() {
      client.publish_endgame_timer(endgame_time);
    }
  }

  fn publish_start_timer(&self) {
    for client in self.values() {
      client.publish_start_timer();
    }
  }

  fn publish_stop_timer(&self) {
    for client in self.values() {
      client.publish_stop_timer();
    }
  }

  fn publish_time_timer(&self, time: u32) {
    for client in self.values() {
      client.publish_time_timer(time);
    }
  }

  fn publish_reload_timer(&self) {
    for client in self.values() {
      client.publish_reload_timer();
    }
  }

  //
  // matches
  //
  fn publish_load_matches(&self, game_match_numbers: Vec<String>) {
    for client in self.values() {
      client.publish_load_matches(game_match_numbers.clone());
    }
  }

  fn publish_unload_matches(&self) {
    for client in self.values() {
      client.publish_unload_matches();
    }
  }


}