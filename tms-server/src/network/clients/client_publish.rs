use tms_infra::{DataSchemeExtensions, TmsServerMatchState, TmsServerMatchStateEvent, TmsServerMatchTimerEvent, TmsServerMatchTimerState, TmsServerSocketEvent, TmsServerSocketMessage};

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
  fn publish_endgame_timer(&self);
  fn publish_end_timer(&self);
  fn publish_stop_timer(&self);
  fn publish_reload_timer(&self);

  // publish match events
  fn publish_load_matches(&self, game_match_numbers: Vec<String>);
  fn publish_unload_matches(&self);
  fn publish_ready_matches(&self, game_match_numbers: Vec<String>);
  fn publish_running_matches(&self, game_match_numbers: Vec<String>);
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
      message_event: TmsServerSocketEvent::MatchTimerEvent,
      message: Some(TmsServerMatchTimerEvent {
        state: TmsServerMatchTimerState::StartWithCountdown,
        ..Default::default()
      }.to_json_string()),
    };
    self.publish_message(msg);
  }

  fn publish_start_timer(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchTimerEvent,
      message: Some(TmsServerMatchTimerEvent {
        state: TmsServerMatchTimerState::Start,
        ..Default::default()
      }.to_json_string()),
    };
    self.publish_message(msg);
  }

  fn publish_time_timer(&self, time: u32) {
    let msg_payload = TmsServerMatchTimerEvent {
      time: Some(time),
      state: TmsServerMatchTimerState::Time,
    };

    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
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
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchTimerEvent,
      message: Some(msg_payload.to_json_string()),
    };
    self.publish_message(msg);
  }

  fn publish_end_timer(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchTimerEvent,
      message: Some(TmsServerMatchTimerEvent {
        state: TmsServerMatchTimerState::End,
        ..Default::default()
      }.to_json_string()),
    };
    self.publish_message(msg);
  }

  fn publish_stop_timer(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchTimerEvent,
      message: Some(TmsServerMatchTimerEvent {
        state: TmsServerMatchTimerState::Stop,
        ..Default::default()
      }.to_json_string()),
    };
    self.publish_message(msg);
  }

  fn publish_reload_timer(&self) {
    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchTimerEvent,
      message: Some(TmsServerMatchTimerEvent {
        state: TmsServerMatchTimerState::Reload,
        ..Default::default()
      }.to_json_string()),
    };
    self.publish_message(msg);
  }

  //
  // Matches
  //
  fn publish_load_matches(&self, game_match_numbers: Vec<String>) {
    let msg_payload = TmsServerMatchStateEvent {
      state: TmsServerMatchState::Load,
      game_match_numbers,
      game_match_tables: vec![],
    };

    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchStateEvent,
      message: Some(msg_payload.to_json_string()),
    };
    self.publish_message(msg);
  }

  fn publish_unload_matches(&self) {
    let msd_payload = TmsServerMatchStateEvent {
      state: TmsServerMatchState::Unload,
      game_match_numbers: vec![],
      game_match_tables: vec![],
    };

    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchStateEvent,
      message: Some(msd_payload.to_json_string()),
    };
    self.publish_message(msg);
  }

  fn publish_ready_matches(&self, game_match_numbers: Vec<String>) {
    let msg_payload = TmsServerMatchStateEvent {
      state: TmsServerMatchState::Ready,
      game_match_numbers,
      game_match_tables: vec![],
    };

    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchStateEvent,
      message: Some(msg_payload.to_json_string()),
    };
    self.publish_message(msg);
  }


  fn publish_running_matches(&self, game_match_numbers: Vec<String>) {
    let msg_payload = TmsServerMatchStateEvent {
      state: TmsServerMatchState::Running,
      game_match_numbers,
      game_match_tables: vec![],
    };

    let msg = TmsServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: TmsServerSocketEvent::MatchStateEvent,
      message: Some(msg_payload.to_json_string()),
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

  fn publish_endgame_timer(&self) {
    for client in self.values() {
      client.publish_endgame_timer();
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

  fn publish_ready_matches(&self, game_match_numbers: Vec<String>) {
    for client in self.values() {
      client.publish_ready_matches(game_match_numbers.clone());
    }
  }

  fn publish_running_matches(&self, game_match_numbers: Vec<String>) {
    for client in self.values() {
      client.publish_running_matches(game_match_numbers.clone());
    }
  }
}