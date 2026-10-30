//! Who this device is logged in as. Persisted in localStorage so a reopened app lands where it was.
//!
//! An access key is kept on the device (it is the device's credential, issued per table or pod) so the
//! app can log in again without a person, and so it can start in offline mode before the server is reachable.

use chrono::{DateTime, TimeDelta, Utc};
use dioxus::prelude::*;
use gloo_storage::{LocalStorage, Storage};
use serde::{Deserialize, Serialize};
use tms_core::Role;
use tms_core::dto::{AuthResponse, Identity, Principal};

const STORAGE_KEY: &str = "tms.session";

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize, Default)]
pub enum SessionState {
  #[default]
  LoggedOut,
  /// Verified by the server. `key` is set when the session came from an access key.
  Online {
    token: String,
    expires_at: DateTime<Utc>,
    identity: Identity,
    key: Option<String>,
  },
  /// An access key entered while the server was unreachable. The role comes from the key prefix.
  /// `rejected` is set if the server later refused the key.
  OfflineKey { key: String, role: Role, rejected: bool },
}

impl SessionState {
  pub fn token(&self) -> Option<&str> {
    match self {
      SessionState::Online { token, .. } => Some(token),
      _ => None,
    }
  }

  pub fn roles(&self) -> Vec<Role> {
    match self {
      SessionState::LoggedOut => Vec::new(),
      SessionState::Online { identity, .. } => identity.roles.clone(),
      SessionState::OfflineKey { role, .. } => vec![*role],
    }
  }

  pub fn display_name(&self) -> String {
    match self {
      SessionState::LoggedOut => String::new(),
      SessionState::Online { identity, .. } => match &identity.principal {
        Principal::User { display_name, .. } => display_name.clone(),
        Principal::Key { label, .. } => label.clone(),
      },
      SessionState::OfflineKey { key, .. } => key.split('-').next().unwrap_or_default().to_owned() + " key",
    }
  }

  pub fn must_change_password(&self) -> bool {
    matches!(self, SessionState::Online { identity, .. } if identity.must_change_password)
  }

  pub fn from_auth(auth: AuthResponse, key: Option<String>) -> Self {
    if let (Some(key), Principal::Key { table_id, pod_id, .. }) = (&key, &auth.identity.principal) {
      let _ = LocalStorage::set(table_key(key), table_id);
      let _ = LocalStorage::set(pod_key(key), pod_id);
    }
    SessionState::Online {
      token: auth.token,
      expires_at: auth.expires_at,
      identity: auth.identity,
      key,
    }
  }
}

fn table_key(key: &str) -> String {
  format!("tms.key-table.{key}")
}

/// The table an access key was bound to the last time the server confirmed it, so a station that starts offline
/// with that key still knows its table.
pub fn remembered_table(key: &str) -> Option<uuid::Uuid> {
  LocalStorage::get::<Option<uuid::Uuid>>(table_key(key)).ok().flatten()
}

fn pod_key(key: &str) -> String {
  format!("tms.key-pod.{key}")
}

/// The pod an access key was bound to the last time the server confirmed it.
pub fn remembered_pod(key: &str) -> Option<uuid::Uuid> {
  LocalStorage::get::<Option<uuid::Uuid>>(pod_key(key)).ok().flatten()
}

/// The pod this device's login is bound to: the access key's pod, remembered while the key is unverified.
pub fn bound_pod(session: &SessionState) -> Option<uuid::Uuid> {
  match session {
    SessionState::Online { identity, .. } => match &identity.principal {
      Principal::Key { pod_id, .. } => *pod_id,
      Principal::User { .. } => None,
    },
    SessionState::OfflineKey { key, .. } => remembered_pod(key),
    SessionState::LoggedOut => None,
  }
}

/// Context handle. Every write goes through `set` so it is persisted.
#[derive(Clone, Copy)]
pub struct Session(Signal<SessionState>);

impl Session {
  pub fn load() -> Self {
    Self(Signal::new(LocalStorage::get(STORAGE_KEY).unwrap_or_default()))
  }

  pub fn read(&self) -> SessionState {
    self.0.read().clone()
  }

  /// Read without subscribing the current component (for tasks and event handlers).
  pub fn peek(&self) -> SessionState {
    self.0.peek().clone()
  }

  pub fn set(&mut self, state: SessionState) {
    // Storage can be unavailable (private mode); the session then lasts for this page load only.
    let _ = match &state {
      SessionState::LoggedOut => {
        LocalStorage::delete(STORAGE_KEY);
        Ok(())
      }
      s => LocalStorage::set(STORAGE_KEY, s),
    };
    self.0.set(state);
  }
}

/// Login tokens expire (12 h for a password login, 24 h for a key), so a long day at a station would otherwise
/// end in a logout. Every 10 minutes, a token with less than 6 hours left is swapped for a fresh one.
pub fn use_token_refresh(mut session: Session) {
  const CHECK_EVERY_MS: u32 = 10 * 60 * 1000;
  let refresh_within = TimeDelta::hours(6);
  use_future(move || async move {
    loop {
      gloo_timers::future::TimeoutFuture::new(CHECK_EVERY_MS).await;
      let SessionState::Online {
        token, expires_at, key, ..
      } = session.peek()
      else {
        continue;
      };
      if expires_at - Utc::now() > refresh_within {
        continue;
      }
      // Failures are left alone: an expired or revoked token is handled by the live feed's recovery path.
      if let Ok(auth) = crate::net::api::post::<_, AuthResponse>("/auth/refresh", Some(&token), &()).await {
        session.set(SessionState::from_auth(auth, key));
      }
    }
  });
}
