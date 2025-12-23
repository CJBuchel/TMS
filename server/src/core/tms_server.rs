use tokio::time::Duration;

use anyhow::Result;
use tokio::sync::oneshot;

use crate::{
  TmsConfig,
  auth::jwt::init_jwt_secret,
  core::{
    api::Api, db::init_db, events::init_event_bus, scheduler::ScheduleManager, shutdown::ShutdownNotifier, web::Web,
  },
  modules::integrity::IntegrityCheckService,
};

pub struct TmsServer {
  config: TmsConfig,
  shutdown_rx: Option<oneshot::Receiver<()>>,
  scheduler: ScheduleManager,
}

pub struct TmsServerHandle {
  shutdown_tx: Option<oneshot::Sender<()>>,
}

impl TmsServerHandle {
  /// Request graceful shutdown
  pub fn shutdown(&mut self) {
    if let Some(tx) = self.shutdown_tx.take() {
      let _ = tx.send(());
    }
  }
}

impl TmsServer {
  pub fn new(config: Option<TmsConfig>) -> (Self, TmsServerHandle) {
    let config = match config {
      Some(cfg) => cfg,
      None => TmsConfig::parse_from_cli(),
    };

    let (shutdown_tx, shutdown_rx) = oneshot::channel();

    let server = Self { config, shutdown_rx: Some(shutdown_rx), scheduler: ScheduleManager::new() };

    let handle = TmsServerHandle { shutdown_tx: Some(shutdown_tx) };

    (server, handle)
  }

  pub async fn run(mut self) -> Result<()> {
    log::info!("Running Server with config: {:?}", self.config);

    // Take the shutdown receiver (can only be used once)
    let shutdown_rx = self.shutdown_rx.take().expect("Server can only have one instance");
    let shutdown_notifier = ShutdownNotifier::get();

    // Middleware Setups
    init_event_bus(1024)?;
    init_db(&self.config)?;
    init_jwt_secret()?;

    // Schedule background services
    self.scheduler.schedule(IntegrityCheckService::with_default_interval(), shutdown_notifier);

    // Add more scheduled services here as needed:
    // self.scheduler.schedule(BackupService::new(Duration::from_secs(300)), shutdown_notifier);

    log::info!("Scheduled {} background service(s)", self.scheduler.count());

    // Create serving address

    // Start API server
    let api_socket_addr =
      format!("{}:{}", self.config.addr, self.config.api_port).parse().expect("Error parsing API address");
    let api_server = Api::new(api_socket_addr);
    let mut api_handle = tokio::spawn(async move {
      if let Err(e) = api_server.serve().await {
        log::error!("API Server Error: {:?}", e);
      }
    });

    // Start Web Server
    let web_socket_addr =
      format!("{}:{}", self.config.addr, self.config.web_port).parse().expect("Error parsing API address");
    let web_server = Web::new(web_socket_addr, "client/build/web".to_string());
    let mut web_handle = tokio::spawn(async move {
      if let Err(e) = web_server.serve().await {
        log::error!("Web Server Error: {:?}", e);
      }
    });

    // Wait for shutdown signal
    shutdown_rx.await.ok();
    log::info!("Server received shutdown signal");

    // Notify all services to begin graceful shutdown
    shutdown_notifier.notify();

    // Wait for services to shutdown gracefully

    let timeout_future = async {
      let (api_result, web_result) = tokio::join!(&mut api_handle, &mut web_handle);
      let combined_result = api_result.and(web_result);

      // Wait for scheduled services
      if let Err(e) = self.scheduler.wait_all().await {
        log::error!("Scheduled services error: {:?}", e);
        return combined_result;
      }

      combined_result
    };

    match tokio::time::timeout(Duration::from_secs(5), timeout_future).await {
      Ok(Ok(())) => log::info!("All services shut down gracefully"),
      Ok(Err(e)) => log::error!("Service task panicked: {:?}", e),
      Err(_) => {
        log::warn!("Shutdown timeout - force aborting...");
        api_handle.abort();
        web_handle.abort();
        self.scheduler.abort_all();
      }
    }

    log::info!("Server exited gracefully");
    Ok(())
  }
}
