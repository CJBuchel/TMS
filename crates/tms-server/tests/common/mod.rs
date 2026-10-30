#![allow(dead_code)]

use std::fmt::Write as _;
use std::path::PathBuf;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::time::Duration;

use futures_util::{SinkExt, StreamExt};
use reqwest::{Client, Response, StatusCode};
use serde::Serialize;
use serde::de::DeserializeOwned;
use sqlx::PgPool;
use tms_core::Role;
use tms_core::dto::{AuthResponse, CreateEventRequest, EventSummary};
use tms_core::ws::{ClientMessage, PROTOCOL_VERSION, ServerMessage};
use tms_server::auth::crypto;
use tms_server::repo::users;
use tms_server::{AppState, router};
use tokio::net::TcpStream;
use tokio_tungstenite::tungstenite::Message;
use tokio_tungstenite::{MaybeTlsStream, WebSocketStream};

pub const ADMIN_PASSWORD: &str = "admin-password-1";

pub struct TestApp {
  pub addr: std::net::SocketAddr,
  pub http: Client,
  pub pool: PgPool,
  _db: TestDb,
}

/// A real embedded PostgreSQL in its own temporary folder, stopped and deleted when the test ends
/// (also when it panics, because PostgreSQL's handle stops the server on drop).
struct TestDb {
  database: Option<tms_db::Database>,
  dir: PathBuf,
}

impl Drop for TestDb {
  fn drop(&mut self) {
    drop(self.database.take());
    let _ = std::fs::remove_dir_all(&self.dir);
  }
}

static NEXT_DB: AtomicUsize = AtomicUsize::new(0);

impl TestApp {
  pub async fn spawn() -> Self {
    let n = NEXT_DB.fetch_add(1, Ordering::Relaxed);
    let dir = std::env::temp_dir().join(format!("tms-server-test-{}-{n}", std::process::id()));
    let _ = std::fs::remove_dir_all(&dir);
    let database = tms_db::Database::open(tms_db::Source::Embedded {
      dir: dir.clone(),
      port: None,
    })
    .await
    .unwrap();
    database.migrate().await.unwrap();
    let pool = database.pool().clone();

    let listener = tokio::net::TcpListener::bind("127.0.0.1:0").await.unwrap();
    let addr = listener.local_addr().unwrap();
    // Match timings run 100 times faster, so a 2:30 match takes 1.5 s.
    let state = AppState::with_timer_speedup(pool.clone(), 100).await.unwrap();
    let web_dir = std::path::Path::new("/nonexistent");
    let app = router(state, web_dir).into_make_service_with_connect_info::<std::net::SocketAddr>();
    tokio::spawn(async move { axum::serve(listener, app).await.unwrap() });
    Self {
      addr,
      http: Client::new(),
      pool,
      _db: TestDb {
        database: Some(database),
        dir,
      },
    }
  }

  pub fn url(&self, path: &str) -> String {
    format!("http://{}/api/v1{}", self.addr, path)
  }

  pub async fn create_user(&self, username: &str, password: &str, roles: &[Role], must_change: bool) {
    let hash = crypto::hash_password(password).unwrap();
    users::insert(
      &self.pool,
      users::NewUser {
        username,
        display_name: username,
        password_hash: &hash,
        roles,
        must_change_password: must_change,
      },
    )
    .await
    .unwrap();
  }

  pub async fn login(&self, username: &str, password: &str) -> Response {
    self
      .http
      .post(self.url("/auth/login"))
      .json(&serde_json::json!({"username": username, "password": password}))
      .send()
      .await
      .unwrap()
  }

  /// An admin with no pending password change, already logged in.
  pub async fn admin_token(&self) -> String {
    self.create_user("admin", ADMIN_PASSWORD, &[Role::Admin], false).await;
    let res = self.login("admin", ADMIN_PASSWORD).await;
    assert_eq!(res.status(), StatusCode::OK);
    res.json::<AuthResponse>().await.unwrap().token
  }

  pub async fn get(&self, token: Option<&str>, path: &str) -> Response {
    let mut req = self.http.get(self.url(path));
    if let Some(t) = token {
      req = req.bearer_auth(t);
    }
    req.send().await.unwrap()
  }

  pub async fn post<B: Serialize>(&self, token: Option<&str>, path: &str, body: &B) -> Response {
    let mut req = self.http.post(self.url(path)).json(body);
    if let Some(t) = token {
      req = req.bearer_auth(t);
    }
    req.send().await.unwrap()
  }

  pub async fn patch<B: Serialize>(&self, token: &str, path: &str, body: &B) -> Response {
    self
      .http
      .patch(self.url(path))
      .bearer_auth(token)
      .json(body)
      .send()
      .await
      .unwrap()
  }

  pub async fn delete(&self, token: &str, path: &str) -> Response {
    self
      .http
      .delete(self.url(path))
      .bearer_auth(token)
      .send()
      .await
      .unwrap()
  }

  /// POSTs raw text (a CSV file).
  pub async fn post_text(&self, token: &str, path: &str, body: &str) -> Response {
    self
      .http
      .post(self.url(path))
      .bearer_auth(token)
      .body(body.to_owned())
      .send()
      .await
      .unwrap()
  }

  /// Creates and activates an event, so its data is pushed on the live feed.
  pub async fn active_event(&self, token: &str, code: &str) -> EventSummary {
    let event = self.create_event(token, code).await;
    ok_json(
      self
        .post(Some(token), &format!("/events/{}/activate", event.id), &())
        .await,
    )
    .await
  }

  pub async fn create_event(&self, token: &str, code: &str) -> EventSummary {
    let body = CreateEventRequest {
      code: code.into(),
      name: format!("Event {code}"),
      season_id: "bioglow_founders".into(),
      timezone: "Australia/Sydney".into(),
      starts_on: "2026-11-14".parse().unwrap(),
      ends_on: "2026-11-14".parse().unwrap(),
    };
    ok_json(self.post(Some(token), "/events", &body).await).await
  }

  pub async fn ws(&self) -> Ws {
    let (stream, _) = tokio_tungstenite::connect_async(format!("ws://{}/ws", self.addr))
      .await
      .unwrap();
    Ws { stream }
  }

  /// Connects and completes the hello/welcome handshake.
  pub async fn ws_ready(&self, token: Option<&str>) -> Ws {
    let mut ws = self.ws().await;
    ws.send(&ClientMessage::Hello {
      v: PROTOCOL_VERSION,
      token: token.map(Into::into),
      client_build: "test".into(),
    })
    .await;
    match ws.recv().await {
      ServerMessage::Welcome { .. } => ws,
      other => panic!("expected welcome, got {other:?}"),
    }
  }
}

pub async fn ok_json<T: DeserializeOwned>(res: Response) -> T {
  let status = res.status();
  let text = res.text().await.unwrap();
  assert!(status.is_success(), "expected success, got {status}: {text}");
  serde_json::from_str(&text).unwrap_or_else(|e| panic!("bad json ({e}): {text}"))
}

pub async fn error_code(res: Response) -> (StatusCode, String) {
  let status = res.status();
  let body: serde_json::Value = res.json().await.unwrap();
  (status, body["code"].as_str().unwrap_or_default().to_owned())
}

pub struct Ws {
  stream: WebSocketStream<MaybeTlsStream<TcpStream>>,
}

impl Ws {
  pub async fn send(&mut self, m: &ClientMessage) {
    self
      .stream
      .send(Message::Text(serde_json::to_string(m).unwrap().into()))
      .await
      .unwrap();
  }

  pub async fn send_raw(&mut self, text: &str) {
    self.stream.send(Message::Text(text.to_owned().into())).await.unwrap();
  }

  /// Next protocol message, skipping pings. Panics after 3 s.
  pub async fn recv(&mut self) -> ServerMessage {
    self.try_recv(Duration::from_secs(3)).await.expect("expected a message")
  }

  /// `None` on timeout or close.
  pub async fn try_recv(&mut self, wait: Duration) -> Option<ServerMessage> {
    loop {
      let msg = tokio::time::timeout(wait, self.stream.next()).await.ok()??.ok()?;
      if let Message::Text(text) = msg {
        let m: ServerMessage = serde_json::from_str(&text).unwrap();
        if m != ServerMessage::Ping {
          return Some(m);
        }
      } else if let Message::Close(_) = msg {
        return None;
      }
    }
  }

  /// Sends a time sync and returns every message received before its reply, proving nothing else is queued.
  pub async fn drain(&mut self) -> Vec<ServerMessage> {
    self.send(&ClientMessage::TimeSync { client_ms: -1 }).await;
    let mut seen = Vec::new();
    loop {
      match self.recv().await {
        ServerMessage::TimeSync { client_ms: -1, .. } => return seen,
        other => seen.push(other),
      }
    }
  }
}

/// Twelve teams on two tables: three ranking rounds of six matches, five minutes apart, and one judging pod.
pub fn twelve_team_schedule() -> String {
  let mut csv = String::from("Version Number,1\nBlock Format,1\nNumber of Teams,12\n");
  for n in 1..=12 {
    let _ = writeln!(csv, "{n},Team {n},School {n},");
  }
  csv.push_str(
    "Block Format,2\nNumber of Ranking Matches,18\nNumber of Tables,2\nNumber of Teams per Table,1\n\
     Number of Simultaneous Tables,2\nTable Names,Red,Blue,\n",
  );
  let time = |minutes: u32| {
    let (h, m) = (9 + minutes / 60, minutes % 60);
    format!("{h}:{m:02}:00 {}", if h < 12 { "AM" } else { "PM" })
  };
  for round in 0..3u32 {
    for k in 0..6u32 {
      let number = round * 6 + k + 1;
      let a = (2 * k + round) % 12 + 1;
      let b = (2 * k + 1 + round) % 12 + 1;
      let start = (number - 1) * 5;
      let _ = writeln!(csv, "{number},{},{},{a},{b},", time(start), time(start + 3));
    }
  }
  csv.push_str(
    "Block Format,3\nNumber of Judged Events,1\nNumber of Event Time Slots,12\nNumber of Judging Teams,1\n\
     Room Names,Pod 1,\n",
  );
  for n in 1..=12u32 {
    let start = 120 + (n - 1) * 30;
    let _ = writeln!(csv, "{n},{},{},{n},", time(start), time(start + 25));
  }
  csv
}
