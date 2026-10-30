use dioxus::prelude::*;
use tms_core::dto::VersionInfo;
use tms_core::ws::PROTOCOL_VERSION;
use tms_ui::{Badge, Card, DataTable, KeyValue, Select, Tone};

use crate::net::api;
use crate::net::realtime::{ConnStatus, Realtime};
use crate::pages::ChangePassword;
use crate::pages::device_sheets::DeviceSheets;
use crate::store::session::{Session, SessionState};
use crate::store::theme::{Theme, ThemeMode};

#[component]
pub fn Settings() -> Element {
  let session = use_context::<Session>();
  rsx! {
    div { class: "mb-4", DeviceSheets {} }
    div { class: "grid gap-4 lg:grid-cols-2",
      Appearance {}
      Connection {}
      SessionInfo {}
      if matches!(session.read(), SessionState::Online { key: None, .. }) {
        ChangePassword { forced: false }
      }
      Subscriptions {}
    }
  }
}

#[component]
fn Appearance() -> Element {
  let mut theme = use_context::<Theme>();
  let options = ThemeMode::ALL
    .iter()
    .map(|m| (m.key().to_owned(), m.label().to_owned()))
    .collect();
  rsx! {
    Card { title: "Appearance",
      Select { label: "Theme", value: theme.mode().key(), options, onchange: move |v: String| theme.set(ThemeMode::from_key(&v)) }
    }
  }
}

#[component]
fn Connection() -> Element {
  let realtime = use_context::<Realtime>();
  let version = use_resource(|| async { api::get::<VersionInfo>("/version", None).await.ok() });
  let status = *realtime.stores.status.read();
  let offset = *realtime.stores.offset_ms.read();
  let (tone, label) = match status {
    ConnStatus::Online => (Tone::Success, "Online"),
    ConnStatus::Connecting => (Tone::Warning, "Connecting"),
    ConnStatus::Offline => (Tone::Danger, "Offline"),
  };
  let server = match &*version.read() {
    Some(Some(v)) => format!("{} (protocol {})", v.version, v.protocol),
    Some(None) => "unreachable".to_owned(),
    None => "checking…".to_owned(),
  };
  rsx! {
    Card { title: "Connection",
      dl {
        KeyValue { label: "Status", Badge { tone, "{label}" } }
        KeyValue { label: "Clock offset", match offset { Some(ms) => rsx! { "{ms} ms" }, None => rsx! { "not measured" } } }
        KeyValue { label: "Server version", "{server}" }
        KeyValue { label: "Client version", "{env!(\"CARGO_PKG_VERSION\")} (protocol {PROTOCOL_VERSION})" }
      }
    }
  }
}

#[component]
fn SessionInfo() -> Element {
  let session = use_context::<Session>();
  let state = session.read();
  let (kind, expires) = match &state {
    SessionState::Online {
      key: Some(_),
      expires_at,
      ..
    } => ("Access key, verified", Some(expires_at.to_rfc3339())),
    SessionState::Online { expires_at, .. } => ("Password login", Some(expires_at.to_rfc3339())),
    SessionState::OfflineKey { rejected: true, .. } => ("Access key, rejected by server", None),
    SessionState::OfflineKey { .. } => ("Access key, not yet verified", None),
    SessionState::LoggedOut => ("Logged out", None),
  };
  let roles: Vec<&str> = state.roles().into_iter().map(tms_core::Role::label).collect();
  rsx! {
    Card { title: "Session",
      dl {
        KeyValue { label: "Logged in as", "{state.display_name()}" }
        KeyValue { label: "Type", "{kind}" }
        KeyValue { label: "Roles", "{roles.join(\", \")}" }
        if let Some(expires) = expires {
          KeyValue { label: "Session expires", span { class: "font-mono text-xs", "{expires}" } }
        }
      }
    }
  }
}

/// What this device is listening to: local reference counts and the set last sent to the server.
#[component]
fn Subscriptions() -> Element {
  let realtime = use_context::<Realtime>();
  let sent = realtime.stores.sent_topics.read().clone();
  let rows = realtime
    .registry_counts()
    .into_iter()
    .map(|(topic, count)| {
      let on_server = sent.contains(&topic);
      rsx! {
        tr {
          td { class: "font-mono", "{topic}" }
          td { "{count}" }
          td {
            if on_server {
              Badge { tone: Tone::Success, "Subscribed" }
            } else {
              Badge { tone: Tone::Warning, "Pending" }
            }
          }
        }
      }
    })
    .collect();
  rsx! {
    Card { title: "Live subscriptions",
      DataTable { columns: vec!["Topic".into(), "Users on this page".into(), "Server".into()], empty: "None", rows }
    }
  }
}
