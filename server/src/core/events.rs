use std::any::{Any, TypeId};

use anyhow::Result;
use dashmap::DashMap;
use once_cell::sync::OnceCell;
use tokio::sync::broadcast;

#[derive(Clone, Debug)]
pub enum ChangeOperation {
  Create,
  Update,
  Delete,
}

#[derive(Clone, Debug)]
pub enum ChangeEvent<T> {
  /// A single database record changed
  Record {
    operation: ChangeOperation,
    id: String,
    data: Option<T>, // None for Delete, Some for Create/Update
  },

  /// A database table changed
  Table,

  /// Integrity check completed with results
  IntegrityUpdate { data: T },

  /// Generic message published to a topic (fallback for future use)
  Message { topic: String, data: T },
}

pub struct EventBus {
  channels: DashMap<TypeId, Box<dyn Any + Send + Sync>>,
  capacity: usize,
}

impl EventBus {
  fn new(capacity: usize) -> Self {
    Self { channels: DashMap::new(), capacity }
  }

  /// Publish an event
  pub fn publish<T: Clone + Send + Sync + 'static>(&self, event: ChangeEvent<T>) -> Result<()> {
    // Only publish if there are subscribers
    if let Some(sender_box) = self.channels.get(&TypeId::of::<T>()) {
      let sender = sender_box
        .downcast_ref::<broadcast::Sender<ChangeEvent<T>>>()
        .ok_or_else(|| anyhow::anyhow!("Type mismatch in EventBus for {}", std::any::type_name::<T>()))?;

      // Ignore send error (happens when no active subscribers)
      let _ = sender.send(event);
    }
    Ok(())
  }

  /// Subscribe to events for a specific type
  pub fn subscribe<T: Clone + Send + Sync + 'static>(&self) -> Result<broadcast::Receiver<ChangeEvent<T>>> {
    let sender_box = self.channels.entry(TypeId::of::<T>()).or_insert_with(|| {
      let (tx, _rx) = broadcast::channel::<ChangeEvent<T>>(self.capacity);
      Box::new(tx) as Box<dyn Any + Send + Sync>
    });

    let sender = sender_box
      .value()
      .downcast_ref::<broadcast::Sender<ChangeEvent<T>>>()
      .ok_or_else(|| anyhow::anyhow!("Type mismatch in EventBus for {}", std::any::type_name::<T>()))?;

    Ok(sender.subscribe())
  }
}

pub static EVENT_BUS: OnceCell<EventBus> = OnceCell::new();

pub fn init_event_bus(capacity: usize) -> Result<()> {
  if EVENT_BUS.get().is_some() {
    log::warn!("Event Bus already initialized");
  } else {
    log::info!("Initializing Event Bus");
    let bus = EventBus::new(capacity);
    EVENT_BUS.set(bus).map_err(|_| anyhow::anyhow!("Failed to set Event Bus"))?;
  }

  Ok(())
}
