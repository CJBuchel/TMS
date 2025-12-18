use once_cell::sync::Lazy;
use tokio::sync::broadcast;
use tokio_stream::{Stream, StreamExt};

pub static SHUTDOWN_NOTIFIER: Lazy<ShutdownNotifier> = Lazy::new(|| {
  let (tx, _) = broadcast::channel(1024);
  ShutdownNotifier { tx }
});

pub struct ShutdownNotifier {
  tx: broadcast::Sender<()>,
}

impl ShutdownNotifier {
  pub fn get() -> &'static Self {
    &SHUTDOWN_NOTIFIER
  }

  pub fn subscribe(&self) -> broadcast::Receiver<()> {
    self.tx.subscribe()
  }

  pub fn notify(&self) {
    let _ = self.tx.send(());
  }
}

/// Wraps any stream and terminates it when shutdown is signaled
pub fn with_shutdown<S, T>(stream: S) -> impl Stream<Item = T> + Send
where
  S: Stream<Item = T> + Send + 'static,
  T: Send + 'static,
{
  let mut shutdown_rx = ShutdownNotifier::get().subscribe();

  // Extract just the response type name from Result<ResponseType, Status>
  let full_type = std::any::type_name::<T>();
  let stream_type = full_type
    .split("Result<")
    .nth(1)
    .and_then(|s| s.split(',').next())
    .and_then(|s| s.split("::").last())
    .unwrap_or(full_type);

  async_stream::stream! {
    tokio::pin!(stream);

    loop {
      tokio::select! {
        item = stream.next() => {
          match item {
            Some(value) => yield value,
            None => break,
          }
        }
        _ = shutdown_rx.recv() => {
          log::warn!("Stream<{}> terminated due to shutdown signal", stream_type);
          break;
        }
      }
    }
  }
}
