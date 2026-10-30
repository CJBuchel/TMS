use dioxus::prelude::*;
use tms_core::dto::{PodInput, ReorderRequest, TableInput};
use tms_core::model::{GameTable, Pod};
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Card, Modal, TextField, Tone};
use uuid::Uuid;

use crate::components::{ConfirmButton, ErrorBox, NeedsActiveEvent, PageHeader, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::Realtime;
use crate::store::session::Session;

/// Shows the error of a failed request, or clears the previous one.
fn report(mut error: Signal<Option<ApiFailure>>, result: Result<(), ApiFailure>) {
  error.set(result.err());
}

/// "Pair 2 · B" for the table at position 3.
pub fn pair_label(position: usize) -> String {
  format!(
    "Pair {} · {}",
    position / 2 + 1,
    if position.is_multiple_of(2) { "A" } else { "B" }
  )
}

/// Moves the item at `index` by `delta` places and returns the new order of ids.
fn moved(ids: &[Uuid], index: usize, delta: isize) -> Option<Vec<Uuid>> {
  let target = index.checked_add_signed(delta)?;
  if target >= ids.len() {
    return None;
  }
  let mut order = ids.to_vec();
  order.swap(index, target);
  Some(order)
}

#[component]
pub fn SetupVenue() -> Element {
  let realtime = use_context::<Realtime>();
  let Some(event) = realtime.stores.event.read().clone() else {
    return rsx! { PageHeader { title: "Tables & pods" } NeedsActiveEvent {} };
  };
  rsx! {
    PageHeader {
      title: "Tables & pods",
      subtitle: "Tables play in pairs in list order: the first two face each other, then the next two.",
    }
    div { class: "grid gap-4 lg:grid-cols-2",
      Tables { event_id: event.id }
      Pods { event_id: event.id }
    }
  }
}

#[component]
fn Tables(event_id: Uuid) -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let mut new_name = use_signal(String::new);
  let mut renaming = use_signal(|| None::<GameTable>);
  let error = use_signal(|| None::<ApiFailure>);

  let mut tables = realtime.stores.tables.read().clone();
  tables.sort_by_key(|t| t.sort_order);
  let ids: Vec<Uuid> = tables.iter().map(|t| t.id).collect();

  let reorder = move |order: Vec<Uuid>| async move {
    let result = api::post::<_, Vec<GameTable>>(
      &format!("/events/{event_id}/tables/order"),
      token(session).as_deref(),
      &ReorderRequest { ids: order },
    )
    .await;
    report(error, result.map(|_| ()));
  };
  let add = move |e: FormEvent| async move {
    e.prevent_default();
    let result = api::post::<_, GameTable>(
      &format!("/events/{event_id}/tables"),
      token(session).as_deref(),
      &TableInput { name: new_name() },
    )
    .await;
    if result.is_ok() {
      new_name.set(String::new());
    }
    report(error, result.map(|_| ()));
  };
  let delete = move |id: Uuid| async move {
    report(
      error,
      api::delete(&format!("/tables/{id}"), token(session).as_deref()).await,
    );
  };

  rsx! {
    Card { title: "Competition tables",
      ul { class: "divide-y divide-line",
        if tables.is_empty() {
          li { class: "py-2 text-sm text-muted", "No tables yet." }
        }
        for (i , table) in tables.iter().enumerate() {
          li { key: "{table.id}", class: "flex items-center gap-2 py-1.5",
            Badge { tone: Tone::Neutral, {pair_label(i)} }
            span { class: "flex-1 font-medium", "{table.name}" }
            Button {
              variant: ButtonVariant::Ghost,
              size: ButtonSize::Small,
              disabled: i == 0,
              title: "Move up",
              onclick: {
                  let ids = ids.clone();
                  move |_| {
                      if let Some(order) = moved(&ids, i, -1) {
                          spawn(reorder(order));
                      }
                  }
              },
              "↑"
            }
            Button {
              variant: ButtonVariant::Ghost,
              size: ButtonSize::Small,
              disabled: i + 1 == ids.len(),
              title: "Move down",
              onclick: {
                  let ids = ids.clone();
                  move |_| {
                      if let Some(order) = moved(&ids, i, 1) {
                          spawn(reorder(order));
                      }
                  }
              },
              "↓"
            }
            Button {
              variant: ButtonVariant::Secondary,
              size: ButtonSize::Small,
              onclick: {
                  let table = table.clone();
                  move |_| renaming.set(Some(table.clone()))
              },
              "Rename"
            }
            ConfirmButton {
              label: "Delete",
              title: "Delete {table.name}?",
              message: "A table with matches in the schedule cannot be deleted.",
              confirm_label: "Delete table",
              onconfirm: {
                  let id = table.id;
                  move |()| {
                      spawn(delete(id));
                  }
              },
            }
          }
        }
      }
      form { class: "mt-3 flex items-end gap-2", onsubmit: add,
        div { class: "flex-1",
          TextField { label: "New table", value: new_name(), placeholder: "Red", oninput: move |v| new_name.set(v) }
        }
        Button { r#type: "submit", disabled: new_name().trim().is_empty(), "Add" }
      }
      if let Some(e) = error() {
        div { class: "mt-3", ErrorBox { error: e } }
      }
    }
    if let Some(table) = renaming() {
      NameDialog {
        title: "Rename table",
        name: table.name.clone(),
        room: None,
        onsave: move |(name, _): (String, Option<String>)| async move {
            let result = api::patch::<_, GameTable>(&format!("/tables/{}", table.id), token(session).as_deref(), &TableInput { name }).await;
            renaming.set(None);
            report(error, result.map(|_| ()));
        },
        onclose: move |()| renaming.set(None),
      }
    }
  }
}

#[component]
fn Pods(event_id: Uuid) -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let mut new_name = use_signal(String::new);
  let mut editing = use_signal(|| None::<Pod>);
  let error = use_signal(|| None::<ApiFailure>);

  let mut pods = realtime.stores.pods.read().clone();
  pods.sort_by_key(|p| p.sort_order);
  let ids: Vec<Uuid> = pods.iter().map(|p| p.id).collect();

  let reorder = move |order: Vec<Uuid>| async move {
    let result = api::post::<_, Vec<Pod>>(
      &format!("/events/{event_id}/pods/order"),
      token(session).as_deref(),
      &ReorderRequest { ids: order },
    )
    .await;
    report(error, result.map(|_| ()));
  };
  let add = move |e: FormEvent| async move {
    e.prevent_default();
    let body = PodInput {
      name: new_name(),
      room: None,
    };
    let result = api::post::<_, Pod>(&format!("/events/{event_id}/pods"), token(session).as_deref(), &body).await;
    if result.is_ok() {
      new_name.set(String::new());
    }
    report(error, result.map(|_| ()));
  };
  let delete = move |id: Uuid| async move {
    report(
      error,
      api::delete(&format!("/pods/{id}"), token(session).as_deref()).await,
    );
  };

  rsx! {
    Card { title: "Judging pods",
      ul { class: "divide-y divide-line",
        if pods.is_empty() {
          li { class: "py-2 text-sm text-muted", "No pods yet." }
        }
        for (i , pod) in pods.iter().enumerate() {
          li { key: "{pod.id}", class: "flex items-center gap-2 py-1.5",
            span { class: "flex-1",
              span { class: "font-medium", "{pod.name}" }
              if let Some(room) = &pod.room {
                span { class: "ml-2 text-sm text-muted", "{room}" }
              }
            }
            Button {
              variant: ButtonVariant::Ghost,
              size: ButtonSize::Small,
              disabled: i == 0,
              title: "Move up",
              onclick: {
                  let ids = ids.clone();
                  move |_| {
                      if let Some(order) = moved(&ids, i, -1) {
                          spawn(reorder(order));
                      }
                  }
              },
              "↑"
            }
            Button {
              variant: ButtonVariant::Ghost,
              size: ButtonSize::Small,
              disabled: i + 1 == ids.len(),
              title: "Move down",
              onclick: {
                  let ids = ids.clone();
                  move |_| {
                      if let Some(order) = moved(&ids, i, 1) {
                          spawn(reorder(order));
                      }
                  }
              },
              "↓"
            }
            Button {
              variant: ButtonVariant::Secondary,
              size: ButtonSize::Small,
              onclick: {
                  let pod = pod.clone();
                  move |_| editing.set(Some(pod.clone()))
              },
              "Edit"
            }
            ConfirmButton {
              label: "Delete",
              title: "Delete {pod.name}?",
              message: "A pod with judging sessions in the schedule cannot be deleted.",
              confirm_label: "Delete pod",
              onconfirm: {
                  let id = pod.id;
                  move |()| {
                      spawn(delete(id));
                  }
              },
            }
          }
        }
      }
      form { class: "mt-3 flex items-end gap-2", onsubmit: add,
        div { class: "flex-1",
          TextField { label: "New pod", value: new_name(), placeholder: "Pod 1", oninput: move |v| new_name.set(v) }
        }
        Button { r#type: "submit", disabled: new_name().trim().is_empty(), "Add" }
      }
      if let Some(e) = error() {
        div { class: "mt-3", ErrorBox { error: e } }
      }
    }
    if let Some(pod) = editing() {
      NameDialog {
        title: "Edit pod",
        name: pod.name.clone(),
        room: Some(pod.room.clone().unwrap_or_default()),
        onsave: move |(name, room): (String, Option<String>)| async move {
            let result = api::patch::<_, Pod>(&format!("/pods/{}", pod.id), token(session).as_deref(), &PodInput { name, room }).await;
            editing.set(None);
            report(error, result.map(|_| ()));
        },
        onclose: move |()| editing.set(None),
      }
    }
  }
}

/// Edits a name, and a room when `room` is given.
#[component]
fn NameDialog(
  title: String,
  name: String,
  room: Option<String>,
  onsave: EventHandler<(String, Option<String>)>,
  onclose: EventHandler<()>,
) -> Element {
  let has_room = room.is_some();
  let mut name = use_signal(|| name);
  let mut room = use_signal(|| room.unwrap_or_default());
  rsx! {
    Modal {
      title,
      onclose,
      footer: rsx! {
        Button { variant: ButtonVariant::Secondary, onclick: move |_| onclose.call(()), "Cancel" }
        Button {
          disabled: name().trim().is_empty(),
          onclick: move |_| onsave.call((name(), if has_room { Some(room()) } else { None })),
          "Save"
        }
      },
      div { class: "flex flex-col gap-3",
        TextField { label: "Name", value: name(), autofocus: true, oninput: move |v| name.set(v) }
        if has_room {
          TextField { label: "Room", value: room(), placeholder: "Optional", oninput: move |v| room.set(v) }
        }
      }
    }
  }
}
