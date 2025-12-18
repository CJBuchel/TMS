#![forbid(unsafe_code)]
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use anyhow::Result;
use launcher::logging;
use server::{TmsConfig, core::tms_server::TmsServer};

#[tokio::main]
async fn main() -> Result<()> {
  // Init logger
  logging::init_logging().expect("Failed to initialize logger");

  // Parse CLI
  let config = TmsConfig::parse_from_cli();

  if config.no_gui {
    // Run server directly (headless mode)
    log::info!("Starting TMS (Headless)");
    run_headless(config).await?;
  } else {
    // Run with GUI launcher
    log::info!("Starting TMS Launcher");
    launcher::run_launcher(config).await?;
  }

  Ok(())
}

async fn run_headless(config: TmsConfig) -> Result<()> {
  let (server, mut handle) = TmsServer::new(Some(config));
  let mut server_task = tokio::spawn(async move { server.run().await });

  // Setup Ctrl+C handler
  let shutdown_signal = async {
    tokio::signal::ctrl_c().await.expect("Failed to listen for Ctrl+C");
    log::info!("Received shutdown signal (Ctrl+C)");
  };

  // Wait for shutdown or server exit
  tokio::select! {
    result = &mut server_task => {
      match result {
        Ok(Ok(())) => log::info!("Server exited gracefully"),
        Ok(Err(e)) => log::error!("Server exited with error: {}", e),
        Err(e) => log::error!("Server task panicked: {}", e),
      }
    },
    () = shutdown_signal => {
      log::info!("Shutting down server...");
      handle.shutdown();

      // Wait for server to stop (5 second timeout)
      match tokio::time::timeout(std::time::Duration::from_secs(5), server_task).await {
        Ok(Ok(Ok(()))) => log::info!("Server stopped gracefully"),
        Ok(Ok(Err(e))) => log::error!("Server stopped with error: {}", e),
        Ok(Err(e)) => log::error!("Server task panicked: {}", e),
        Err(_) => {
          log::error!("Server did not stop within 5 seconds");
          std::process::exit(1);
        }
      }
    }
  }

  Ok(())
}
