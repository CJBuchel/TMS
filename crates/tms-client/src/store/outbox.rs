//! Scoresheets and rubrics kept on this device until the server has them. Every document goes here first, so one
//! made offline (or when the server is unreachable) is never lost, and one the server can't place waits for a
//! person.
//!
//! Stored in localStorage: a device holds at most a day or two of its own documents, a few kilobytes each, so the
//! simpler synchronous store is plenty (IndexedDB would add an async layer for no gain at this size).

use chrono::{DateTime, Utc};
use dioxus::prelude::*;
use futures::StreamExt;
use gloo_storage::{LocalStorage, Storage};
use serde::de::DeserializeOwned;
use serde::{Deserialize, Serialize};
use tms_core::game::{
  ScoresheetDoc, ScoresheetStatus, SyncOutcome, SyncResult, SyncScoresheetsRequest, SyncScoresheetsResponse,
};
use tms_core::judging::{RubricDoc, RubricStatus, SyncRubricsRequest, SyncRubricsResponse};
use tms_core::model::MatchKind;
use uuid::Uuid;

use crate::net::api::{self, ApiFailure};
use crate::net::realtime::{ConnStatus, Realtime};
use crate::store::session::Session;

const STORAGE_KEY: &str = "tms.outbox";
const BATCH: usize = 50;
/// While anything is waiting, try again this often even if nothing else happens.
const RETRY_MS: u32 = 10_000;

/// A document the device made. The tag is `document`, not `kind`: a scoresheet has a `kind` of its own (ranking
/// or practice), and two `kind` keys made stored sheets unreadable after a reload.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "document", rename_all = "snake_case")]
pub enum Document {
  Scoresheet(ScoresheetDoc),
  Rubric(RubricDoc),
}

impl Document {
  pub fn id(&self) -> Uuid {
    match self {
      Document::Scoresheet(d) => d.id,
      Document::Rubric(d) => d.id,
    }
  }

  pub fn event_id(&self) -> Uuid {
    match self {
      Document::Scoresheet(d) => d.event_id,
      Document::Rubric(d) => d.event_id,
    }
  }

  pub fn event_code(&self) -> &str {
    match self {
      Document::Scoresheet(d) => &d.event_code,
      Document::Rubric(d) => &d.event_code,
    }
  }

  pub fn team_number(&self) -> &str {
    match self {
      Document::Scoresheet(d) => &d.team_number,
      Document::Rubric(d) => &d.team_number,
    }
  }

  pub fn created_at(&self) -> DateTime<Utc> {
    match self {
      Document::Scoresheet(d) => d.created_at,
      Document::Rubric(d) => d.created_at,
    }
  }

  /// "Ranking round 2 scoresheet, 70 points" or "Rubrics".
  pub fn describe(&self) -> String {
    match self {
      Document::Scoresheet(d) => format!(
        "{} round {} scoresheet, {} points",
        d.kind.label(),
        d.round.map_or_else(|| "?".to_owned(), |r| r.to_string()),
        d.score
      ),
      Document::Rubric(_) => "Rubrics".to_owned(),
    }
  }

  /// A scoresheet's kind, for choosing its round when binding.
  pub fn match_kind(&self) -> Option<MatchKind> {
    match self {
      Document::Scoresheet(d) => Some(d.kind),
      Document::Rubric(_) => None,
    }
  }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "state", rename_all = "snake_case")]
pub enum OutboxState {
  /// Waiting to be sent.
  Pending,
  /// The server has it. `counted` is true once it counts (a published sheet, accepted rubrics).
  Sent { status: String, counted: bool },
  /// The server can't tell which team (or round) it is for; a person fixes it here.
  NeedsBinding { reason: String },
  /// The server refused it, for example one from another event.
  Rejected { message: String },
}

impl OutboxState {
  pub fn label(&self) -> &'static str {
    match self {
      OutboxState::Pending => "Waiting to send",
      OutboxState::Sent { .. } => "Sent",
      OutboxState::NeedsBinding { .. } => "Needs a team or round",
      OutboxState::Rejected { .. } => "Refused",
    }
  }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct OutboxItem {
  pub doc: Document,
  pub state: OutboxState,
  pub attempts: u32,
  /// The last network problem, while still pending.
  pub last_error: Option<String>,
  pub updated_at: DateTime<Utc>,
}

/// Context handle for the outbox.
#[derive(Clone, Copy)]
pub struct Outbox {
  items: Signal<Vec<OutboxItem>>,
  kick: Coroutine<()>,
}

impl Outbox {
  pub fn items(&self) -> Vec<OutboxItem> {
    self.items.read().clone()
  }

  pub fn state_of(&self, id: Uuid) -> Option<OutboxState> {
    self
      .items
      .read()
      .iter()
      .find(|i| i.doc.id() == id)
      .map(|i| i.state.clone())
  }

  pub fn pending(&self) -> usize {
    self
      .items
      .read()
      .iter()
      .filter(|i| i.state == OutboxState::Pending)
      .count()
  }

  /// Keeps a new document and tries to send it right away.
  pub fn add(&mut self, doc: Document) {
    self.change(|items| {
      items.retain(|i| i.doc.id() != doc.id());
      items.push(OutboxItem {
        doc,
        state: OutboxState::Pending,
        attempts: 0,
        last_error: None,
        updated_at: Utc::now(),
      });
    });
    self.kick.send(());
  }

  /// Fixes the team (and, for a scoresheet, the round) of a document the server couldn't place, and sends it again.
  pub fn bind(&mut self, id: Uuid, team_number: String, round: Option<i32>) {
    self.change(|items| {
      if let Some(item) = items.iter_mut().find(|i| i.doc.id() == id) {
        match &mut item.doc {
          Document::Scoresheet(d) => {
            d.team_number = team_number;
            d.round = round.or(d.round);
            d.slot_id = None;
          }
          Document::Rubric(d) => {
            d.team_number = team_number;
            d.slot_id = None;
          }
        }
        item.state = OutboxState::Pending;
        item.updated_at = Utc::now();
      }
    });
    self.kick.send(());
  }

  pub fn retry(&mut self, id: Uuid) {
    self.change(|items| {
      if let Some(item) = items.iter_mut().find(|i| i.doc.id() == id) {
        item.state = OutboxState::Pending;
        item.updated_at = Utc::now();
      }
    });
    self.kick.send(());
  }

  pub fn remove(&mut self, id: Uuid) {
    self.change(|items| items.retain(|i| i.doc.id() != id));
  }

  /// Forgets every document the server already has.
  pub fn clear_sent(&mut self) {
    self.change(|items| items.retain(|i| !matches!(i.state, OutboxState::Sent { .. })));
  }

  fn change(&mut self, f: impl FnOnce(&mut Vec<OutboxItem>)) {
    let mut items = self.items.write();
    f(&mut items);
    // Storage can be unavailable (private mode); the outbox then lasts for this page load only.
    let _ = LocalStorage::set(STORAGE_KEY, &*items);
  }
}

/// Creates the outbox and its sending worker. Call once, in the root component, after the live feed.
// `Realtime` is a bundle of `Copy` signal handles; passing it by value is the intended use.
#[allow(clippy::large_types_passed_by_value)]
pub fn use_outbox_provider(session: Session, realtime: Realtime) -> Outbox {
  let items = use_signal(load);
  let kick = use_coroutine(move |mut rx: UnboundedReceiver<()>| async move {
    loop {
      flush(items, session, realtime).await;
      let waiting = items.peek().iter().any(|i| i.state == OutboxState::Pending);
      // Sleep until kicked, or retry on a timer while documents are waiting.
      if waiting {
        let timer = gloo_timers::future::TimeoutFuture::new(RETRY_MS);
        futures::select! {
          _ = rx.next() => {},
          () = futures::FutureExt::fuse(timer) => {},
        }
      } else if rx.next().await.is_none() {
        return;
      }
      while rx.try_recv().is_ok() {}
    }
  });
  let outbox = use_context_provider(|| Outbox { items, kick });

  // A reconnect is the moment offline documents can go.
  use_effect(move || {
    if *realtime.stores.status.read() == ConnStatus::Online {
      kick.send(());
    }
  });
  use_hook(move || watch_visibility(move || kick.send(())));
  outbox
}

/// The documents kept on this device. Ones that can't be read are set aside under another key rather than
/// overwritten, so nothing a referee or judge made is lost to a format change.
fn load() -> Vec<OutboxItem> {
  match LocalStorage::get::<Vec<OutboxItem>>(STORAGE_KEY) {
    Ok(items) => items,
    Err(gloo_storage::errors::StorageError::KeyNotFound(_)) => Vec::new(),
    Err(e) => {
      dioxus::logger::tracing::error!(error = %e, "the documents kept on this device could not be read; set aside");
      if let Ok(raw) = LocalStorage::raw().get_item(STORAGE_KEY)
        && let Some(raw) = raw
      {
        let _ = LocalStorage::raw().set_item(
          &format!("{STORAGE_KEY}.unreadable.{}", Utc::now().timestamp_millis()),
          &raw,
        );
      }
      Vec::new()
    }
  }
}

/// What a sync answer means for the device.
fn state_of<S>(outcome: SyncOutcome<S>, describe: fn(S) -> (String, bool)) -> OutboxState {
  match outcome {
    SyncOutcome::Accepted { status } | SyncOutcome::Duplicate { status } => {
      let (status, counted) = describe(status);
      OutboxState::Sent { status, counted }
    }
    SyncOutcome::NeedsBinding { reason } => OutboxState::NeedsBinding { reason },
    SyncOutcome::Rejected { message, issues, .. } => {
      let details: Vec<String> = issues.into_iter().map(|i| i.message).collect();
      OutboxState::Rejected {
        message: if details.is_empty() {
          message
        } else {
          format!("{message} {}", details.join(" "))
        },
      }
    }
  }
}

fn scoresheet_status(status: ScoresheetStatus) -> (String, bool) {
  (status.label().to_lowercase(), status == ScoresheetStatus::Published)
}

fn rubric_status(status: RubricStatus) -> (String, bool) {
  (status.label().to_lowercase(), status == RubricStatus::Accepted)
}

/// Sends every pending document of the active event, in batches, and records each outcome.
#[allow(clippy::large_types_passed_by_value)]
async fn flush(items: Signal<Vec<OutboxItem>>, session: Session, realtime: Realtime) {
  let Some(token) = session.peek().token().map(str::to_owned) else {
    // An unverified offline key has no token yet; the live feed verifies it on reconnect.
    return;
  };
  let Some(event_id) = realtime.stores.event.peek().as_ref().map(|e| e.id) else {
    return;
  };
  let pending: Vec<Document> = items
    .peek()
    .iter()
    .filter(|i| i.state == OutboxState::Pending && i.doc.event_id() == event_id)
    .map(|i| i.doc.clone())
    .collect();
  let sheets: Vec<ScoresheetDoc> = pending
    .iter()
    .filter_map(|d| {
      if let Document::Scoresheet(s) = d {
        Some(s.clone())
      } else {
        None
      }
    })
    .take(BATCH)
    .collect();
  let rubrics: Vec<RubricDoc> = pending
    .iter()
    .filter_map(|d| {
      if let Document::Rubric(r) = d {
        Some(r.clone())
      } else {
        None
      }
    })
    .take(BATCH)
    .collect();
  if !sheets.is_empty() {
    let ids: Vec<Uuid> = sheets.iter().map(|s| s.id).collect();
    let response = api::post::<_, SyncScoresheetsResponse>(
      "/sync/scoresheets",
      Some(&token),
      &SyncScoresheetsRequest { documents: sheets },
    )
    .await
    .map(|r| r.results);
    record(items, &ids, response, scoresheet_status);
  }
  if !rubrics.is_empty() {
    let ids: Vec<Uuid> = rubrics.iter().map(|r| r.id).collect();
    let response = api::post::<_, SyncRubricsResponse>(
      "/sync/rubrics",
      Some(&token),
      &SyncRubricsRequest { documents: rubrics },
    )
    .await
    .map(|r| r.results);
    record(items, &ids, response, rubric_status);
  }
}

fn record<S: DeserializeOwned>(
  mut items: Signal<Vec<OutboxItem>>,
  sent: &[Uuid],
  response: Result<Vec<SyncResult<S>>, ApiFailure>,
  describe: fn(S) -> (String, bool),
) {
  let mut list = items.write();
  match response {
    Ok(results) => {
      for result in results {
        let Some(item) = list.iter_mut().find(|i| i.doc.id() == result.id) else {
          continue;
        };
        item.attempts += 1;
        item.last_error = None;
        item.updated_at = Utc::now();
        item.state = state_of(result.outcome, describe);
      }
    }
    Err(e) => {
      for item in list.iter_mut().filter(|i| sent.contains(&i.doc.id())) {
        item.attempts += 1;
        item.last_error = Some(e.message());
      }
    }
  }
  let _ = LocalStorage::set(STORAGE_KEY, &*list);
}

/// Calls `f` whenever the page becomes visible again, such as a tablet waking up.
fn watch_visibility(f: impl Fn() + 'static) {
  use web_sys::wasm_bindgen::JsCast;
  use web_sys::wasm_bindgen::closure::Closure;
  let Some(document) = web_sys::window().and_then(|w| w.document()) else {
    return;
  };
  let target = document.clone();
  let callback = Closure::<dyn Fn()>::new(move || {
    if target.visibility_state() == web_sys::VisibilityState::Visible {
      f();
    }
  });
  let _ = document.add_event_listener_with_callback("visibilitychange", callback.as_ref().unchecked_ref());
  // The listener lives as long as the page.
  callback.forget();
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn a_kept_scoresheet_reads_back_after_a_reload() {
    let doc: ScoresheetDoc = serde_json::from_str(DOC).unwrap();
    let item = OutboxItem {
      doc: Document::Scoresheet(doc),
      state: OutboxState::Pending,
      attempts: 1,
      last_error: Some("Cannot reach the server.".into()),
      updated_at: Utc::now(),
    };
    let stored = serde_json::to_string(&vec![item.clone()]).unwrap();
    let read: Vec<OutboxItem> = serde_json::from_str(&stored).unwrap();
    assert_eq!(read, vec![item]);
  }

  const DOC: &str = r#"{"kind":"ranking","id":"01a18ad8-92db-7356-af85-29e242a56253","event_id":"01a18ad8-7c88-7571-8987-ba826026d859","event_code":"WIFI-26","season_id":"bioglow_founders","schema_version":1,"team_number":"1","slot_id":"01a18ad8-7c94-76f1-9bea-39ad9f1fad88","round":1,"table_id":"01a18ad8-7c93-72d8-b2d8-80b86f88690e","referee_name":"","no_show":false,"answers":{"m00a":false,"m01a":false,"m01b":false,"m02a":0,"m03a":false,"m03b":false,"m04a":0,"m04b":true,"m04c":true,"m05a":"no","m06a":false,"m06b":0,"m07a":false,"m07b":0,"m08a":false,"m09a":false,"m09b":false,"m09c":false,"m10a":true,"m10b":true,"m11a":false,"m12a":false,"m12b":false,"m13a":false,"m14a":0,"m14b":0,"m15a":false,"m15b":false,"m15c":false,"m15d":"mine","m16a":6},"score":70,"gp":3,"gp_comment":"","team_agreed":true,"team_initials":"","private_comment":"","created_at":"2026-10-30T03:26:51.728Z"}"#;
}
