#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::sync::Arc;

use launcher::{gui, logging, GuiMessage, ServerState};
use parking_lot::Mutex;
use tokio::sync::{mpsc, oneshot};

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

    // Create channel for GUI messages
    let (gui_tx, gui_rx) = mpsc::channel::<GuiMessage>(32);
    let (done_tx, _) = oneshot::channel();

    // Create shared server state
    let shared_state = Arc::new(Mutex::new(ServerState::Stopped));

    // Clone for server thread
    let server_state = shared_state.clone();

    // Start server management thread
    let server_handle = tokio::task::spawn_blocking(move || {
      let rt = tokio::runtime::Builder::new_multi_thread()
        .enable_all()
        .build()
        .expect("Failed to create Tokio runtime for server thread");

      rt.block_on(async move {
        run_server_management(gui_rx, server_state).await;
        // Signal that the server management thread has exited
        let _ = done_tx.send(());
      });
    });

    // Start GUI
    if let Err(e) = gui::run_gui(gui_tx, shared_state, config) {
      log::error!("GUI error: {}", e);
    }

    // Wait for server management thread to exit
    log::info!("GUI closed, waiting for server management to finish...");

    // Wait for server management to complete (with timeout)
    tokio::select! {
      _ = server_handle => (),
      _ = tokio::time::sleep(tokio::time::Duration::from_secs(5)) => (),
    }

    log::info!("Application exiting");
  }
}

async fn run_server_management(mut rx: mpsc::Receiver<GuiMessage>, server_state: Arc<Mutex<ServerState>>) {
  // The server instance (None initially)
  let mut server_instance: Option<server::TmsServer> = None;

  // Server management loop
  loop {
    if let Some(server) = &mut server_instance {
      // Server is running - select between GUI messages and server events
      tokio::select! {
        Some(msg) = rx.recv() => match msg {

          // Stop server
          GuiMessage::StopServer => {
            log::warn!("Stopping server");
            server_instance = None;
            *server_state.lock() = ServerState::Stopped;
          },

          // Exit
          GuiMessage::Exit => break,
          _ => {}
        },

        result = server.run() => {
          match result {
            Ok(_) => {
              log::info!("Server exited successfully");
              *server_state.lock() = ServerState::Stopped;
            },
            Err(e) => {
              log::error!("Server exited with error: {}", e);
              *server_state.lock() = ServerState::Error(e.to_string());
            }
          }

          server_instance = None;
        }
      }
    } else {
      // Server is stopped - wait for messages
      if let Some(msg) = rx.recv().await {
        log::debug!("Received message: {:?}", msg);
        match msg {
          // Start server
          GuiMessage::StartServer(config) => {
            log::info!("Starting server");
            let server = Some(server::TmsServer::new(Some(config)));
            server_instance = server;
            *server_state.lock() = ServerState::Running;
          }

          // Exit
          GuiMessage::Exit => break,
          _ => {}
        }
      } else {
        // Channel closed, exit loop
        break;
      }
    }
  }

  log::info!("Server management thread exiting");
}
