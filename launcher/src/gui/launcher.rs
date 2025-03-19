use std::sync::Arc;

use egui::{Color32, RichText, Visuals};
use parking_lot::Mutex;
use server::TmsConfig;
use tokio::sync::mpsc::Sender;

use crate::{GuiMessage, ServerState};

use super::ConfigFields;

pub struct Launcher {
  // Channel to send messages to main thread
  pub message_sender: Sender<GuiMessage>,

  // Shared server state
  server_state: Arc<Mutex<ServerState>>,

  // UI state
  pub status_text: RichText,
  pub error_message: Option<String>,

  // Config fields (stringified)
  pub active_cfg: ConfigFields,
}

impl Launcher {
  pub fn new(
    message_sender: Sender<GuiMessage>,
    server_state: Arc<Mutex<ServerState>>,
    config: TmsConfig,
    cc: &eframe::CreationContext<'_>,
  ) -> Self {
    // Set visuals
    let mut visuals = Visuals::dark();
    visuals.panel_fill = Color32::from_hex("#2A2D3E").unwrap_or_default();
    visuals.window_fill = Color32::from_hex("#2A2D3E").unwrap_or_default();
    visuals.extreme_bg_color = Color32::from_hex("#20222f").unwrap_or_default();
    cc.egui_ctx.set_visuals(visuals);

    Launcher {
      message_sender,
      server_state,
      status_text: RichText::new("Server not running"),
      error_message: None,

      // Config fields
      active_cfg: ConfigFields::from(config),
    }
  }

  pub fn update_status_text(&mut self) {
    // Get server state
    let server_state = self.server_state.lock().clone();

    // Update status text
    match server_state {
      ServerState::Running => {
        self.status_text = RichText::new("Server running").color(Color32::GREEN);
      }
      ServerState::Stopped => {
        self.status_text = RichText::new("Server not running");
      }
      ServerState::Error(error) => {
        self.status_text = RichText::new("Server error").color(Color32::RED);
        self.error_message = Some(error);
      }
    }
  }

  pub fn is_server_running(&self) -> bool {
    let state = self.server_state.lock().clone();
    matches!(state, ServerState::Running)
  }

  pub fn start_server(&mut self) {
    // Create TmsConfig from active_cfg
    let config = TmsConfig::from(self.active_cfg.clone());

    // Send start message
    if let Err(e) = self.message_sender.try_send(GuiMessage::StartServer(config)) {
      log::error!("Failed to send start message: {}", e);
      self.error_message = Some("Failed to start server".to_string());
    }
  }

  pub fn stop_server(&mut self) {
    // Send stop message
    if let Err(e) = self.message_sender.try_send(GuiMessage::StopServer) {
      log::error!("Failed to send stop message: {}", e);
      self.error_message = Some("Failed to stop server".to_string());
    }
  }
}
