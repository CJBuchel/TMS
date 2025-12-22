use anyhow::Result;
use server::{
  TmsConfig,
  core::tms_server::{TmsServer, TmsServerHandle},
};
use tokio::sync::{mpsc, watch};

#[derive(Debug, Clone, PartialEq)]
pub enum ServerState {
  Stopped,
  Starting,
  Running,
  Stopping,
  Error(String),
}

#[derive(Debug)]
enum ServerCommand {
  Start(TmsConfig),
  Stop,
  Shutdown,
}

/// Manages the server lifecycle with its own dedicated tokio runtime
pub struct ServerManager {
  // Dedicated runtime for server tasks (must be kept alive)
  _runtime: tokio::runtime::Runtime,

  // Channel to send commands to server management task
  command_tx: mpsc::Sender<ServerCommand>,

  // Watch channel to observe server state
  state_rx: watch::Receiver<ServerState>,
}

impl ServerManager {
  /// Create a new server manager with its own tokio runtime
  pub fn new() -> Result<Self> {
    log::info!("Creating server manager with dedicated runtime");

    // Create dedicated multi-threaded runtime for server operations
    let runtime = tokio::runtime::Builder::new_multi_thread().enable_all().thread_name("tms-server-worker").build()?;

    // Create channels
    let (command_tx, command_rx) = mpsc::channel::<ServerCommand>(32);
    let (state_tx, state_rx) = watch::channel(ServerState::Stopped);

    // Spawn the server management task on the runtime
    runtime.spawn(async move {
      run_server_management_loop(command_rx, state_tx).await;
    });

    Ok(ServerManager { _runtime: runtime, command_tx, state_rx })
  }

  /// Start the server with the given configuration
  pub fn start(&self, config: TmsConfig) -> Result<()> {
    self.command_tx.blocking_send(ServerCommand::Start(config))?;
    Ok(())
  }

  /// Stop the server gracefully
  pub fn stop(&self) -> Result<()> {
    self.command_tx.blocking_send(ServerCommand::Stop)?;
    Ok(())
  }

  /// Get current server state
  pub fn state(&self) -> ServerState {
    self.state_rx.borrow().clone()
  }

  /// Subscribe to state changes
  pub fn subscribe_state(&self) -> watch::Receiver<ServerState> {
    self.state_rx.clone()
  }

  /// Shutdown the server manager (called on drop or explicit shutdown)
  fn shutdown_internal(&self) {
    log::info!("Shutting down server manager");
    let _ = self.command_tx.blocking_send(ServerCommand::Shutdown);
    // Runtime will be shut down when dropped
  }
}

impl Drop for ServerManager {
  fn drop(&mut self) {
    log::info!("ServerManager being dropped, initiating shutdown");
    self.shutdown_internal();
    // Runtime will be shut down when it's dropped
    // Note: We can't call shutdown_timeout because it consumes self
  }
}

/// The main server management loop that runs on the dedicated runtime
async fn run_server_management_loop(
  mut command_rx: mpsc::Receiver<ServerCommand>,
  state_tx: watch::Sender<ServerState>,
) {
  let mut server_instance: Option<(tokio::task::JoinHandle<Result<()>>, TmsServerHandle)> = None;

  loop {
    if let Some((server_task, _)) = &mut server_instance {
      // Server running - wait for commands or server exit
      tokio::select! {
        Some(cmd) = command_rx.recv() => {
          match cmd {
            ServerCommand::Stop => {
              log::info!("Received stop command");
              if let Err(e) = stop_server(&mut server_instance, &state_tx).await {
                log::error!("Error stopping server: {}", e);
                let _ = state_tx.send(ServerState::Error(e.to_string()));
              }
            },
            ServerCommand::Shutdown => {
              log::info!("Received shutdown command while server running");
              let _ = stop_server(&mut server_instance, &state_tx).await;
              break;
            },
            ServerCommand::Start(_) => {
              log::warn!("Received start command while server already running");
            }
          }
        },
        result = server_task => {
          // Server task completed (exit or crash)
          handle_server_exit(result, &state_tx);
          server_instance = None;
        }
      }
    } else {
      // Server stopped - wait for commands
      if let Some(cmd) = command_rx.recv().await {
        match cmd {
          ServerCommand::Start(config) => {
            log::info!("Received start command");
            if let Err(e) = start_server(config, &mut server_instance, &state_tx).await {
              log::error!("Failed to start server: {}", e);
              let _ = state_tx.send(ServerState::Error(e.to_string()));
            }
          }
          ServerCommand::Shutdown => {
            log::info!("Received shutdown command while server stopped");
            break;
          }
          ServerCommand::Stop => {
            log::warn!("Received stop command while server not running");
          }
        }
      } else {
        log::info!("Command channel closed, exiting server management");
        break;
      }
    }
  }

  log::info!("Server management loop exited");
}

/// Start the server and wait for it to actually be running
async fn start_server(
  config: TmsConfig,
  server_instance: &mut Option<(tokio::task::JoinHandle<Result<()>>, TmsServerHandle)>,
  state_tx: &watch::Sender<ServerState>,
) -> Result<()> {
  let _ = state_tx.send(ServerState::Starting);

  let (server, handle) = TmsServer::new(Some(config));

  // Clone state_tx to move into the spawn
  let state_tx_clone = state_tx.clone();

  let server_task = tokio::spawn(async move {
    // Run the server and handle the result
    match server.run().await {
      Ok(()) => {
        log::info!("Server task completed successfully");
        Ok(())
      }
      Err(e) => {
        log::error!("Server task failed: {}", e);
        // Send error state immediately
        let _ = state_tx_clone.send(ServerState::Error(e.to_string()));
        Err(e)
      }
    }
  });

  *server_instance = Some((server_task, handle));

  // Wait briefly to see if server fails immediately during initialization
  tokio::time::sleep(std::time::Duration::from_millis(200)).await;

  // Check if we're still in Starting state (not transitioned to Error)
  if matches!(*state_tx.borrow(), ServerState::Starting) {
    let _ = state_tx.send(ServerState::Running);
    log::info!("Server transitioned to Running state");
  }

  Ok(())
}

/// Stop the server gracefully
async fn stop_server(
  server_instance: &mut Option<(tokio::task::JoinHandle<Result<()>>, TmsServerHandle)>,
  state_tx: &watch::Sender<ServerState>,
) -> Result<()> {
  let _ = state_tx.send(ServerState::Stopping);

  if let Some((server_task, mut handle)) = server_instance.take() {
    handle.shutdown();

    // Wait for server to actually stop (with timeout)
    match tokio::time::timeout(std::time::Duration::from_secs(5), server_task).await {
      Ok(Ok(Ok(()))) => log::info!("Server stopped gracefully"),
      Ok(Ok(Err(e))) => log::warn!("Server stopped with error: {}", e),
      Ok(Err(e)) => log::error!("Server task panicked: {}", e),
      Err(_) => {
        log::error!("Server did not stop within 5 seconds");
        return Err(anyhow::anyhow!("Server shutdown timeout"));
      }
    }
  }

  let _ = state_tx.send(ServerState::Stopped);
  Ok(())
}

/// Handle server task exit
fn handle_server_exit(result: Result<Result<()>, tokio::task::JoinError>, state_tx: &watch::Sender<ServerState>) {
  match result {
    Ok(Ok(())) => {
      log::info!("Server exited gracefully");
      let _ = state_tx.send(ServerState::Stopped);
    }
    Ok(Err(e)) => {
      log::error!("Server exited with error: {}", e);
      let _ = state_tx.send(ServerState::Error(e.to_string()));
    }
    Err(e) => {
      log::error!("Server task panicked: {}", e);
      let _ = state_tx.send(ServerState::Error(format!("Server panic: {}", e)));
    }
  }
}
