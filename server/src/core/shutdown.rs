use once_cell::sync::Lazy;
use tokio::sync::broadcast;

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
