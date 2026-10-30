//! Which station devices are connected right now. A WebSocket logged in with an access key joins on connect and
//! leaves when it closes, so the head referee sees a table's device drop off the moment it does.

use std::collections::HashMap;
use std::sync::{Arc, Mutex};

use chrono::Utc;
use tms_core::Role;
use tms_core::Topic;
use tms_core::dto::Identity;
use tms_core::dto::Principal;
use tms_core::queue::Presence;
use tms_core::ws::TopicItem;
use uuid::Uuid;

use crate::bus::Bus;

pub struct PresenceHub {
  /// Key id to (event id, presence).
  keys: Mutex<HashMap<Uuid, (Uuid, Presence)>>,
  bus: Bus,
}

/// Leaves when dropped.
pub struct PresenceGuard {
  hub: Arc<PresenceHub>,
  key_id: Uuid,
}

impl PresenceHub {
  pub fn new(bus: Bus) -> Self {
    Self {
      keys: Mutex::default(),
      bus,
    }
  }

  /// Marks a key's device as connected. Password logins are people, not stations, and are not listed.
  pub fn join(self: &Arc<Self>, identity: &Identity) -> Option<PresenceGuard> {
    let Principal::Key {
      key_id,
      event_id,
      label,
      table_id,
      pod_id,
    } = &identity.principal
    else {
      return None;
    };
    let presence = {
      let mut keys = self.keys.lock().expect("presence map poisoned");
      let entry = keys.entry(*key_id).or_insert_with(|| {
        (
          *event_id,
          Presence {
            key_id: *key_id,
            label: label.clone(),
            role: identity.roles.first().copied().unwrap_or(Role::Display),
            table_id: *table_id,
            pod_id: *pod_id,
            connections: 0,
            since: Utc::now(),
            waiting: 0,
          },
        )
      });
      entry.1.connections += 1;
      entry.1.clone()
    };
    self.bus.upsert(Topic::Presence, TopicItem::Presence(presence));
    Some(PresenceGuard {
      hub: Arc::clone(self),
      key_id: *key_id,
    })
  }

  fn leave(&self, key_id: Uuid) {
    let remaining = {
      let mut keys = self.keys.lock().expect("presence map poisoned");
      let Some(entry) = keys.get_mut(&key_id) else {
        return;
      };
      entry.1.connections -= 1;
      if entry.1.connections == 0 {
        keys.remove(&key_id);
        None
      } else {
        Some(entry.1.clone())
      }
    };
    match remaining {
      Some(presence) => self.bus.upsert(Topic::Presence, TopicItem::Presence(presence)),
      None => self.bus.delete(Topic::Presence, key_id),
    }
  }

  /// Records what a connected device reports it still holds, and tells those watching.
  pub fn set_waiting(&self, key_id: Uuid, waiting: u32) {
    let changed = {
      let mut keys = self.keys.lock().expect("presence map poisoned");
      match keys.get_mut(&key_id) {
        Some(entry) if entry.1.waiting != waiting => {
          entry.1.waiting = waiting;
          Some(entry.1.clone())
        }
        _ => None,
      }
    };
    if let Some(presence) = changed {
      self.bus.upsert(Topic::Presence, TopicItem::Presence(presence));
    }
  }

  /// The connected devices of one event.
  pub fn list(&self, event_id: Uuid) -> Vec<Presence> {
    let keys = self.keys.lock().expect("presence map poisoned");
    let mut list: Vec<Presence> = keys
      .values()
      .filter(|(event, _)| *event == event_id)
      .map(|(_, p)| p.clone())
      .collect();
    list.sort_by(|a, b| a.label.cmp(&b.label));
    list
  }
}

impl Drop for PresenceGuard {
  fn drop(&mut self) {
    self.hub.leave(self.key_id);
  }
}
