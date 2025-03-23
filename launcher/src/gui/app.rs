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
    let protocol = if self.active_cfg.tls { "https" } else { "http" };
    let server_url = format!("{}://{}:{}", protocol, local_ip, self.active_cfg.port);

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

      ui.separator();
      ui.add_space(10.0);

      // Enable playground
      ui.horizontal(|ui| {
        ui.add_enabled(
          !is_running,
          egui::Checkbox::new(&mut self.active_cfg.api_playground, "Enable API Playground"),
        );

        // add orange text warning if enabled
        if self.active_cfg.api_playground {
          ui.label(RichText::new("Warning: For Debug Only!").color(Color32::ORANGE));
        }
      });

      // Enable TLS
      ui.horizontal(|ui| {
        ui.add_enabled(!is_running, egui::Checkbox::new(&mut self.active_cfg.tls, "Enable TLS"));
      });

      // ui.add_space(10.0);

      // // Database path
      // ui.horizontal(|ui| {
      //   ui.label("Database Path:");
      //   ui.add_enabled(
      //     !is_running,
      //     egui::TextEdit::singleline(&mut self.active_cfg.db_path).desired_width(150.0),
      //   );
      // });

      ui.separator();
      ui.add_space(10.0);

      // Certificate path
      {
        ui.label("Certificate Path:");
        ui.horizontal(|ui| {
          // Display the current path
          ui.add_enabled(
            !is_running,
            egui::TextEdit::singleline(&mut self.active_cfg.cert_path).desired_width(150.0),
          );

          // Browse button
          if ui.add_enabled(!is_running, egui::Button::new("Browse...")).clicked() {
            if let Some(picked_path) = rfd::FileDialog::new().pick_file() {
              self.active_cfg.cert_path = picked_path.to_str().unwrap_or_default().to_string();
            }
          }
        });
      }

      ui.add_space(10.0);

      // Key path
      {
        ui.label("Key Path:");
        ui.horizontal(|ui| {
          // Display the current path
          ui.add_enabled(
            !is_running,
            egui::TextEdit::singleline(&mut self.active_cfg.key_path).desired_width(150.0),
          );

          // Browse button
          if ui.add_enabled(!is_running, egui::Button::new("Browse...")).clicked() {
            if let Some(picked_path) = rfd::FileDialog::new().pick_file() {
              self.active_cfg.key_path = picked_path.to_str().unwrap_or_default().to_string();
            }
          }
        });
      }

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
