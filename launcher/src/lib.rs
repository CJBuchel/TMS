use anyhow::Result;
use server::{
  TmsConfig,
  core::tms_server::{TmsServer, TmsServerHandle},
};
use tokio::sync::{mpsc, watch};

pub mod gui;
pub mod logging;

#[derive(Debug, Clone)]
pub enum ServerState {
  Stopped,
  Starting,
  Running,
  Stopping,
  Error(String),
}

#[derive(Debug)]
pub enum GuiMessage {
  StartServer(TmsConfig),
  StopServer,
  Exit,
}

/// Run the launcher with GUI
pub fn run_launcher(config: TmsConfig) -> Result<()> {
  // Create channels
  let (msg_tx, msg_rx) = mpsc::channel::<GuiMessage>(32);
  let (state_tx, state_rx) = watch::channel(ServerState::Stopped);

  // Spawn server management on Tokio runtime
  tokio::spawn(async move {
    run_server_management(msg_rx, state_tx).await;
  });

  // Run GUI on main thread (required by winit/eframe on Linux)
  if let Err(e) = gui::run_gui(msg_tx, state_rx, config) {
    log::error!("GUI error: {}", e);
  }

  log::info!("Launcher exiting");
  Ok(())
}

async fn run_server_management(mut msg_rx: mpsc::Receiver<GuiMessage>, state_tx: watch::Sender<ServerState>) {
  let mut server_instance: Option<(tokio::task::JoinHandle<Result<()>>, TmsServerHandle)> = None;

  loop {
    if let Some((server_task, _)) = &mut server_instance {
      // Server running - wait for messages or server exit
      tokio::select! {
        Some(msg) = msg_rx.recv() => {
          match msg {
            GuiMessage::StopServer => {
              log::info!("Stopping server");
              let _ = state_tx.send(ServerState::Stopping);

              if let Some((server_task, mut handle)) = server_instance.take() {
                handle.shutdown();

                // Wait for server to actually stop (with timeout)
                match tokio::time::timeout(std::time::Duration::from_secs(5), server_task).await {
                  Ok(Ok(Ok(()))) => log::info!("Server stopped gracefully"),
                  Ok(Ok(Err(e))) => log::error!("Server stopped with error: {}", e),
                  Ok(Err(e)) => log::error!("Server task panicked: {}", e),
                  Err(_) => log::error!("Server did not stop within 5 seconds"),
                }
              }
              let _ = state_tx.send(ServerState::Stopped);
            },
            GuiMessage::Exit => {
              log::info!("Received exit signal");
              if let Some((_, mut handle)) = server_instance.take() {
                log::info!("Shutting down server before exit");
                handle.shutdown();
              }
              let _ = state_tx.send(ServerState::Stopped);
              break;
            },
            GuiMessage::StartServer(_) => {
              log::warn!("Received StartServer while server already running");
            }
          }
        },
        result = server_task => {
          match result {
            Ok(Ok(())) => {
              log::info!("Server exited gracefully");
              let _ = state_tx.send(ServerState::Stopped);
            },
            Ok(Err(e)) => {
              log::error!("Server exited with error: {}", e);
              let _ = state_tx.send(ServerState::Error(e.to_string()));
            },
            Err(e) => {
              log::error!("Server task panicked: {}", e);
              let _ = state_tx.send(ServerState::Error(e.to_string()));
            }
          }
          server_instance = None;
        }
      }
    } else {
      // Server stopped - wait for messages
      if let Some(msg) = msg_rx.recv().await {
        match msg {
          GuiMessage::StartServer(config) => {
            log::info!("Starting server");
            let _ = state_tx.send(ServerState::Starting);

            let (server, handle) = TmsServer::new(Some(config));
            let server_task = tokio::spawn(async move { server.run().await });
            server_instance = Some((server_task, handle));

            let _ = state_tx.send(ServerState::Running);
          }
          GuiMessage::Exit => {
            log::info!("Received exit signal while server stopped");
            break;
          }
          GuiMessage::StopServer => {
            log::warn!("Received StopServer while server not running");
          }
        }
      } else {
        log::info!("GUI message channel closed, exiting server management");
        break;
      }
    }
  }

  log::info!("Server management loop exited");
}
