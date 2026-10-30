//! The last data received for the topics a station needs, kept on the device. A page opened while the server is
//! unreachable starts from it, so a referee can still see the schedule and score a match.

use dioxus::prelude::*;
use gloo_storage::{LocalStorage, Storage};
use serde::Serialize;
use serde::de::DeserializeOwned;

use crate::net::realtime::Stores;

fn key(name: &str) -> String {
  format!("tms.cache.{name}")
}

/// The cached value, or the default when there is none (or it no longer parses after an update).
pub fn load<T: DeserializeOwned + Default>(name: &str) -> T {
  LocalStorage::get(key(name)).unwrap_or_default()
}

fn save<T: Serialize + 'static>(name: &'static str, signal: Signal<T>) {
  use_effect(move || {
    // Storage can be full or unavailable; the cache is a convenience.
    let _ = LocalStorage::set(key(name), &*signal.read());
  });
}

/// Writes each cached store whenever it changes.
#[allow(clippy::large_types_passed_by_value)]
pub fn use_cache_writer(stores: Stores) {
  save("event", stores.event);
  save("teams", stores.teams);
  save("tables", stores.tables);
  save("pods", stores.pods);
  save("matches", stores.matches);
  save("judging_sessions", stores.sessions);
  save("blocks", stores.blocks);
}
