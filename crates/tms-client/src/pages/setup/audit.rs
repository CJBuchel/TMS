use std::fmt::Write;

use dioxus::prelude::*;
use tms_core::dto::AuditEntry;
use tms_ui::{Badge, Button, ButtonVariant, DataTable, Select};

use crate::components::{ErrorBox, PageHeader, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::Realtime;
use crate::store::session::Session;
use crate::time::format_datetime;

const PAGE: usize = 50;
const ENTITIES: [(&str, &str); 9] = [
  ("", "Everything"),
  ("event", "Events and imports"),
  ("team", "Teams"),
  ("table", "Tables"),
  ("pod", "Pods"),
  ("block", "Timetable"),
  ("user", "Users"),
  ("access_key", "Access keys"),
  ("banner", "Banners"),
];

#[component]
pub fn SetupAudit() -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let mut entity = use_signal(String::new);
  let mut entries = use_signal(Vec::<AuditEntry>::new);
  let mut more = use_signal(|| false);
  let mut error = use_signal(|| None::<ApiFailure>);

  let load = move |before: Option<i64>| async move {
    let mut path = format!("/audit?limit={PAGE}");
    if !entity().is_empty() {
      let _ = write!(path, "&entity_type={}", entity());
    }
    if let Some(before) = before {
      let _ = write!(path, "&before={before}");
    }
    match api::get::<Vec<AuditEntry>>(&path, token(session).as_deref()).await {
      Ok(page) => {
        more.set(page.len() == PAGE);
        if before.is_some() {
          entries.write().extend(page);
        } else {
          entries.set(page);
        }
        error.set(None);
      }
      Err(e) => error.set(Some(e)),
    }
  };
  use_effect(move || {
    let _ = entity();
    spawn(load(None));
  });

  let timezone = realtime
    .stores
    .event
    .read()
    .as_ref()
    .map_or_else(|| "UTC".to_owned(), |e| e.timezone.clone());
  let options: Vec<(String, String)> = ENTITIES
    .iter()
    .map(|(k, v)| ((*k).to_owned(), (*v).to_owned()))
    .collect();
  rsx! {
    PageHeader { title: "Audit log", subtitle: "Every change, who made it and when. Newest first." }
    div { class: "mb-3 max-w-xs",
      Select { label: "Show", value: entity(), options, onchange: move |v| entity.set(v) }
    }
    if let Some(e) = error() {
      div { class: "mb-3", ErrorBox { error: e } }
    }
    DataTable {
      columns: vec!["When".into(), "Who".into(), "What".into(), "Details".into()],
      empty: "Nothing recorded yet.",
      rows: entries
          .read()
          .iter()
          .map(|e| {
              let details = if e.data.as_object().is_some_and(serde_json::Map::is_empty) { String::new() } else { e.data.to_string() };
              rsx! {
                tr {
                  td { class: "whitespace-nowrap", {format_datetime(e.at, &timezone)} }
                  td { class: "font-mono text-xs", "{e.actor}" }
                  td {
                    Badge { "{e.action}" }
                  }
                  td { class: "max-w-md truncate font-mono text-xs text-muted", title: "{details}", "{details}" }
                }
              }
          })
          .collect(),
    }
    if more() {
      div { class: "mt-3",
        Button {
          variant: ButtonVariant::Secondary,
          onclick: move |_| {
              let before = entries.read().last().map(|e| e.id);
              spawn(load(before));
          },
          "Load older"
        }
      }
    }
  }
}
