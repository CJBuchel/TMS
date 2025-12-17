use anyhow::Result;
use log::info;
use server::{TmsConfig, core::tms_server::TmsServer};

pub async fn run_rt_headless(config: TmsConfig) -> Result<()> {
  // Server handle
  let (server, mut handle) = TmsServer::new(Some(config));

  // Spawn the server task
  let mut server_task = tokio::spawn(async move { server.run().await });

  // Setup signal for graceful shutdown
  let shutdown_signal = async {
    match tokio::signal::ctrl_c().await {
      Ok(()) => {
        info!("Received Shutdown signal (Ctrl+C)");
      }
      Err(e) => {
        info!("Error receiving shutdown signal: {}", e);
      }
    }
  };

  // Wait for shutdown signal or server task completion
  tokio::select! {
    result = &mut server_task => {
      match result {
        Ok(Ok(())) => log::info!("Server exited gracefully"),
        Ok(Err(e)) => log::error!("Server exited with error: {}", e),
        Err(e) => log::error!("Server task panicked: {}", e),
      }
    },

    // wait for shutdown signal
    () = shutdown_signal => {
      handle.shutdown();

      // Wait for the server to actually stop (with timeout)
      match tokio::time::timeout(std::time::Duration::from_secs(5), server_task).await {
        Ok(Ok(Ok(()))) => log::info!("Server stopped gracefully"),
        Ok(Ok(Err(e))) => log::error!("Server stopped with error: {}", e),
        Ok(Err(e)) => log::error!("Server task panicked during shutdown: {}", e),
        Err(_) => {
          log::error!("Server did not stop within 5 seconds, forcing exit");
          std::process::exit(1);
        }
      }
    }
  }

  Ok(())
}
