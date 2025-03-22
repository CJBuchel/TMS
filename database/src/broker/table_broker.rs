use std::{
  any::{Any, TypeId},
  collections::HashMap,
  marker::PhantomData,
  pin::Pin,
  sync::Mutex,
  task::{Context, Poll},
};

use once_cell::sync::Lazy;
use slab::Slab;
use tokio::sync::mpsc::{UnboundedReceiver, UnboundedSender};
use tokio_stream::{Stream, StreamExt};

use super::ChangeOperation;

static SUBSCRIBERS: Lazy<Mutex<HashMap<TypeId, Box<dyn Any + Send>>>> = Lazy::new(Default::default);

struct Senders<T>(Slab<UnboundedSender<T>>);
struct BrokerStream<T: Sync + Send + Clone + 'static>(usize, UnboundedReceiver<T>);

fn with_senders<T, F, R>(f: F) -> R
where
  T: Sync + Send + Clone + 'static,
  F: FnOnce(&mut Senders<T>) -> R,
{
  let mut map = SUBSCRIBERS.lock().unwrap();
  let senders = map
    .entry(TypeId::of::<Senders<T>>())
    .or_insert_with(|| Box::new(Senders::<T>(Default::default())));
  f(senders.downcast_mut::<Senders<T>>().unwrap())
}

impl<T: Sync + Send + Clone + 'static> Drop for BrokerStream<T> {
  fn drop(&mut self) {
    with_senders::<T, _, _>(|senders| senders.0.remove(self.0));
  }
}

impl<T: Sync + Send + Clone + 'static> Stream for BrokerStream<T> {
  type Item = T;

  fn poll_next(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Option<Self::Item>> {
    self.1.poll_recv(cx)
  }
}

/// In memory broker for pub/sub channel pattern.
pub struct TableBroker<T>(PhantomData<T>);

impl<T: Sync + Send + Clone + 'static> TableBroker<T> {
  pub fn publish(msg: ChangeOperation<T>) {
    with_senders::<ChangeOperation<T>, _, _>(|senders| {
      for (_, sender) in senders.0.iter_mut() {
        sender.send(msg.clone()).ok();
      }
    });
  }

  pub fn subscribe() -> impl Stream<Item = ChangeOperation<T>> {
    with_senders::<ChangeOperation<T>, _, _>(|senders| {
      let (tx, rx) = tokio::sync::mpsc::unbounded_channel();
      let id = senders.0.insert(tx);
      BrokerStream(id, rx)
    })
  }

  pub fn subscribe_transform<F, U>(f: F) -> impl Stream<Item = U>
  where
    F: Fn(ChangeOperation<T>) -> U + Send + Sync,
  {
    let stream = with_senders::<ChangeOperation<T>, _, _>(|senders| {
      let (tx, rx) = tokio::sync::mpsc::unbounded_channel();
      let id = senders.0.insert(tx);
      BrokerStream(id, rx)
    });

    stream.map(f)
  }
}
