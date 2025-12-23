use std::time::Duration;

use anyhow::Result;
use tokio::task::JoinHandle;

use crate::core::shutdown::ShutdownNotifier;

/// Trait for services that run on a schedule
pub trait ScheduledService: Send + 'static {
  /// How often this service should run
  fn interval(&self) -> Duration;

  /// Human-readable name for logging
  fn name(&self) -> &'static str;

  /// Optional warning threshold - logs a warning if execution exceeds this duration
  /// Returns None by default (no threshold checking)
  fn warning_threshold(&self) -> Option<Duration> {
    None
  }

  /// Execute the service logic
  fn execute(&mut self) -> Result<()>;
}

/// Scheduler for background services
pub struct ServiceScheduler;

impl ServiceScheduler {
  /// Schedule a service to run periodically
  ///
  /// The service will run on its own tokio task at the specified interval.
  /// Returns a JoinHandle that can be awaited during shutdown.
  pub fn schedule<S: ScheduledService>(mut service: S, shutdown: &'static ShutdownNotifier) -> JoinHandle<()> {
    tokio::spawn(async move {
      let mut interval = tokio::time::interval(service.interval());
      let mut shutdown_rx = shutdown.subscribe();
      let name = service.name();

      // Skip first tick to avoid immediate execution on startup
      interval.tick().await;

      log::info!("[{}] Service started (interval: {:?})", name, service.interval());

      loop {
        tokio::select! {
          _ = interval.tick() => {
            let start = std::time::Instant::now();

            match service.execute() {
              Ok(()) => {
                let duration = start.elapsed();

                // Check against warning threshold if configured
                if let Some(threshold) = service.warning_threshold() {
                  if duration > threshold {
                    log::warn!(
                      "[{}] Execution took {}ms (threshold: {}ms)",
                      name,
                      duration.as_millis(),
                      threshold.as_millis()
                    );
                  } else {
                    log::debug!("[{}] Completed in {}ms", name, duration.as_millis());
                  }
                } else {
                  log::debug!("[{}] Completed in {}ms", name, duration.as_millis());
                }
              }
              Err(e) => {
                log::error!("[{}] Service failed: {:?}", name, e);
              }
            }
          }

          _ = shutdown_rx.recv() => {
            log::info!("[{}] Shutting down", name);
            break;
          }
        }
      }
    })
  }
}

/// Manages all scheduled background services
#[derive(Default)]
pub struct ScheduleManager {
  handles: Vec<JoinHandle<()>>,
}

impl ScheduleManager {
  /// Create a new schedule manager
  pub fn new() -> Self {
    Self { handles: Vec::new() }
  }

  /// Schedule a service and track its handle
  pub fn schedule<S: ScheduledService>(&mut self, service: S, shutdown: &'static ShutdownNotifier) {
    let handle = ServiceScheduler::schedule(service, shutdown);
    self.handles.push(handle);
  }

  /// Wait for all scheduled services to complete
  pub async fn wait_all(&mut self) -> Result<()> {
    let handles = std::mem::take(&mut self.handles);

    for handle in handles {
      if let Err(e) = handle.await {
        log::error!("Service task panicked: {:?}", e);
      }
    }

    Ok(())
  }

  /// Abort all scheduled services immediately
  pub fn abort_all(&mut self) {
    for handle in &self.handles {
      handle.abort();
    }
    self.handles.clear();
    log::info!("All scheduled services aborted");
  }

  /// Get count of running services
  pub fn count(&self) -> usize {
    self.handles.len()
  }
}
