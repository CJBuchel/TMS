use anyhow::Result;
use server::TmsConfig;

pub mod gui;
pub mod logging;
pub mod server_manager;

// Re-export for convenience
pub use server_manager::{ServerManager, ServerState};

/// Run the launcher with GUI
/// The ServerManager will be created and passed to the GUI
pub fn run_launcher(config: TmsConfig) -> Result<()> {
  // Create server manager with its own dedicated runtime
  let server_manager = ServerManager::new()?;

  // Run GUI on main thread (required by winit/eframe on Linux)
  // GUI will control the server via the server_manager
  if let Err(e) = gui::run_gui(server_manager, config) {
    log::error!("GUI error: {}", e);
  }

  log::info!("Launcher exiting");
  // ServerManager will be dropped here, triggering graceful shutdown
  Ok(())
}
