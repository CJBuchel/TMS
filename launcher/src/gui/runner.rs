use egui::{Color32, RichText, Visuals};
use local_ip_address::local_ip;
use server::TmsConfig;
use tokio::sync::watch;

use crate::{ServerManager, ServerState};

use super::ConfigFields;

pub struct GuiRunner {
  // Server manager to control server lifecycle
  server_manager: ServerManager,

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

  // Cached local IP to avoid calling local_ip() every frame (leaks netlink sockets)
  pub cached_local_ip: std::net::IpAddr,

  // Cooldown timer to prevent rapid start/stop
  last_state_change: Option<std::time::Instant>,
  last_observed_state: ServerState,
}

impl GuiRunner {
  pub fn new(server_manager: ServerManager, config: TmsConfig, cc: &eframe::CreationContext<'_>) -> Self {
    // Set visuals
    let mut visuals = Visuals::dark();
    visuals.panel_fill = Color32::from_hex("#2A2D3E").unwrap_or_default();
    visuals.window_fill = Color32::from_hex("#2A2D3E").unwrap_or_default();
    visuals.extreme_bg_color = Color32::from_hex("#20222f").unwrap_or_default();
    cc.egui_ctx.set_visuals(visuals);

    // Get local IP once at startup
    let cached_local_ip = local_ip().unwrap_or(std::net::IpAddr::V4(std::net::Ipv4Addr::LOCALHOST));

    // Subscribe to state changes from the server manager
    let state_rx = server_manager.subscribe_state();

    GuiRunner {
      server_manager,
      state_rx,
      status_text: RichText::new("Server not running"),
      error_message: None,

      // Config fields
      active_cfg: ConfigFields::from(config),

      // Cached QR code state
      cached_qr_url: String::new(),
      cached_qr_texture: None,

      // Cached local IP
      cached_local_ip,

      // Cooldown timer
      last_state_change: None,
      last_observed_state: ServerState::Stopped,
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

    // Track state changes for cooldown timer
    if !std::mem::discriminant(&server_state).eq(&std::mem::discriminant(&self.last_observed_state)) {
      self.last_state_change = Some(std::time::Instant::now());
      self.last_observed_state = server_state.clone();
    }

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

  /// Check if we're in cooldown period (1.5 seconds after any state change)
  pub fn is_in_cooldown(&self) -> bool {
    if let Some(last_change) = self.last_state_change {
      last_change.elapsed() < std::time::Duration::from_millis(1500)
    } else {
      false
    }
  }

  /// Get remaining cooldown time in milliseconds
  pub fn remaining_cooldown_ms(&self) -> u64 {
    if let Some(last_change) = self.last_state_change {
      let elapsed_duration = last_change.elapsed();
      let elapsed = elapsed_duration.as_secs() * 1000 + u64::from(elapsed_duration.subsec_millis());
      1500_u64.saturating_sub(elapsed)
    } else {
      0
    }
  }

  pub fn start_server(&mut self) {
    // Clear error message
    self.error_message = None;

    // Create TmsConfig from active_cfg
    let config = TmsConfig::from(self.active_cfg.clone());

    // Start server via server manager
    if let Err(e) = self.server_manager.start(config) {
      log::error!("Failed to start server: {}", e);
      self.error_message = Some(format!("Failed to start server: {}", e));
    }
  }

  pub fn stop_server(&mut self) {
    // Stop server via server manager
    if let Err(e) = self.server_manager.stop() {
      log::error!("Failed to stop server: {}", e);
      self.error_message = Some(format!("Failed to stop server: {}", e));
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
