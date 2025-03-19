use std::sync::Arc;

use anyhow::Result;
use launcher::{gui, logging, GuiMessage, ServerState};
use parking_lot::Mutex;
use server::TmsConfig;
use tokio::sync::mpsc;

async fn start_gui(config: TmsConfig) -> Result<()> {
  // Setup channel for GUI messages
  let (tx, mut rx) = mpsc::channel::<GuiMessage>(32);

  // Setup shared server state
  let server_state = Arc::new(Mutex::new(ServerState::Stopped));

  // Start gui thread with channels
  let gui_server_state = server_state.clone();
  let gui_handle = tokio::spawn(async move {
    // LauncherGui::new(tx, gui_server_state, config).run_gui().await;
    gui::run_gui(tx, gui_server_state, config)
  });

  // The server instance (None initially)
  let mut server_instance: Option<server::TmsServer> = None;

  // Main thread loop
  loop {
    if let Some(server) = &mut server_instance {
      // Server is running - get runtime messages
      tokio::select! {
        Some(msg) = rx.recv() => match msg {
          GuiMessage::StopServer => {
            server_instance = None;
            *server_state.lock() = ServerState::Stopped;
          },

          GuiMessage::Exit => break, // Exit the main thread loop

          // Ignore start messages while server is already running
          _ => {}
        },

        result = server.run() => {
          // Server has stopped on it's own
          match result {
            Ok(_) => {
              log::info!("Server stopped");
              *server_state.lock() = ServerState::Stopped;
            },
            Err(e) => {
              log::error!("Server stopped with error: {}", e);
              *server_state.lock() = ServerState::Error(e.to_string());
            },
          }

          // Clear server instance
          server_instance = None;
        },
      }
    } else {
      // Server is not running - wait for messages
      if let Some(msg) = rx.recv().await {
        match msg {
          GuiMessage::StartServer(config) => {
            log::info!("Starting server");
            // Start the server
            let server = server::TmsServer::new(Some(config));
            server_instance = Some(server);
            *server_state.lock() = ServerState::Running;
          }

          GuiMessage::Exit => break, // Exit the main thread loop

          // Ignore stop messages while server is not running
          _ => {}
        }
      }
    }
  }

  // Wait for GUI thread to finish
  match gui_handle.await {
    Ok(_) => Ok(()),
    Err(e) => Err(e.into()),
  }
}

// tokio main
#[tokio::main]
async fn main() {
  // Initialize logger
  logging::init_logging().expect("Failed to initialize logger");

  // Parse CLI args
  let config = server::TmsConfig::parse_from_cli();

  if config.no_gui {
    // Start without GUI
    log::info!("Starting TMS (No GUI)");
    let server = server::TmsServer::new(Some(config));
    match server.run().await {
      Ok(_) => log::info!("TMS exited successfully"),
      Err(e) => log::error!("TMS exited with error: {}", e),
    }
  } else {
    // Start with GUI
    log::info!("Starting TMS");
    match start_gui(config).await {
      Ok(_) => log::info!("TMS exited successfully"),
      Err(e) => log::error!("TMS exited with error: {}", e),
    }
  }
}
