use std::collections::HashMap;

use dioxus::prelude::*;
use tms_core::Role;
use tms_core::dto::{AccessKeySummary, CreateAccessKeyRequest, CreatedAccessKey};
use tms_ui::{Badge, Button, ButtonVariant, DataTable, Modal, Select, TextField, Tone};
use uuid::Uuid;

use crate::components::{ConfirmButton, ErrorBox, NeedsActiveEvent, PageHeader, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::Realtime;
use crate::store::session::Session;
use crate::time::format_datetime;

fn role_key(role: Role) -> String {
  serde_json::to_value(role)
    .ok()
    .and_then(|v| v.as_str().map(str::to_owned))
    .unwrap_or_default()
}

fn role_from_key(key: &str) -> Option<Role> {
  Role::ALL.into_iter().find(|r| role_key(*r) == key)
}

/// The address that logs a device in with `key`, for its QR code.
fn login_link(key: &str) -> String {
  let origin = web_sys::window()
    .and_then(|w| w.location().origin().ok())
    .unwrap_or_default();
  format!("{origin}/login?access={key}")
}

/// An SVG QR code of `text`.
fn qr_svg(text: &str) -> String {
  qrcode::QrCode::new(text.as_bytes())
    .map(|code| {
      code
        .render::<qrcode::render::svg::Color>()
        .min_dimensions(220, 220)
        .quiet_zone(true)
        .build()
    })
    .unwrap_or_default()
}

#[component]
pub fn SetupKeys() -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let mut version = use_signal(|| 0_u32);
  let event_id = realtime.stores.event.read().as_ref().map(|e| e.id);
  let keys = use_resource(move || async move {
    let _ = version();
    let event_id = realtime.stores.event.read().as_ref().map(|e| e.id)?;
    Some(api::get::<Vec<AccessKeySummary>>(&format!("/events/{event_id}/keys"), token(session).as_deref()).await)
  });
  let mut creating = use_signal(|| false);
  let mut created = use_signal(|| None::<CreatedAccessKey>);
  let mut cards = use_signal(Vec::<CreatedAccessKey>::new);
  let mut making = use_signal(|| false);
  let mut error = use_signal(|| None::<ApiFailure>);

  let Some(event_id) = event_id else {
    return rsx! { PageHeader { title: "Access keys" } NeedsActiveEvent {} };
  };
  let timezone = realtime
    .stores
    .event
    .read()
    .as_ref()
    .map(|e| e.timezone.clone())
    .unwrap_or_default();
  let places: HashMap<Uuid, String> = realtime
    .stores
    .tables
    .read()
    .iter()
    .map(|t| (t.id, format!("Table {}", t.name)))
    .chain(realtime.stores.pods.read().iter().map(|p| (p.id, p.name.clone())))
    .collect();

  let revoke = move |id: Uuid| async move {
    match api::post::<_, AccessKeySummary>(&format!("/keys/{id}/revoke"), token(session).as_deref(), &()).await {
      Ok(_) => error.set(None),
      Err(e) => error.set(Some(e)),
    }
    version += 1;
  };

  // One referee key per table and one judge key per pod, for every one that has no active key yet.
  let make_all = move |_| async move {
    let Some(Some(Ok(list))) = keys.peek().clone() else {
      return;
    };
    making.set(true);
    error.set(None);
    let covered: Vec<Uuid> = list
      .iter()
      .filter(|k| k.revoked_at.is_none())
      .filter_map(|k| k.table_id.or(k.pod_id))
      .collect();
    let mut tables = realtime.stores.tables.peek().clone();
    tables.sort_by_key(|t| t.sort_order);
    let mut pods = realtime.stores.pods.peek().clone();
    pods.sort_by_key(|p| p.sort_order);
    let wanted: Vec<CreateAccessKeyRequest> = tables
      .iter()
      .filter(|t| !covered.contains(&t.id))
      .map(|t| CreateAccessKeyRequest {
        label: format!("{} table", t.name),
        role: Role::Referee,
        table_id: Some(t.id),
        pod_id: None,
        expires_at: None,
      })
      .chain(
        pods
          .iter()
          .filter(|p| !covered.contains(&p.id))
          .map(|p| CreateAccessKeyRequest {
            label: p.name.clone(),
            role: Role::Judge,
            table_id: None,
            pod_id: Some(p.id),
            expires_at: None,
          }),
      )
      .collect();
    let mut made = Vec::new();
    for body in wanted {
      match api::post::<_, CreatedAccessKey>(&format!("/events/{event_id}/keys"), token(session).as_deref(), &body)
        .await
      {
        Ok(key) => made.push(key),
        Err(e) => {
          error.set(Some(e));
          break;
        }
      }
    }
    making.set(false);
    version += 1;
    if !made.is_empty() {
      cards.set(made);
    }
  };

  rsx! {
    PageHeader {
      title: "Access keys",
      subtitle: "One key per device or station. A key logs in without a password, works offline, and ends when revoked or when the event is archived.",
      actions: rsx! {
        Button { variant: ButtonVariant::Secondary, loading: making(), onclick: make_all, "Keys for every table and pod" }
        Button { onclick: move |_| creating.set(true), "Create key" }
      },
    }
    if let Some(e) = error() {
      div { class: "mb-3", ErrorBox { error: e } }
    }
    match &*keys.read() {
      None | Some(None) => rsx! { p { class: "text-sm text-muted", "Loading…" } },
      Some(Some(Err(e))) => rsx! { ErrorBox { error: e.clone() } },
      Some(Some(Ok(list))) => rsx! {
        DataTable {
          columns: vec!["Label".into(), "Role".into(), "For".into(), "Status".into(), "Last used".into(), String::new()],
          empty: "No keys yet.",
          rows: list
              .iter()
              .map(|k| {
                  let id = k.id;
                  let live = k.revoked_at.is_none();
                  let place = k.table_id.or(k.pod_id).and_then(|id| places.get(&id).cloned()).unwrap_or_else(|| "–".into());
                  let last = k.last_used_at.map_or_else(|| "never".into(), |t| format_datetime(t, &timezone));
                  rsx! {
                    tr {
                      td { "{k.label}" }
                      td {
                        for role in k.roles.iter() {
                          Badge { tone: Tone::Primary, "{role.label()}" }
                        }
                      }
                      td { "{place}" }
                      td {
                        if live {
                          Badge { tone: Tone::Success, "Active" }
                        } else {
                          Badge { tone: Tone::Danger, "Revoked" }
                        }
                      }
                      td { class: "whitespace-nowrap text-muted", "{last}" }
                      td { class: "text-right",
                        if live {
                          ConfirmButton {
                            label: "Revoke",
                            title: "Revoke {k.label}?",
                            message: "Devices using this key are logged out at once and cannot log in with it again.",
                            confirm_label: "Revoke key",
                            onconfirm: move |()| { spawn(revoke(id)); },
                          }
                        }
                      }
                    }
                  }
              })
              .collect(),
        }
      },
    }
    if creating() {
      KeyForm {
        event_id,
        onclose: move |()| creating.set(false),
        oncreated: move |key| {
            creating.set(false);
            created.set(Some(key));
            version += 1;
        },
      }
    }
    if let Some(key) = created() {
      ShowKey { created: key, onclose: move |()| created.set(None) }
    }
    if !cards().is_empty() {
      KeyCards { keys: cards(), onclose: move |()| cards.set(Vec::new()) }
    }
  }
}

#[component]
fn KeyForm(event_id: Uuid, onclose: EventHandler<()>, oncreated: EventHandler<CreatedAccessKey>) -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let mut label = use_signal(String::new);
  let mut role = use_signal(|| Role::Referee);
  let mut place = use_signal(String::new);
  let mut error = use_signal(|| None::<ApiFailure>);
  let mut busy = use_signal(|| false);

  let bind_table = matches!(role(), Role::Referee | Role::HeadReferee);
  let bind_pod = matches!(role(), Role::Judge | Role::JudgeAdvisor);
  let mut place_options = vec![(String::new(), "Not bound".to_owned())];
  if bind_table {
    let mut tables = realtime.stores.tables.read().clone();
    tables.sort_by_key(|t| t.sort_order);
    place_options.extend(
      tables
        .into_iter()
        .map(|t| (t.id.to_string(), format!("Table {}", t.name))),
    );
  }
  if bind_pod {
    let mut pods = realtime.stores.pods.read().clone();
    pods.sort_by_key(|p| p.sort_order);
    place_options.extend(pods.into_iter().map(|p| (p.id.to_string(), p.name)));
  }
  let roles: Vec<(String, String)> = Role::ALL
    .iter()
    .filter(|r| **r != Role::Admin)
    .map(|r| (role_key(*r), r.label().to_owned()))
    .collect();

  let save = move |_| async move {
    busy.set(true);
    error.set(None);
    let chosen = place().parse::<Uuid>().ok();
    let body = CreateAccessKeyRequest {
      label: label(),
      role: role(),
      table_id: chosen.filter(|_| bind_table),
      pod_id: chosen.filter(|_| bind_pod),
      expires_at: None,
    };
    match api::post::<_, CreatedAccessKey>(&format!("/events/{event_id}/keys"), token(session).as_deref(), &body).await
    {
      Ok(key) => oncreated.call(key),
      Err(e) => error.set(Some(e)),
    }
    busy.set(false);
  };

  rsx! {
    Modal {
      title: "Create access key",
      onclose,
      footer: rsx! {
        Button { variant: ButtonVariant::Secondary, onclick: move |_| onclose.call(()), "Cancel" }
        Button { loading: busy(), disabled: label().trim().is_empty(), onclick: save, "Create key" }
      },
      div { class: "flex flex-col gap-3",
        TextField { label: "Label", value: label(), placeholder: "Red table iPad", autofocus: true, oninput: move |v| label.set(v) }
        Select {
          label: "Role",
          value: role_key(role()),
          options: roles,
          onchange: move |v: String| {
              if let Some(r) = role_from_key(&v) {
                  role.set(r);
                  place.set(String::new());
              }
          },
        }
        if bind_table || bind_pod {
          Select {
            label: if bind_table { "Table" } else { "Pod" },
            value: place(),
            options: place_options,
            onchange: move |v| place.set(v),
          }
        }
        if let Some(e) = error() {
          ErrorBox { error: e }
        }
      }
    }
  }
}

/// The key text, shown once, with a QR code to scan into the device.
#[component]
fn ShowKey(created: CreatedAccessKey, onclose: EventHandler<()>) -> Element {
  let key = created;
  let svg = qr_svg(&login_link(&key.key));
  let text = key.key.clone();
  let mut copied = use_signal(|| false);
  rsx! {
    Modal {
      title: "Key for {key.summary.label}",
      onclose,
      footer: rsx! {
        Button {
          variant: ButtonVariant::Secondary,
          onclick: move |_| {
              let js = format!("navigator.clipboard && navigator.clipboard.writeText({:?})", text);
              document::eval(&js);
              copied.set(true);
          },
          if copied() { "Copied" } else { "Copy" }
        }
        Button { onclick: move |_| onclose.call(()), "Done" }
      },
      p { class: "mb-3", "Scan the code with the device's camera to log it in, or type the key on its login page. It is shown only now; if it is lost, revoke it and create another." }
      p { class: "rounded-control mb-3 border border-line-strong bg-surface-2 px-4 py-3 text-center font-mono text-2xl tracking-widest", "{key.key}" }
      div { class: "mx-auto w-56 bg-white p-2 [&>svg]:h-auto [&>svg]:w-full", dangerous_inner_html: "{svg}" }
    }
  }
}

/// A printable sheet of new keys, one card per device, each with a QR code that logs the device in. Shown only
/// now, like any new key.
#[component]
fn KeyCards(keys: Vec<CreatedAccessKey>, onclose: EventHandler<()>) -> Element {
  rsx! {
    div { class: "tms-print fixed inset-0 z-50 overflow-auto bg-white p-6 text-black", "data-testid": "key-cards",
      div { class: "mb-5 flex flex-wrap items-center justify-between gap-3 print:hidden",
        div {
          h2 { class: "text-2xl font-bold tracking-tight", "Access key cards" }
          p { class: "text-sm text-gray-600", "Shown only now. Print them and cut out one card per device, or scan each code from this screen." }
        }
        div { class: "flex gap-2",
          Button { variant: ButtonVariant::Secondary, onclick: move |_| { document::eval("window.print()"); }, "Print" }
          Button { onclick: move |_| onclose.call(()), "Done" }
        }
      }
      div { class: "grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4 print:grid-cols-3",
        for k in keys {
          div { key: "{k.summary.id}", class: "flex break-inside-avoid flex-col items-center gap-2 rounded-lg border border-gray-300 p-4 text-center",
            p { class: "text-lg font-bold", "{k.summary.label}" }
            p { class: "text-sm text-gray-600",
              {k.summary.roles.iter().map(|r| r.label()).collect::<Vec<_>>().join(", ")}
            }
            div { class: "w-40 [&>svg]:h-auto [&>svg]:w-full", dangerous_inner_html: "{qr_svg(&login_link(&k.key))}" }
            p { class: "font-mono text-sm tracking-wider", "{k.key}" }
            p { class: "text-xs text-gray-600", "Scan with the tablet's camera, or type the key on the login page." }
          }
        }
      }
    }
  }
}
