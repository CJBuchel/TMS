//! In-process change feed. Services publish after their transaction commits; every WebSocket connection
//! holds a receiver and forwards the messages whose topic it is subscribed to.
//! Each message is serialised once at publish time, not once per connection.

use std::sync::Arc;

use tms_core::Topic;
use tms_core::ws::{ServerMessage, TopicItem};
use tokio::sync::broadcast;
use uuid::Uuid;

#[derive(Debug)]
pub struct Outbound {
  pub topic: Topic,
  pub payload: Payload,
}

#[derive(Debug)]
pub enum Payload {
  /// A serialised `ServerMessage` to forward as-is.
  Json(String),
  /// The topic changed wholesale (e.g. a different event became active); subscribers must resend a snapshot.
  Resnapshot,
}

#[derive(Clone)]
pub struct Bus {
  tx: broadcast::Sender<Arc<Outbound>>,
}

impl Bus {
  pub fn new(capacity: usize) -> Self {
    Self {
      tx: broadcast::channel(capacity).0,
    }
  }

  pub fn subscribe(&self) -> broadcast::Receiver<Arc<Outbound>> {
    self.tx.subscribe()
  }

  pub fn upsert(&self, topic: Topic, item: TopicItem) {
    self.send(&ServerMessage::Upsert { topic, item });
  }

  pub fn delete(&self, topic: Topic, id: Uuid) {
    self.send(&ServerMessage::Delete { topic, id });
  }

  pub fn resnapshot(&self, topic: Topic) {
    let _ = self.tx.send(Arc::new(Outbound {
      topic,
      payload: Payload::Resnapshot,
    }));
  }

  fn send(&self, message: &ServerMessage) {
    let topic = match message {
      ServerMessage::Upsert { topic, .. } | ServerMessage::Delete { topic, .. } => *topic,
      _ => return,
    };
    let json = serde_json::to_string(message).expect("server messages always serialise");
    // An error only means nobody is listening.
    let _ = self.tx.send(Arc::new(Outbound {
      topic,
      payload: Payload::Json(json),
    }));
  }
}
