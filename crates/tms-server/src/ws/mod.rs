//! `/ws`: one socket per client, declarative topic subscriptions, snapshot then deltas. See `tms_core::ws`.

mod snapshot;

use std::collections::BTreeSet;
use std::time::Duration;
use tms_core::dto::Principal;

use axum::extract::State;
use axum::extract::ws::{Message, WebSocket, WebSocketUpgrade};
use axum::response::Response;
use futures_util::stream::{SplitSink, SplitStream};
use futures_util::{SinkExt, StreamExt};
use tms_core::ws::{ClientMessage, PROTOCOL_VERSION, ServerMessage};
use tms_core::{Role, Topic};
use tokio::sync::broadcast::error::RecvError;
use tokio::time::{MissedTickBehavior, interval, timeout};

use crate::AppState;
use crate::auth::Claims;
use crate::bus::Payload;

const HELLO_TIMEOUT: Duration = Duration::from_secs(5);
const PING_INTERVAL: Duration = Duration::from_secs(10);
const MAX_MISSED_PONGS: u8 = 2;

pub async fn handler(ws: WebSocketUpgrade, State(state): State<AppState>) -> Response {
  ws.on_upgrade(move |socket| async move {
    let (sink, stream) = socket.split();
    let mut conn = Connection {
      state,
      sink,
      roles: Vec::new(),
      login: None,
      subscriptions: BTreeSet::new(),
    };
    if let Err(e) = conn.run(stream).await {
      tracing::debug!(error = %e, "websocket closed");
    }
  })
}

/// Who may read a topic. The event, its teams, venue and timetable are public (displays show them before
/// anyone logs in), as are the match timer, ranking and what the awards ceremony has revealed. Scoresheets are for
/// referees, rubrics for judges, deliberation for the judge advisor.
fn can_read(topic: Topic, roles: &[Role]) -> bool {
  match topic {
    Topic::Event
    | Topic::Banners
    | Topic::Teams
    | Topic::Tables
    | Topic::Pods
    | Topic::Matches
    | Topic::JudgingSessions
    | Topic::Blocks
    | Topic::Timer
    | Topic::Rankings
    | Topic::PodTimers
    | Topic::Ceremony => true,
    Topic::Rubrics => tms_core::role::has_role(roles, Role::Judge),
    Topic::Deliberation => tms_core::role::has_role(roles, Role::JudgeAdvisor),
    Topic::Scoresheets => tms_core::role::has_role(roles, Role::Referee),
    Topic::Presence | Topic::Issues => {
      tms_core::role::has_role(roles, Role::HeadReferee) || tms_core::role::has_role(roles, Role::JudgeAdvisor)
    }
  }
}

struct Connection {
  state: AppState,
  sink: SplitSink<WebSocket, Message>,
  roles: Vec<Role>,
  /// The token from `hello` and its verified claims; `None` for a public connection.
  login: Option<(String, Claims)>,
  subscriptions: BTreeSet<Topic>,
}

#[derive(Debug, thiserror::Error)]
enum WsError {
  #[error("socket: {0}")]
  Socket(#[from] axum::Error),
  #[error("database: {0}")]
  Db(#[from] sqlx::Error),
  #[error("{0}")]
  Protocol(&'static str),
}

impl Connection {
  async fn run(&mut self, mut stream: SplitStream<WebSocket>) -> Result<(), WsError> {
    // Subscribed before the handshake so a revocation that lands during it is not missed.
    let mut revocations = self.state.auth.subscribe();
    self.handshake(&mut stream).await?;
    // Held for the life of the connection; a station device shows as connected until it closes.
    let _presence = self
      .login
      .as_ref()
      .and_then(|(_, claims)| self.state.presence.join(&claims.identity()));

    let mut rx = self.state.bus.subscribe();
    let mut ping = interval(PING_INTERVAL);
    ping.set_missed_tick_behavior(MissedTickBehavior::Delay);
    ping.tick().await;
    let mut missed_pongs = 0u8;

    loop {
      tokio::select! {
        incoming = stream.next() => {
          let Some(incoming) = incoming else { return Ok(()) };
          match incoming? {
            Message::Text(text) => match serde_json::from_str::<ClientMessage>(&text) {
              Ok(ClientMessage::SetSubscriptions { topics }) => self.set_subscriptions(topics).await?,
              Ok(ClientMessage::TimeSync { client_ms }) => {
                self.send(&ServerMessage::TimeSync { client_ms, server_ms: now_ms() }).await?;
              }
              Ok(ClientMessage::Pong) => missed_pongs = 0,
              Ok(ClientMessage::DeviceStatus { waiting }) => {
                if let Some((_, claims)) = &self.login
                  && let Principal::Key { key_id, .. } = claims.identity().principal
                {
                  self.state.presence.set_waiting(key_id, waiting);
                }
              }
              Ok(ClientMessage::Hello { .. }) => self.error("ws.duplicate_hello", "hello was already received").await?,
              Err(e) => self.error("ws.bad_message", &e.to_string()).await?,
            },
            Message::Close(_) => return Ok(()),
            _ => {}
          }
        }
        outbound = rx.recv() => match outbound {
          Ok(out) if self.subscriptions.contains(&out.topic) => match &out.payload {
            Payload::Json(json) => self.sink.send(Message::Text(json.as_str().into())).await?,
            Payload::Resnapshot => self.send_snapshot(out.topic).await?,
          },
          Ok(_) => {}
          Err(RecvError::Lagged(skipped)) => {
            tracing::warn!(skipped, "websocket lagged; resending snapshots");
            for topic in self.subscriptions.clone() {
              self.send_snapshot(topic).await?;
            }
          }
          Err(RecvError::Closed) => return Ok(()),
        },
        revocation = revocations.recv() => {
          let still_valid = match (&revocation, &self.login) {
            (_, None) => true,
            (Ok(r), Some((_, claims))) => !r.affects(claims),
            // Missed some revocations: check the token against the current list instead.
            (Err(_), Some((token, _))) => self.state.auth.verify(token).is_some(),
          };
          if !still_valid {
            self.error("auth.revoked", "this login was ended; log in again").await?;
            return Err(WsError::Protocol("token revoked"));
          }
        }
        _ = ping.tick() => {
          if missed_pongs >= MAX_MISSED_PONGS {
            return Err(WsError::Protocol("client stopped answering pings"));
          }
          missed_pongs += 1;
          self.send(&ServerMessage::Ping).await?;
        }
      }
    }
  }

  /// Waits for `hello`, resolves its optional token to roles, and replies `welcome`.
  /// A connection without a token may only read public topics.
  async fn handshake(&mut self, stream: &mut SplitStream<WebSocket>) -> Result<(), WsError> {
    let first = timeout(HELLO_TIMEOUT, stream.next())
      .await
      .map_err(|_| WsError::Protocol("no hello within 5 s"))?;
    let Some(Ok(Message::Text(text))) = first else {
      return Err(WsError::Protocol("expected hello"));
    };
    let Ok(ClientMessage::Hello { v, token, .. }) = serde_json::from_str::<ClientMessage>(&text) else {
      self
        .error("ws.expected_hello", "the first message must be hello")
        .await?;
      return Err(WsError::Protocol("expected hello"));
    };
    if v != PROTOCOL_VERSION {
      self
        .error(
          "ws.protocol_version",
          &format!("server speaks protocol {PROTOCOL_VERSION}, client sent {v}"),
        )
        .await?;
      return Err(WsError::Protocol("protocol version mismatch"));
    }
    if let Some(token) = token {
      let Some(claims) = self.state.auth.verify(&token) else {
        self.error("auth.required", "login token is invalid or expired").await?;
        return Err(WsError::Protocol("invalid token"));
      };
      self.roles.clone_from(&claims.roles);
      self.login = Some((token, claims));
    }
    self
      .send(&ServerMessage::Welcome {
        v: PROTOCOL_VERSION,
        server_ms: now_ms(),
        roles: self.roles.clone(),
      })
      .await
  }

  /// Replaces the subscription set. Added topics get a snapshot; removed topics simply stop being forwarded.
  async fn set_subscriptions(&mut self, topics: Vec<Topic>) -> Result<(), WsError> {
    let mut wanted = BTreeSet::new();
    for topic in topics {
      if can_read(topic, &self.roles) {
        wanted.insert(topic);
      } else {
        self
          .error("ws.topic_forbidden", &format!("not allowed to read `{topic}`"))
          .await?;
      }
    }
    let added: Vec<Topic> = wanted.difference(&self.subscriptions).copied().collect();
    self.subscriptions = wanted;
    for topic in added {
      self.send_snapshot(topic).await?;
    }
    Ok(())
  }

  async fn send_snapshot(&mut self, topic: Topic) -> Result<(), WsError> {
    let items = snapshot::load(&self.state, topic).await?;
    self.send(&ServerMessage::Snapshot { topic, items }).await
  }

  async fn error(&mut self, code: &str, message: &str) -> Result<(), WsError> {
    self
      .send(&ServerMessage::Error {
        code: code.to_owned(),
        message: message.to_owned(),
      })
      .await
  }

  async fn send(&mut self, message: &ServerMessage) -> Result<(), WsError> {
    let json = serde_json::to_string(message).expect("server messages always serialise");
    self.sink.send(Message::Text(json.into())).await?;
    Ok(())
  }
}

fn now_ms() -> i64 {
  chrono::Utc::now().timestamp_millis()
}
