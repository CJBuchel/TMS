//! The awards an event presents, how many places each has, and the ceremony order.

use dioxus::prelude::*;
use tms_core::deliberation::{Award, AwardKind, AwardPatch, NewAward};
use tms_core::dto::ReorderRequest;
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Card, DataTable, Select, TextField, Tone};
use uuid::Uuid;

use crate::components::{ConfirmButton, ErrorBox, NeedsActiveEvent, PageHeader, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::Realtime;
use crate::store::session::Session;

fn places_options(kind: AwardKind) -> Vec<(String, String)> {
  (1..=kind.max_places())
    .map(|p| (p.to_string(), p.to_string()))
    .collect()
}

#[component]
pub fn SetupAwards() -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let mut error = use_signal(|| None::<ApiFailure>);
  let mut refresh = use_signal(|| 0u32);
  let mut kind = use_signal(|| AwardKind::EngineeringExcellence);
  let mut name = use_signal(String::new);
  let mut places = use_signal(|| "1".to_owned());
  let event_id = realtime.stores.event.read().as_ref().map(|e| e.id);
  let awards = use_resource(move || async move {
    let _ = refresh();
    let event_id = realtime.stores.event.read().as_ref().map(|e| e.id)?;
    api::get::<Vec<Award>>(&format!("/events/{event_id}/awards"), token(session).as_deref())
      .await
      .ok()
  });
  let Some(event_id) = event_id else {
    return rsx! { PageHeader { title: "Awards" } NeedsActiveEvent {} };
  };
  let list: Vec<Award> = awards.read().clone().flatten().unwrap_or_default();
  let addable: Vec<AwardKind> = AwardKind::ALL
    .into_iter()
    .filter(|k| !k.required() && (*k == AwardKind::Local || !list.iter().any(|a| a.kind == *k)))
    .collect();
  let mut done = move |result: Result<(), ApiFailure>| {
    match result {
      Ok(()) => error.set(None),
      Err(e) => error.set(Some(e)),
    }
    refresh += 1;
  };
  let ids: Vec<Uuid> = list.iter().map(|a| a.id).collect();
  let reorder = move |ids: Vec<Uuid>| async move {
    let result = api::post::<_, Vec<Award>>(
      &format!("/events/{event_id}/awards/order"),
      token(session).as_deref(),
      &ReorderRequest { ids },
    )
    .await
    .map(|_| ());
    done(result);
  };
  let add = move |_| async move {
    let body = NewAward {
      kind: kind(),
      name: name(),
      places: places().parse().unwrap_or(1),
    };
    let result = api::post::<_, Award>(&format!("/events/{event_id}/awards"), token(session).as_deref(), &body)
      .await
      .map(|_| ());
    if result.is_ok() {
      name.set(String::new());
    }
    done(result);
  };
  let chosen = if addable.contains(&kind()) {
    kind()
  } else {
    addable.first().copied().unwrap_or(AwardKind::Local)
  };

  rsx! {
    Card { title: "Awards",
      p { class: "mb-3 text-sm text-muted",
        "Listed in ceremony order. The six required awards are always presented; optional and local awards are up to the tournament. Deliberation allocates them in the official order whatever the ceremony order."
      }
      if let Some(e) = error() {
        div { class: "mb-3", ErrorBox { error: e } }
      }
      DataTable {
        columns: vec!["Order".into(), "Award".into(), "Places".into(), String::new()],
        empty: "No awards.",
        rows: list
            .iter()
            .enumerate()
            .map(|(i, a)| {
                let id = a.id;
                let kind = a.kind;
                let (up, down) = (ids.clone(), ids.clone());
                rsx! {
                  tr { key: "{id}",
                    td { class: "whitespace-nowrap",
                      Button { size: ButtonSize::Small, variant: ButtonVariant::Ghost, disabled: i == 0,
                        onclick: move |_| { let mut ids = up.clone(); ids.swap(i, i - 1); reorder(ids) }, "↑" }
                      Button { size: ButtonSize::Small, variant: ButtonVariant::Ghost, disabled: i + 1 == ids.len(),
                        onclick: move |_| { let mut ids = down.clone(); ids.swap(i, i + 1); reorder(ids) }, "↓" }
                    }
                    td {
                      span { class: "font-semibold", "{a.name}" }
                      if kind.required() {
                        span { class: "ml-2", Badge { tone: Tone::Neutral, "Required" } }
                      }
                      if kind == AwardKind::Local {
                        span { class: "ml-2", Badge { tone: Tone::Info, "Local" } }
                      }
                    }
                    td { class: "w-28",
                      Select {
                        label: "",
                        value: a.places.to_string(),
                        options: places_options(kind),
                        onchange: move |v: String| async move {
                            let patch = AwardPatch { places: v.parse().ok(), ..AwardPatch::default() };
                            let result = api::patch::<_, Award>(&format!("/awards/{id}"), token(session).as_deref(), &patch).await.map(|_| ());
                            done(result);
                        },
                      }
                    }
                    td { class: "text-right",
                      if !kind.required() {
                        ConfirmButton {
                          label: "Remove",
                          title: "Remove this award?",
                          message: "It won't be allocated or presented.",
                          confirm_label: "Remove",
                          onconfirm: move |()| async move {
                              let result = api::delete(&format!("/awards/{id}"), token(session).as_deref()).await;
                              done(result);
                          },
                        }
                      }
                    }
                  }
                }
            })
            .collect(),
      }
      if !addable.is_empty() {
        div { class: "mt-4 grid items-end gap-3 sm:grid-cols-[1fr_1fr_8rem_auto]",
          Select {
            label: "Add an award",
            value: format!("{chosen:?}"),
            options: addable.iter().map(|k| (format!("{k:?}"), k.label().to_owned())).collect(),
            onchange: move |v: String| {
                if let Some(k) = AwardKind::ALL.into_iter().find(|k| format!("{k:?}") == v) {
                    kind.set(k);
                }
            },
          }
          TextField {
            label: "Name",
            value: name(),
            placeholder: if chosen == AwardKind::Local { "Required for a local award" } else { chosen.label() },
            oninput: move |v| name.set(v),
          }
          Select { label: "Places", value: places(), options: places_options(chosen), onchange: move |v| places.set(v) }
          Button {
            variant: ButtonVariant::Primary,
            onclick: move |e| {
                kind.set(chosen);
                add(e)
            },
            "Add"
          }
        }
      }
    }
  }
}
