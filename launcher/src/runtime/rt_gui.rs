use std::sync::Arc;

use anyhow::Result;
use parking_lot::Mutex;
use server::{
  TmsConfig,
  core::tms_server::{TmsServer, TmsServerHandle},
};
use tokio::sync::{mpsc, oneshot};

use crate::{GuiMessage, ServerState, gui};

async fn run_server_management(mut rx: mpsc::Receiver<GuiMessage>, server_state: Arc<Mutex<ServerState>>) {
  // The server task and shutdown handle (None initially)
  let mut server_instance: Option<(tokio::task::JoinHandle<anyhow::Result<()>>, TmsServerHandle)> = None;

  // Server management loop
  loop {
    if let Some((server_task, _)) = &mut server_instance {
      // Server is running - select between GUI messages and server events
      tokio::select! {
        Some(msg) = rx.recv() => match msg {

          // Stop server
          GuiMessage::StopServer => {
            log::warn!("Stopping server");

            // Request graceful shutdown using the handle
            if let Some((_, mut handle)) = server_instance.take() {
              handle.shutdown();
            }

            *server_state.lock() = ServerState::Stopped;
          },

          // Exit
          GuiMessage::Exit => {
            // Shutdown server if running
            if let Some((_, mut handle)) = server_instance.take() {
              handle.shutdown();
            }
            break;
          },

          GuiMessage::StartServer(_) => {}
        },

        result = server_task => {
          match result {
            Ok(Ok(())) => {
              log::info!("Server exited gracefully");
              *server_state.lock() = ServerState::Stopped;
            },
            Ok(Err(e)) => {
              log::error!("Server exited with error: {}", e);
              *server_state.lock() = ServerState::Error(e.to_string());
            },
            Err(e) => {
              log::error!("Server task panicked: {}", e);
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

            // Create server and handle using the new API
            let (server, handle) = TmsServer::new(Some(config));

            // Spawn server task
            let server_task = tokio::spawn(async move { server.run().await });

            server_instance = Some((server_task, handle));
            *server_state.lock() = ServerState::Running;
          }

          // Exit
          GuiMessage::Exit => break,

          GuiMessage::StopServer => {}
        }
      } else {
        // Channel closed, exit loop
        break;
      }
    }
  }
}

pub async fn run_rt_gui(config: TmsConfig) -> Result<()> {
  // Create channel for GUI messages
  let (gui_tx, gui_rx) = mpsc::channel::<GuiMessage>(16);
  let (done_tx, done_rx) = oneshot::channel();

  // Create shared server state
  let shared_state = Arc::new(Mutex::new(ServerState::Stopped));

  // Clone for server thread
  let server_state = shared_state.clone();

  // Start server management thread
  let server_handle = tokio::task::spawn_blocking(move || {
    let rt = tokio::runtime::Builder::new_multi_thread()
      .enable_all()
      .build()
      .expect("Failed to create Tokio runtime for management thread");

    rt.block_on(async move {
      run_server_management(gui_rx, server_state).await;
      // Signal that the server management thread has exited
      let _ = done_tx.send(());
    });
  });

  // Start GUI - this will block until the GUI exits
  // The GUI framework will handle window close events and system shutdown
  if let Err(e) = gui::run_gui(gui_tx, shared_state, config) {
    log::error!("GUI error: {}", e);
  }

  // GUI has closed, wait for server management thread to cleanup
  log::info!("GUI closed, waiting for server management to exit...");

  // Wait for the done signal or timeout
  tokio::select! {
    _ = done_rx => {
      log::info!("Server management thread signaled completion");
    }
    () = tokio::time::sleep(std::time::Duration::from_secs(5)) => {
      log::warn!("Server management thread did not signal completion within 5 seconds");
    }
  }

  // Wait for the actual thread to finish with a timeout
  let timeout_result = tokio::time::timeout(std::time::Duration::from_secs(3), server_handle).await;

  match timeout_result {
    Ok(Ok(())) => {
      log::info!("Server management thread exited gracefully");
    }
    Ok(Err(e)) => {
      log::error!("Server management thread exited with error: {}", e);
    }
    Err(_) => {
      log::error!("Server management thread did not exit in time, terminating...");
      // Note: We can't really force-kill a blocking task cleanly,
      // but the process will exit anyway
    }
  }

  Ok(())
}
