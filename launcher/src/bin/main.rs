#![forbid(unsafe_code)]
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use anyhow::Result;
use launcher::{ServerManager, logging};
use server::TmsConfig;

fn main() -> Result<()> {
  // Init logger
  logging::init_logging().expect("Failed to initialize logger");

  // Parse CLI
  let config = TmsConfig::parse_from_cli();

  if config.no_gui {
    // Run server in headless mode with auto-start
    log::info!("Starting TMS (Headless)");
    run_headless(config)?;
  } else {
    // Run with GUI launcher
    log::info!("Starting TMS Launcher");
    launcher::run_launcher(config)?;
  }

  Ok(())
}

fn run_headless(config: TmsConfig) -> Result<()> {
  // Create server manager with dedicated runtime
  let server_manager = ServerManager::new()?;

  // Start server immediately in headless mode
  log::info!("Starting server in headless mode");
  server_manager.start(config)?;

  // Wait for Ctrl+C signal
  log::info!("Server running. Press Ctrl+C to shutdown.");

  // Set up Ctrl+C handler using a simple blocking approach
  match ctrlc::set_handler(move || {
    log::info!("Received Ctrl+C signal, shutting down...");
    std::process::exit(0);
  }) {
    Ok(()) => {
      // Block forever until Ctrl+C
      std::thread::park();
    }
    Err(e) => {
      log::error!("Failed to set Ctrl+C handler: {}", e);
      return Err(anyhow::anyhow!("Failed to set Ctrl+C handler"));
    }
  }

  // ServerManager will be dropped on exit, triggering graceful shutdown
  Ok(())
}
