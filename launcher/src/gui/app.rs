use std::{net::IpAddr, str::FromStr};

use egui::{Color32, RichText};
use local_ip_address::local_ip;
use qrcodegen::{QrCode, QrCodeEcc};

use crate::GuiMessage;

use super::{launcher::Launcher, qr_code};

impl eframe::App for Launcher {
  fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
    // Update status text
    self.update_status_text();

    // Get local IP address
    let local_ip = local_ip().unwrap_or(IpAddr::V4(std::net::Ipv4Addr::new(127, 0, 0, 1)));

    // Server URL
    let server_url = format!("http://{}:{}", local_ip, self.active_cfg.port);

    // Check if server is running (to disable config fields)
    let is_running = self.is_server_running();

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
        ui.add_enabled(
          !is_running,
          egui::TextEdit::singleline(&mut self.active_cfg.bind_address).desired_width(150.0),
        );
        if IpAddr::from_str(&self.active_cfg.bind_address).is_err() {
          ui.label(RichText::new("Invalid IP").color(Color32::RED));
        }
      });

      // Port
      ui.horizontal(|ui| {
        ui.label("Port:");
        let mut port_text = self.active_cfg.port.clone();
        let response = ui.add_enabled(
          !is_running,
          egui::TextEdit::singleline(&mut port_text).desired_width(150.0),
        );
        if response.changed() {
          if port_text.is_empty() {
            self.active_cfg.port = port_text;
          } else {
            if let Ok(port) = port_text.parse::<u16>() {
              self.active_cfg.port = port.to_string();
            }
          }
        }
      });

      // Display error if any
      if let Some(error) = &self.error_message {
        ui.add_space(10.0);
        ui.label(RichText::new(error.clone()).color(Color32::RED));
      }
    });

    // Right panel
    egui::SidePanel::right("right_panel").show(ctx, |ui| {
      // generate qr code.
      let qr = QrCode::encode_text(&server_url, QrCodeEcc::Low).unwrap();
      let qr_image = qr_code::qr_to_image(&qr, 6);

      let texture_id = "qr_image".to_owned();
      let texture = ctx.load_texture(texture_id, qr_image, egui::TextureOptions::default());

      ui.vertical_centered(|ui| {
        ui.add_space(10.0);
        ui.image((texture.id(), egui::Vec2::new(150.0, 150.0)));
        ui.add_space(10.0);
        ui.hyperlink(server_url);
        ui.add_space(10.0);
        ui.label(self.status_text.clone());
        ui.add_space(10.0);

        // Start/Stop server button
        let button_text = if is_running { "Stop Server" } else { "Start Server" };

        if ui.button(button_text).clicked() {
          if is_running {
            self.stop_server();
          } else {
            self.start_server();
          }
        }
      });
    });

    // Request repaint
    ctx.request_repaint_after_secs(1.0);
  }

  fn on_exit(&mut self, _gl: Option<&eframe::glow::Context>) {
    // Send exit message
    if let Err(e) = self.message_sender.try_send(GuiMessage::Exit) {
      log::error!("Failed to send exit message: {}", e);
    }
  }
}
