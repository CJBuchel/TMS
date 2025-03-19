use std::{net::IpAddr, sync::Arc};

use egui::{Color32, RichText, Visuals};
use local_ip_address::local_ip;
use parking_lot::Mutex;
use server::TmsConfig;
use tokio::sync::mpsc::Sender;

use crate::{GuiMessage, ServerState};

struct ConfigFields {
  port: String,
  bind_address: String,
}

struct LauncherGui {
  // Channel to send messages to main thread
  message_sender: Sender<GuiMessage>,

  // Shared server state
  server_state: Arc<Mutex<ServerState>>,

  // Config
  config: TmsConfig,

  // UI state
  status_text: RichText,
  error_message: Option<String>,

  // Config fields (stringified)
  active_cfg: ConfigFields,
}

impl LauncherGui {
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

    LauncherGui {
      message_sender,
      server_state,
      config: config.clone(),
      status_text: RichText::new("Server not running"),
      error_message: None,

      // Config fields
      active_cfg: ConfigFields {
        port: config.web_port.to_string(),
        bind_address: config.addr.to_string(),
      },
    }
  }

  fn update_status_text(&mut self) {
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

  fn is_server_running(&self) -> bool {
    let state = self.server_state.lock().clone();
    matches!(state, ServerState::Running)
  }

  fn start_server(&mut self) {}
  fn stop_server(&mut self) {}
}

impl eframe::App for LauncherGui {
  fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
    self.update_status_text();

    // Get local IP address
    let local_ip = local_ip().unwrap_or(IpAddr::V4(std::net::Ipv4Addr::new(127, 0, 0, 1)));

    // Server URL
    let server_url = format!("http://{}:{}", local_ip, self.config.web_port);

    // Check if server is running (to disable config fields)
    let server_running = self.is_server_running();

    // Teal color
    let teal_color = Color32::from_hex("#009485").unwrap_or_default();

    // Header panel
    egui::TopBottomPanel::top("header")
      .frame(
        egui::Frame::NONE
          .fill(teal_color)
          .inner_margin(egui::Margin::symmetric(10, 10)),
      )
      .show(ctx, |ui| {
        ui.horizontal(|ui| {
          ui.image(egui::include_image!("../../assets/TMS_LOGO_WHITE.svg"));
        });
      });

    // Central panel
    egui::CentralPanel::default().show(ctx, |ui| {
      // Configuration section
      ui.heading("Configuration");
      ui.add_space(10.0);

      // Server binding
      ui.horizontal(|ui| {
        ui.label("Binding:");
        ui.add(egui::TextEdit::singleline(&mut self.active_cfg.bind_address).desired_width(150.0));
        if IpAddr::from_str(&self.active_cfg.bind_address).is_err() {
          ui.label(RichText::new("Invalid IP").color(Color32::RED));
        }
      });

      // Port
      ui.horizontal(|ui| {
        ui.label("Port:");
        let mut port_text = self.port.to_string();
        let response = ui.add(egui::TextEdit::singleline(&mut port_text).desired_width(150.0));
        if response.changed() {
          if port_text.is_empty() {
            self.port = port_text;
          } else {
            if let Ok(port) = port_text.parse::<u16>() {
              self.port = port.to_string();
            }
          }
        }
      });
    });
  }
}

pub fn run_gui(message_sender: Sender<GuiMessage>, server_state: Arc<Mutex<ServerState>>, config: TmsConfig) {
  // let gui = LauncherGui::new(message_sender, server_state, config);
  // eframe::run_native(
  //   eframe::NativeOptions {
  //     initial_window_size: Some(egui::vec2(800.0, 600.0)),
  //     ..Default::default()
  //   },
  //   gui,
  // );
}
