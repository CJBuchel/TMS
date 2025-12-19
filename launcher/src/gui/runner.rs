use egui::{Color32, RichText, Visuals};
use server::TmsConfig;
use tokio::sync::{mpsc::Sender, watch};

use crate::{GuiMessage, ServerState};

use super::ConfigFields;

pub struct GuiRunner {
  // Channel to send messages to server management
  pub message_sender: Sender<GuiMessage>,

  // Watch receiver for server state (gets notified on changes)
  state_rx: watch::Receiver<ServerState>,

  // UI state
  pub status_text: RichText,
  pub error_message: Option<String>,

  // Config fields (stringified)
  pub active_cfg: ConfigFields,

  // Cached QR code state
  cached_qr_url: String,
  cached_qr_texture: Option<egui::TextureHandle>,
}

impl GuiRunner {
  pub fn new(
    message_sender: Sender<GuiMessage>,
    state_rx: watch::Receiver<ServerState>,
    config: TmsConfig,
    cc: &eframe::CreationContext<'_>,
  ) -> Self {
    // Set visuals
    let mut visuals = Visuals::dark();
    visuals.panel_fill = Color32::from_hex("#2A2D3E").unwrap_or_default();
    visuals.window_fill = Color32::from_hex("#2A2D3E").unwrap_or_default();
    visuals.extreme_bg_color = Color32::from_hex("#20222f").unwrap_or_default();
    cc.egui_ctx.set_visuals(visuals);

    GuiRunner {
      message_sender,
      state_rx,
      status_text: RichText::new("Server not running"),
      error_message: None,

      // Config fields
      active_cfg: ConfigFields::from(config),

      // Cached QR code state
      cached_qr_url: String::new(),
      cached_qr_texture: None,
    }
  }

  pub fn update_status_text(&mut self) {
    // Check if state changed (non-blocking)
    if self.state_rx.has_changed().unwrap_or(false) {
      // Mark as seen
      self.state_rx.borrow_and_update();
    }

    // Get current server state
    let server_state = self.state_rx.borrow().clone();

    // Update status text
    match server_state {
      ServerState::Starting => {
        self.status_text = RichText::new("Server starting...").color(Color32::YELLOW);
        self.error_message = None;
      }
      ServerState::Running => {
        self.status_text = RichText::new("Server running").color(Color32::GREEN);
        self.error_message = None;
      }
      ServerState::Stopping => {
        self.status_text = RichText::new("Server stopping...").color(Color32::YELLOW);
        self.error_message = None;
      }
      ServerState::Stopped => {
        self.status_text = RichText::new("Server not running");
        self.error_message = None;
      }
      ServerState::Error(error) => {
        self.status_text = RichText::new("Server error").color(Color32::RED);
        self.error_message = Some(error);
      }
    }
  }

  pub fn is_server_running(&self) -> bool {
    matches!(*self.state_rx.borrow(), ServerState::Running)
  }

  pub fn is_server_transitioning(&self) -> bool {
    matches!(*self.state_rx.borrow(), ServerState::Starting | ServerState::Stopping)
  }

  pub fn start_server(&mut self) {
    // Clear error message
    self.error_message = None;

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

  pub fn get_or_create_qr_texture(&mut self, ctx: &egui::Context, server_url: &str) -> Option<&egui::TextureHandle> {
    // Only regenerate if URL changed
    if self.cached_qr_url != server_url {
      log::debug!("Regenerating QR code for URL: {}", server_url);

      // Generate new QR code
      match qrcodegen::QrCode::encode_text(server_url, qrcodegen::QrCodeEcc::Low) {
        Ok(qr) => {
          let qr_image = super::qr_code::qr_to_image(&qr, 6);

          // Load texture - egui handles caching internally by name
          let texture = ctx.load_texture("qr_code_texture", qr_image, egui::TextureOptions::default());

          self.cached_qr_url = server_url.to_string();
          self.cached_qr_texture = Some(texture);
          log::debug!("QR code texture created successfully");
        }
        Err(e) => {
          log::error!("Failed to generate QR code: {:?}", e);
          return None;
        }
      }
    }

    self.cached_qr_texture.as_ref()
  }
}
