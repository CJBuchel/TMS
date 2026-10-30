//! WebSocket protocol at `/ws`. JSON text frames tagged by `type`.
//!
//! 1. Client sends `hello` (with a login token, or none for public topics only).
//! 2. Server replies `welcome`.
//! 3. Client sends `set_subscriptions` with its complete desired topic set whenever it changes.
//!    The server sends a `snapshot` for each added topic, then `upsert`/`delete` deltas.
//! 4. Server sends `ping` every 10 s; client answers `pong`. Client sends `time_sync` to estimate clock offset.

use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::Topic;
use crate::deliberation::{Ceremony, Deliberation};
use crate::dto::{Banner, EventSummary};
use crate::game::{MatchTimer, RankingRow, Scoresheet};
use crate::judging::{PodTimer, Rubric};
use crate::model::{GameMatch, GameTable, JudgingSession, Pod, ScheduleBlock, Team};
use crate::queue::Presence;
use crate::role::Role;
use crate::validation::ScheduleIssue;

pub const PROTOCOL_VERSION: u16 = 1;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum ClientMessage {
  Hello {
    v: u16,
    token: Option<String>,
    client_build: String,
  },
  /// The complete desired subscription set. Replaces the previous set; duplicates are ignored.
  SetSubscriptions {
    topics: Vec<Topic>,
  },
  TimeSync {
    client_ms: i64,
  },
  Pong,
  /// From a station device: how many scoresheets and rubrics it holds that the server has not accepted yet.
  DeviceStatus {
    waiting: u32,
  },
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum ServerMessage {
  Welcome { v: u16, server_ms: i64, roles: Vec<Role> },
  Snapshot { topic: Topic, items: Vec<TopicItem> },
  Upsert { topic: Topic, item: TopicItem },
  Delete { topic: Topic, id: Uuid },
  TimeSync { client_ms: i64, server_ms: i64 },
  Error { code: String, message: String },
  Ping,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
/// `{"kind": "match", "data": {...}}`: the data sits in its own field so its fields can never clash with the tag.
#[serde(tag = "kind", content = "data", rename_all = "snake_case")]
pub enum TopicItem {
  Event(EventSummary),
  Banner(Banner),
  Team(Team),
  Table(GameTable),
  Pod(Pod),
  Match(GameMatch),
  JudgingSession(JudgingSession),
  Block(ScheduleBlock),
  Timer(MatchTimer),
  Ranking(RankingRow),
  Scoresheet(Box<Scoresheet>),
  Presence(Presence),
  PodTimer(PodTimer),
  Rubric(Box<Rubric>),
  Deliberation(Box<Deliberation>),
  Ceremony(Ceremony),
  Issue(ScheduleIssue),
}

impl TopicItem {
  /// The item's key within its topic. The timer, deliberation and ceremony are keyed by their event, a ranking
  /// row by its team.
  pub fn id(&self) -> Uuid {
    match self {
      TopicItem::Timer(t) => t.event_id,
      TopicItem::Ranking(r) => r.team_id,
      TopicItem::Scoresheet(s) => s.id,
      TopicItem::Presence(p) => p.key_id,
      TopicItem::PodTimer(t) => t.pod_id,
      TopicItem::Rubric(r) => r.id,
      TopicItem::Deliberation(d) => d.event_id,
      TopicItem::Ceremony(c) => c.event_id,
      TopicItem::Issue(i) => i.id,
      TopicItem::Event(e) => e.id,
      TopicItem::Banner(b) => b.id,
      TopicItem::Team(t) => t.id,
      TopicItem::Table(t) => t.id,
      TopicItem::Pod(p) => p.id,
      TopicItem::Match(m) => m.id,
      TopicItem::JudgingSession(s) => s.id,
      TopicItem::Block(b) => b.id,
    }
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn client_message_wire_format() {
    let m = ClientMessage::SetSubscriptions {
      topics: vec![Topic::Banners, Topic::Event],
    };
    assert_eq!(
      serde_json::to_string(&m).unwrap(),
      r#"{"type":"set_subscriptions","topics":["banners","event"]}"#
    );
    let parsed: ClientMessage = serde_json::from_str(r#"{"type":"pong"}"#).unwrap();
    assert_eq!(parsed, ClientMessage::Pong);
  }

  #[test]
  fn server_message_wire_format() {
    let m = ServerMessage::Delete {
      topic: Topic::Banners,
      id: Uuid::nil(),
    };
    assert_eq!(
      serde_json::to_string(&m).unwrap(),
      r#"{"type":"delete","topic":"banners","id":"00000000-0000-0000-0000-000000000000"}"#
    );
  }
}
