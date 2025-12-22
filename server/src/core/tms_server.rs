use tokio::time::Duration;

use anyhow::Result;
use tokio::sync::oneshot;

use crate::{
  TmsConfig,
  auth::jwt::init_jwt_secret,
  core::{api::Api, db::init_db, events::init_event_bus, shutdown::ShutdownNotifier, web::Web},
};

const SERVER_TICK_PERIOD_MS: u64 = 2000; // 10
const SERVER_WARNING_THRESHOLD_MS: u64 = 100; // 100

pub struct TmsServer {
  config: TmsConfig,
  shutdown_rx: Option<oneshot::Receiver<()>>,
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

    let server = Self { config, shutdown_rx: Some(shutdown_rx) };

    let handle = TmsServerHandle { shutdown_tx: Some(shutdown_tx) };

    (server, handle)
  }

  // fn update() -> Result<()> {
  //   Ok(())
  // }

  pub async fn run(mut self) -> Result<()> {
    log::info!("Running Server with config: {:?}", self.config);

    // Take the shutdown receiver (can only be used once)
    let mut shutdown_rx = self.shutdown_rx.take().expect("Server can only have one instance");
    let shutdown_notifier = ShutdownNotifier::get();

    // Create interval for regular server ticks
    let mut interval = tokio::time::interval(Duration::from_millis(SERVER_TICK_PERIOD_MS));

    // Middleware Setups
    init_event_bus(1024)?;
    init_db(&self.config)?;
    init_jwt_secret()?;

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

    // Main server loop
    loop {
      tokio::select! {
        // Regular server tick
        _ = interval.tick() => {
          // Server updates

          let start = std::time::Instant::now();
          // match Self::update() {
          //   Ok(()) => {},
          //   Err(e) => log::error!("Server update error: {:?}", e),
          // }
          let duration = start.elapsed();

          if duration.as_millis() > u128::from(SERVER_WARNING_THRESHOLD_MS) {
            log::warn!("Server work took {}ms (threshold: {}ms)",
                      duration.as_millis(),
                      SERVER_WARNING_THRESHOLD_MS);
          }
        }

        // Check for shutdown signal
        _ = &mut shutdown_rx => {
          log::info!("Server received shutdown signal");
          // Notify all services listening for the shutdown
          shutdown_notifier.notify();
          break;
        }
      }
    }

    // Wait for services to shutdown gracefully

    let timeout_future = async {
      let (api_result, web_result) = tokio::join!(&mut api_handle, &mut web_handle);
      api_result.and(web_result)
    };

    match tokio::time::timeout(Duration::from_secs(5), timeout_future).await {
      Ok(Ok(())) => log::info!("All services shut down gracefully"),
      Ok(Err(e)) => log::error!("Service task panicked: {:?}", e),
      Err(_) => {
        log::warn!("Force aborting...");
        api_handle.abort();
        web_handle.abort();
      }
    }

    log::info!("Server exited gracefully");
    Ok(())
  }
}
