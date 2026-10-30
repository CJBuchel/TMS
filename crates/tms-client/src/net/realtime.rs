//! The live feed: one WebSocket per device.
//!
//! Components call `use_subscription(topic)`. A reference-counted registry turns those calls into one desired
//! topic set, and every change sends that full set to the server (`set_subscriptions`), debounced by 50 ms.
//! Because the full set is always sent, a missed release can never leave a server-side subscription hanging,
//! and a reconnect simply resends the current set.

use std::collections::{BTreeMap, VecDeque};

use dioxus::logger::tracing::{debug, warn};
use dioxus::prelude::*;
use futures::stream::{SplitSink, SplitStream};
use futures::{FutureExt, SinkExt, StreamExt, select};
use gloo_net::websocket::futures::WebSocket;
use gloo_net::websocket::{Message, State};
use gloo_timers::future::{IntervalStream, TimeoutFuture};
use tms_core::access_key;
use tms_core::deliberation::{Ceremony, Deliberation};
use tms_core::dto::{AuthResponse, Banner, EventSummary};
use tms_core::game::{MatchTimer, RankingRow, Scoresheet};
use tms_core::judging::{PodTimer, Rubric};
use tms_core::model::{GameMatch, GameTable, JudgingSession, Pod, ScheduleBlock, Team};
use tms_core::queue::Presence;
use tms_core::validation::ScheduleIssue;
use tms_core::ws::{ClientMessage, PROTOCOL_VERSION, ServerMessage, TopicItem};
use tms_core::{Role, Topic};
use uuid::Uuid;

use crate::net::api::{self, ApiFailure};
use crate::store::cache;
use crate::store::session::{Session, SessionState};
use crate::time::now_ms;

const DEBOUNCE_MS: u32 = 50;
const HELLO_TIMEOUT_MS: u32 = 5_000;
const BACKOFF_START_MS: u32 = 1_000;
const BACKOFF_MAX_MS: u32 = 16_000;
const TICK_MS: u32 = 5_000;
/// The server pings every 10 s, so this much silence means the connection is dead.
const SILENCE_LIMIT_MS: i64 = 25_000;
const TIME_SYNC_EVERY_MS: i64 = 30_000;
const OFFSET_SAMPLES: usize = 5;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ConnStatus {
  Connecting,
  Online,
  Offline,
}

pub enum Command {
  SubscriptionsChanged,
  /// Reconnect now, e.g. after signing in or out so the server sees the new token.
  Reconnect,
  /// Tell the server how many sheets and rubrics this device still holds.
  DeviceStatus,
}

/// Everything the live feed writes. All fields are signals, so components re-render on change.
#[derive(Clone, Copy)]
pub struct Stores {
  pub status: Signal<ConnStatus>,
  /// `server time - local time`, the median of recent samples.
  pub offset_ms: Signal<Option<i64>>,
  pub last_connected_ms: Signal<Option<i64>>,
  pub roles: Signal<Vec<Role>>,
  /// The topic set most recently sent to the server.
  pub sent_topics: Signal<Vec<Topic>>,
  pub event: Signal<Option<EventSummary>>,
  pub banners: Signal<Vec<Banner>>,
  pub teams: Signal<Vec<Team>>,
  pub tables: Signal<Vec<GameTable>>,
  pub pods: Signal<Vec<Pod>>,
  pub matches: Signal<Vec<GameMatch>>,
  pub sessions: Signal<Vec<JudgingSession>>,
  pub blocks: Signal<Vec<ScheduleBlock>>,
  pub timer: Signal<Option<MatchTimer>>,
  /// In ranking order.
  pub rankings: Signal<Vec<RankingRow>>,
  pub scoresheets: Signal<Vec<Scoresheet>>,
  pub presence: Signal<Vec<Presence>>,
  pub pod_timers: Signal<Vec<PodTimer>>,
  pub rubrics: Signal<Vec<Rubric>>,
  pub deliberation: Signal<Option<Deliberation>>,
  pub ceremony: Signal<Option<Ceremony>>,
  pub issues: Signal<Vec<ScheduleIssue>>,
  registry: CopyValue<BTreeMap<Topic, usize>>,
  /// Sheets and rubrics on this device the server has not accepted yet; sent on connect and on change.
  waiting: CopyValue<u32>,
}

#[derive(Clone, Copy)]
pub struct Realtime {
  pub stores: Stores,
  commands: Coroutine<Command>,
}

impl Realtime {
  fn acquire(&self, topic: Topic) {
    let mut registry = self.stores.registry;
    *registry.write().entry(topic).or_insert(0) += 1;
    self.commands.send(Command::SubscriptionsChanged);
  }

  fn release(&self, topic: Topic) {
    let mut registry = self.stores.registry;
    let mut map = registry.write();
    if let Some(count) = map.get_mut(&topic) {
      *count -= 1;
      if *count == 0 {
        map.remove(&topic);
      }
    }
    drop(map);
    self.commands.send(Command::SubscriptionsChanged);
  }

  pub fn reconnect(&self) {
    self.commands.send(Command::Reconnect);
  }

  /// Reports how many sheets and rubrics this device holds that the server has not accepted, so the head
  /// referee and judge advisor can see a tablet sitting on them.
  pub fn report_waiting(&self, waiting: u32) {
    let mut stored = self.stores.waiting;
    if *stored.peek() != waiting {
      stored.set(waiting);
      self.commands.send(Command::DeviceStatus);
    }
  }

  /// Current reference counts, for the settings page.
  pub fn registry_counts(&self) -> Vec<(Topic, usize)> {
    self.stores.registry.read().iter().map(|(t, c)| (*t, *c)).collect()
  }

  /// Local clock corrected to server time.
  pub fn server_now_ms(&self) -> i64 {
    now_ms() + self.stores.offset_ms.read().unwrap_or(0)
  }
}

/// Creates the live feed for the app and provides it as context. Call once, in the root component.
pub fn use_realtime_provider(session: Session) -> Realtime {
  let stores = use_hook(|| Stores {
    status: Signal::new(ConnStatus::Connecting),
    offset_ms: Signal::new(None),
    last_connected_ms: Signal::new(None),
    roles: Signal::new(Vec::new()),
    sent_topics: Signal::new(Vec::new()),
    event: Signal::new(cache::load("event")),
    banners: Signal::new(Vec::new()),
    teams: Signal::new(cache::load("teams")),
    tables: Signal::new(cache::load("tables")),
    pods: Signal::new(cache::load("pods")),
    matches: Signal::new(cache::load("matches")),
    sessions: Signal::new(cache::load("judging_sessions")),
    blocks: Signal::new(cache::load("blocks")),
    timer: Signal::new(None),
    rankings: Signal::new(Vec::new()),
    scoresheets: Signal::new(Vec::new()),
    presence: Signal::new(Vec::new()),
    pod_timers: Signal::new(Vec::new()),
    rubrics: Signal::new(Vec::new()),
    deliberation: Signal::new(None),
    ceremony: Signal::new(None),
    issues: Signal::new(Vec::new()),
    registry: CopyValue::new(BTreeMap::new()),
    waiting: CopyValue::new(0),
  });
  cache::use_cache_writer(stores);
  let commands = use_coroutine(move |rx: UnboundedReceiver<Command>| run(stores, session, rx));
  use_context_provider(|| Realtime { stores, commands })
}

/// Keeps `topic` subscribed while the calling component is mounted.
pub fn use_subscription(topic: Topic) {
  let realtime = use_context::<Realtime>();
  use_hook(move || realtime.acquire(topic));
  use_drop(move || realtime.release(topic));
}

enum Ended {
  /// The connection was up and then dropped; retry promptly.
  WasConnected,
  /// Never got a welcome.
  Failed,
  /// Asked to reconnect immediately.
  Reconnect,
  /// The app is shutting down.
  Stop,
}

// `Stores` is a bundle of `Copy` signal handles; passing it by value is the intended use.
#[allow(clippy::large_types_passed_by_value)]
async fn run(stores: Stores, mut session: Session, mut rx: UnboundedReceiver<Command>) {
  let mut backoff = BACKOFF_START_MS;
  loop {
    match connect_once(stores, &mut session, &mut rx).await {
      Ended::Reconnect => continue,
      Ended::Stop => return,
      Ended::WasConnected => backoff = BACKOFF_START_MS,
      Ended::Failed => {}
    }
    stores.set_status(ConnStatus::Offline);

    // Wait out the backoff, unless someone asks to reconnect now.
    let mut timer = TimeoutFuture::new(backoff).fuse();
    loop {
      select! {
        () = timer => break,
        cmd = rx.next() => match cmd {
          Some(Command::Reconnect) => break,
          Some(Command::SubscriptionsChanged | Command::DeviceStatus) => {}
          None => return,
        },
      }
    }
    backoff = (backoff * 2).min(BACKOFF_MAX_MS);
  }
}

fn ws_url() -> Option<String> {
  let location = web_sys::window()?.location();
  let scheme = if location.protocol().ok()? == "https:" {
    "wss"
  } else {
    "ws"
  };
  Some(format!("{scheme}://{}/ws", location.host().ok()?))
}

type Sink = SplitSink<WebSocket, Message>;

async fn send(sink: &mut Sink, message: &ClientMessage) -> bool {
  let json = serde_json::to_string(message).expect("client messages always serialise");
  sink.send(Message::Text(json)).await.is_ok()
}

async fn next_message(stream: &mut SplitStream<WebSocket>) -> Option<Option<ServerMessage>> {
  match stream.next().await? {
    Ok(Message::Text(text)) => Some(
      serde_json::from_str(&text)
        .map_err(|e| warn!("bad server message: {e}"))
        .ok(),
    ),
    Ok(Message::Bytes(_)) => Some(None),
    Err(_) => None,
  }
}

#[allow(clippy::large_types_passed_by_value)]
async fn connect_once(stores: Stores, session: &mut Session, rx: &mut UnboundedReceiver<Command>) -> Ended {
  stores.set_status(ConnStatus::Connecting);
  let Some(url) = ws_url() else {
    return Ended::Failed;
  };
  let Ok(socket) = WebSocket::open(&url) else {
    return Ended::Failed;
  };
  // Wait for the connection before writing: writing to a socket that failed to connect (no network) only
  // makes the browser complain.
  let waited_since = now_ms();
  loop {
    match socket.state() {
      State::Open => break,
      State::Closing | State::Closed => return Ended::Failed,
      State::Connecting if now_ms() - waited_since > i64::from(HELLO_TIMEOUT_MS) => return Ended::Failed,
      State::Connecting => TimeoutFuture::new(25).await,
    }
  }
  let (mut sink, mut stream) = socket.split();

  let token = session.peek().token().map(str::to_owned);
  let hello = ClientMessage::Hello {
    v: PROTOCOL_VERSION,
    token,
    client_build: env!("CARGO_PKG_VERSION").to_owned(),
  };
  if !send(&mut sink, &hello).await {
    return Ended::Failed;
  }

  let first = select! {
    m = next_message(&mut stream).fuse() => m,
    () = TimeoutFuture::new(HELLO_TIMEOUT_MS).fuse() => None,
  };
  match first {
    Some(Some(ServerMessage::Welcome { roles, .. })) => stores.welcomed(roles),
    Some(Some(ServerMessage::Error { code, .. })) if code == "auth.required" => {
      return recover_rejected_token(session).await;
    }
    _ => return Ended::Failed,
  }

  if let SessionState::OfflineKey {
    key,
    role,
    rejected: false,
  } = session.peek()
    && let Some(ended) = verify_offline_key(session, key, role).await
  {
    return ended;
  }

  stores.sync_subscriptions(&mut sink).await;
  send(
    &mut sink,
    &ClientMessage::DeviceStatus {
      waiting: *stores.waiting.peek(),
    },
  )
  .await;
  let mut last_received = now_ms();
  let mut last_sync_sent = now_ms();
  let mut samples = VecDeque::with_capacity(OFFSET_SAMPLES);
  send(
    &mut sink,
    &ClientMessage::TimeSync {
      client_ms: last_sync_sent,
    },
  )
  .await;
  let mut tick = IntervalStream::new(TICK_MS).fuse();

  loop {
    select! {
      cmd = rx.next() => match cmd {
        Some(Command::SubscriptionsChanged) => {
          // Debounce: let a burst of mounts and unmounts settle, then send one set.
          TimeoutFuture::new(DEBOUNCE_MS).await;
          let mut reconnect = false;
          while let Ok(cmd) = rx.try_recv() {
            reconnect |= matches!(cmd, Command::Reconnect);
          }
          if reconnect {
            return Ended::Reconnect;
          }
          if !stores.sync_subscriptions(&mut sink).await {
            return Ended::WasConnected;
          }
          // The debounce above may have swallowed a status change.
          send(&mut sink, &ClientMessage::DeviceStatus { waiting: *stores.waiting.peek() }).await;
        }
        Some(Command::DeviceStatus) => {
          send(&mut sink, &ClientMessage::DeviceStatus { waiting: *stores.waiting.peek() }).await;
        }
        Some(Command::Reconnect) => return Ended::Reconnect,
        None => return Ended::Stop,
      },
      message = next_message(&mut stream).fuse() => {
        let Some(message) = message else { return Ended::WasConnected };
        last_received = now_ms();
        match message {
          Some(ServerMessage::Ping) => {
            send(&mut sink, &ClientMessage::Pong).await;
          }
          Some(ServerMessage::TimeSync { client_ms, server_ms }) => stores.time_sample(&mut samples, client_ms, server_ms),
          // The server ended this login and is closing the socket: stop using it and log in again or out.
          // The server ended the login this socket used and is closing it. Reconnect after the usual pause: a
          // password change has put a new token in the session by then, and a truly revoked token fails the
          // handshake, which logs in again with the key or logs out.
          Some(ServerMessage::Error { code, .. }) if code == "auth.revoked" => return Ended::WasConnected,
          Some(ServerMessage::Error { code, message }) => warn!(%code, %message, "server reported an error"),
          Some(other) => stores.apply(other),
          None => {}
        }
      },
      _ = tick.next() => {
        let now = now_ms();
        if now - last_received > SILENCE_LIMIT_MS {
          debug!("no traffic from server; reconnecting");
          return Ended::WasConnected;
        }
        if now - last_sync_sent > TIME_SYNC_EVERY_MS {
          last_sync_sent = now;
          send(&mut sink, &ClientMessage::TimeSync { client_ms: now }).await;
        }
      },
    }
  }
}

/// The server refused our token: tokens expire and get revoked. A key-backed device logs in again on its own;
/// a password login is logged out and sent to the login page.
async fn recover_rejected_token(session: &mut Session) -> Ended {
  match session.peek() {
    SessionState::Online {
      key: Some(key),
      identity,
      ..
    } => {
      let role = identity.roles.first().copied().unwrap_or(Role::Display);
      verify_offline_key(session, key, role).await.unwrap_or(Ended::Reconnect)
    }
    SessionState::Online { key: None, .. } => {
      session.set(SessionState::LoggedOut);
      Ended::Reconnect
    }
    _ => Ended::Failed,
  }
}

/// Exchanges a stored access key for a session. `None` means stay connected as we are.
async fn verify_offline_key(session: &mut Session, key: String, role: Role) -> Option<Ended> {
  let parsed = access_key::parse(&key)?;
  match api::post::<_, AuthResponse>(
    "/auth/key",
    None,
    &tms_core::dto::KeyLoginRequest {
      key: parsed.normalized.clone(),
    },
  )
  .await
  {
    Ok(auth) => {
      session.set(SessionState::from_auth(auth, Some(parsed.normalized)));
      Some(Ended::Reconnect)
    }
    Err(ApiFailure::Network(_)) => None,
    Err(ApiFailure::Api { .. }) => {
      session.set(SessionState::OfflineKey {
        key,
        role,
        rejected: true,
      });
      Some(Ended::Reconnect)
    }
  }
}

impl Stores {
  fn set_status(self, status: ConnStatus) {
    let mut s = self.status;
    if *s.peek() != status {
      s.set(status);
    }
  }

  fn welcomed(self, roles: Vec<Role>) {
    self.set_status(ConnStatus::Online);
    let (mut last, mut r) = (self.last_connected_ms, self.roles);
    last.set(Some(now_ms()));
    r.set(roles);
  }

  /// Sends the full desired set. Returns false if the socket is gone.
  async fn sync_subscriptions(self, sink: &mut Sink) -> bool {
    let topics: Vec<Topic> = self.registry.peek().keys().copied().collect();
    let mut sent = self.sent_topics;
    sent.set(topics.clone());
    send(sink, &ClientMessage::SetSubscriptions { topics }).await
  }

  fn time_sample(self, samples: &mut VecDeque<i64>, client_ms: i64, server_ms: i64) {
    let now = now_ms();
    if client_ms <= 0 || now < client_ms {
      return;
    }
    let round_trip = now - client_ms;
    if samples.len() == OFFSET_SAMPLES {
      samples.pop_front();
    }
    samples.push_back(server_ms + round_trip / 2 - now);
    let mut sorted: Vec<i64> = samples.iter().copied().collect();
    sorted.sort_unstable();
    let mut offset = self.offset_ms;
    offset.set(Some(sorted[sorted.len() / 2]));
  }

  /// Writes a snapshot or delta into the matching store.
  fn apply(self, message: ServerMessage) {
    match message {
      ServerMessage::Snapshot { topic, items } => self.replace(topic, items),
      ServerMessage::Upsert { item, .. } => self.upsert(item),
      ServerMessage::Delete { topic, id } => self.remove(topic, id),
      _ => {}
    }
  }

  fn replace(self, topic: Topic, items: Vec<TopicItem>) {
    let mut event = self.event;
    match topic {
      Topic::Event => event.set(
        items
          .into_iter()
          .find_map(|i| if let TopicItem::Event(e) = i { Some(e) } else { None }),
      ),
      Topic::Banners => set_list(self.banners, items, |i| {
        if let TopicItem::Banner(x) = i { Some(x) } else { None }
      }),
      Topic::Teams => set_list(self.teams, items, |i| {
        if let TopicItem::Team(x) = i { Some(x) } else { None }
      }),
      Topic::Tables => set_list(self.tables, items, |i| {
        if let TopicItem::Table(x) = i { Some(x) } else { None }
      }),
      Topic::Pods => set_list(
        self.pods,
        items,
        |i| if let TopicItem::Pod(x) = i { Some(x) } else { None },
      ),
      Topic::Matches => set_list(self.matches, items, |i| {
        if let TopicItem::Match(x) = i { Some(x) } else { None }
      }),
      Topic::JudgingSessions => {
        set_list(self.sessions, items, |i| {
          if let TopicItem::JudgingSession(x) = i {
            Some(x)
          } else {
            None
          }
        });
      }
      Topic::Blocks => set_list(self.blocks, items, |i| {
        if let TopicItem::Block(x) = i { Some(x) } else { None }
      }),
      Topic::Timer => {
        let mut timer = self.timer;
        timer.set(
          items
            .into_iter()
            .find_map(|i| if let TopicItem::Timer(t) = i { Some(t) } else { None }),
        );
      }
      Topic::Rankings => set_list(self.rankings, items, |i| {
        if let TopicItem::Ranking(x) = i { Some(x) } else { None }
      }),
      Topic::Scoresheets => set_list(self.scoresheets, items, |i| {
        if let TopicItem::Scoresheet(x) = i {
          Some(*x)
        } else {
          None
        }
      }),
      Topic::Presence => set_list(self.presence, items, |i| {
        if let TopicItem::Presence(x) = i { Some(x) } else { None }
      }),
      Topic::PodTimers => set_list(self.pod_timers, items, |i| {
        if let TopicItem::PodTimer(x) = i { Some(x) } else { None }
      }),
      Topic::Rubrics => set_list(self.rubrics, items, |i| {
        if let TopicItem::Rubric(x) = i { Some(*x) } else { None }
      }),
      Topic::Deliberation => {
        let mut deliberation = self.deliberation;
        deliberation.set(items.into_iter().find_map(|i| {
          if let TopicItem::Deliberation(d) = i {
            Some(*d)
          } else {
            None
          }
        }));
      }
      Topic::Issues => set_list(self.issues, items, |i| {
        if let TopicItem::Issue(x) = i { Some(x) } else { None }
      }),
      Topic::Ceremony => {
        let mut ceremony = self.ceremony;
        ceremony.set(
          items
            .into_iter()
            .find_map(|i| if let TopicItem::Ceremony(c) = i { Some(c) } else { None }),
        );
      }
    }
  }

  fn upsert(self, item: TopicItem) {
    let mut event = self.event;
    match item {
      TopicItem::Event(e) => event.set(Some(e)),
      TopicItem::Banner(x) => upsert_in(self.banners, x, |b| b.id),
      TopicItem::Team(x) => upsert_in(self.teams, x, |t| t.id),
      TopicItem::Table(x) => upsert_in(self.tables, x, |t| t.id),
      TopicItem::Pod(x) => upsert_in(self.pods, x, |p| p.id),
      TopicItem::Match(x) => upsert_in(self.matches, x, |m| m.id),
      TopicItem::JudgingSession(x) => upsert_in(self.sessions, x, |s| s.id),
      TopicItem::Block(x) => upsert_in(self.blocks, x, |b| b.id),
      TopicItem::Timer(x) => {
        let mut timer = self.timer;
        timer.set(Some(x));
      }
      TopicItem::Ranking(x) => upsert_in(self.rankings, x, |r| r.team_id),
      TopicItem::Scoresheet(x) => upsert_in(self.scoresheets, *x, |s| s.id),
      TopicItem::Presence(x) => upsert_in(self.presence, x, |p| p.key_id),
      TopicItem::PodTimer(x) => upsert_in(self.pod_timers, x, |t| t.pod_id),
      TopicItem::Rubric(x) => upsert_in(self.rubrics, *x, |r| r.id),
      TopicItem::Deliberation(x) => {
        let mut deliberation = self.deliberation;
        deliberation.set(Some(*x));
      }
      TopicItem::Ceremony(x) => {
        let mut ceremony = self.ceremony;
        ceremony.set(Some(x));
      }
      TopicItem::Issue(x) => upsert_in(self.issues, x, |i| i.id),
    }
  }

  fn remove(self, topic: Topic, id: Uuid) {
    let mut event = self.event;
    match topic {
      Topic::Event => {
        if event.peek().as_ref().is_some_and(|e| e.id == id) {
          event.set(None);
        }
      }
      Topic::Banners => remove_from(self.banners, id, |b| b.id),
      Topic::Teams => remove_from(self.teams, id, |t| t.id),
      Topic::Tables => remove_from(self.tables, id, |t| t.id),
      Topic::Pods => remove_from(self.pods, id, |p| p.id),
      Topic::Matches => remove_from(self.matches, id, |m| m.id),
      Topic::JudgingSessions => remove_from(self.sessions, id, |s| s.id),
      Topic::Blocks => remove_from(self.blocks, id, |b| b.id),
      Topic::Timer => {
        let mut timer = self.timer;
        if timer.peek().as_ref().is_some_and(|t| t.event_id == id) {
          timer.set(None);
        }
      }
      Topic::Rankings => remove_from(self.rankings, id, |r| r.team_id),
      Topic::Scoresheets => remove_from(self.scoresheets, id, |s| s.id),
      Topic::Presence => remove_from(self.presence, id, |p| p.key_id),
      Topic::PodTimers => remove_from(self.pod_timers, id, |t| t.pod_id),
      Topic::Rubrics => remove_from(self.rubrics, id, |r| r.id),
      Topic::Deliberation => {
        let mut deliberation = self.deliberation;
        deliberation.set(None);
      }
      Topic::Ceremony => {
        let mut ceremony = self.ceremony;
        ceremony.set(None);
      }
      Topic::Issues => remove_from(self.issues, id, |i| i.id),
    }
  }
}

fn set_list<T: 'static>(mut list: Signal<Vec<T>>, items: Vec<TopicItem>, pick: impl Fn(TopicItem) -> Option<T>) {
  list.set(items.into_iter().filter_map(pick).collect());
}

fn upsert_in<T: 'static>(mut list: Signal<Vec<T>>, item: T, id: impl Fn(&T) -> Uuid) {
  let mut list = list.write();
  let key = id(&item);
  match list.iter_mut().find(|x| id(x) == key) {
    Some(existing) => *existing = item,
    None => list.push(item),
  }
}

fn remove_from<T: 'static>(mut list: Signal<Vec<T>>, key: Uuid, id: impl Fn(&T) -> Uuid) {
  list.write().retain(|x| id(x) != key);
}
