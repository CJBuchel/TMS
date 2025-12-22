use std::{net::IpAddr, str::FromStr};

use egui::{Color32, RichText};

use crate::gui::runner::GuiRunner;

impl eframe::App for GuiRunner {
  fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
    // Update status text
    self.update_status_text();

    // Use cached local IP address (calling local_ip() every frame leaks netlink sockets)
    let local_ip = self.cached_local_ip;

    // Server URL
    let protocol = if self.active_cfg.tls { "https" } else { "http" };
    let server_url = format!("{}://{}:{}", protocol, local_ip, self.active_cfg.web_port);

    // Check if server is running (to disable config fields)
    let is_running = self.is_server_running();

    // Teal color
    let teal_color = Color32::from_hex("#009485").unwrap_or_default();

    // Header panel
    egui::TopBottomPanel::top("header")
      .frame(egui::Frame::NONE.fill(teal_color).inner_margin(egui::Margin::symmetric(10, 10)))
      .show(ctx, |ui| {
        ui.horizontal(|ui| {
          ui.image(egui::include_image!("../../assets/TMS_Logo.png"));
        });
      });

    // Central panel
    egui::CentralPanel::default().show(ctx, |ui| {
      // Configuration section
      ui.heading("Configuration");
      ui.add_space(10.0);

      // Admin password
      ui.horizontal(|ui| {
        ui.label("Admin Password:");
        ui.add_enabled(
          !is_running,
          egui::TextEdit::singleline(&mut self.active_cfg.admin_password)
            .desired_width(150.0)
            .password(true)
            .hint_text("Using default..."),
        );
      });

      // Server binding
      ui.horizontal(|ui| {
        ui.label("Binding:");
        ui.add_enabled(!is_running, egui::TextEdit::singleline(&mut self.active_cfg.bind_address).desired_width(150.0));
        if IpAddr::from_str(&self.active_cfg.bind_address).is_err() {
          ui.label(RichText::new("Invalid IP").color(Color32::RED));
        }
      });

      // Web Port
      ui.horizontal(|ui| {
        ui.label("Web Port:");
        let mut port_text = self.active_cfg.web_port.clone();
        let response = ui.add_enabled(!is_running, egui::TextEdit::singleline(&mut port_text).desired_width(150.0));
        if response.changed() {
          if port_text.is_empty() {
            self.active_cfg.web_port = port_text;
          } else if let Ok(port) = port_text.parse::<u16>() {
            self.active_cfg.web_port = port.to_string();
          }
        }
      });

      // API Port
      ui.horizontal(|ui| {
        ui.label("API Port:");
        let mut port_text = self.active_cfg.api_port.clone();
        let response = ui.add_enabled(!is_running, egui::TextEdit::singleline(&mut port_text).desired_width(150.0));
        if response.changed() {
          if port_text.is_empty() {
            self.active_cfg.api_port = port_text;
          } else if let Ok(port) = port_text.parse::<u16>() {
            self.active_cfg.api_port = port.to_string();
          }
        }
      });

      // Proxy token
      ui.horizontal(|ui| {
        ui.label("Proxy Token:");
        let mut token_text = self.active_cfg.proxy_token.clone();
        let response = ui.add_enabled(!is_running, egui::TextEdit::singleline(&mut token_text).desired_width(150.0));
        if response.changed() {
          self.active_cfg.proxy_token = token_text;
        }
      });

      // Proxy domain
      ui.horizontal(|ui| {
        ui.label("Proxy Domain:");
        let mut domain_text = self.active_cfg.proxy_domain.clone();
        let response = ui.add_enabled(!is_running, egui::TextEdit::singleline(&mut domain_text).desired_width(150.0));
        if response.changed() {
          self.active_cfg.proxy_domain = domain_text;
        }
      });

      ui.separator();
      ui.add_space(10.0);

      // Enable TLS
      ui.horizontal(|ui| {
        ui.add_enabled(!is_running, egui::Checkbox::new(&mut self.active_cfg.tls, "Enable TLS"));
      });

      ui.separator();
      ui.add_space(10.0);

      // Backup path
      {
        ui.label("Backup Path:");
        ui.horizontal(|ui| {
          // Display the current path
          ui.add_enabled(
            !is_running,
            egui::TextEdit::singleline(&mut self.active_cfg.backups_path).desired_width(150.0),
          );

          // Browse button
          if ui.add_enabled(!is_running, egui::Button::new("Browse...")).clicked()
            && let Some(picked_path) = rfd::FileDialog::new().pick_folder()
          {
            self.active_cfg.backups_path = picked_path.to_str().unwrap_or_default().to_string();
          }
        });
      }

      ui.add_space(10.0);

      // Certificate path
      {
        ui.label("Certificate Path:");
        ui.horizontal(|ui| {
          // Display the current path
          ui.add_enabled(!is_running, egui::TextEdit::singleline(&mut self.active_cfg.cert_path).desired_width(150.0));

          // Browse button
          if ui.add_enabled(!is_running, egui::Button::new("Browse...")).clicked()
            && let Some(picked_path) = rfd::FileDialog::new().pick_file()
          {
            self.active_cfg.cert_path = picked_path.to_str().unwrap_or_default().to_string();
          }
        });
      }

      ui.add_space(10.0);

      // Key path
      {
        ui.label("Key Path:");
        ui.horizontal(|ui| {
          // Display the current path
          ui.add_enabled(!is_running, egui::TextEdit::singleline(&mut self.active_cfg.key_path).desired_width(150.0));

          // Browse button
          if ui.add_enabled(!is_running, egui::Button::new("Browse...")).clicked()
            && let Some(picked_path) = rfd::FileDialog::new().pick_file()
          {
            self.active_cfg.key_path = picked_path.to_str().unwrap_or_default().to_string();
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
      ui.vertical_centered(|ui| {
        ui.add_space(10.0);

        // Get or create cached QR code texture
        if let Some(texture) = self.get_or_create_qr_texture(ctx, &server_url) {
          ui.image((texture.id(), egui::Vec2::new(150.0, 150.0)));
        } else {
          // Fallback if QR generation fails
          ui.label(RichText::new("QR Code Error").color(Color32::RED));
          log::warn!("QR code texture unavailable for URL: {}", server_url);
        }

        ui.add_space(10.0);
        ui.hyperlink(server_url);
        ui.add_space(10.0);
        ui.label(self.status_text.clone());
        ui.add_space(10.0);

        // Start/Stop server button
        let is_transitioning = self.is_server_transitioning();
        let is_in_cooldown = self.is_in_cooldown();
        let is_disabled = is_transitioning || is_in_cooldown;

        let button_text = if is_transitioning {
          "Please wait...".to_string()
        } else if is_in_cooldown {
          let remaining_ms = self.remaining_cooldown_ms().min(10000); // Cap at 10 seconds for display
          let remaining_secs = (f64::from(remaining_ms as u32) / 1000.0).ceil();
          format!("Wait {:.0}s...", remaining_secs)
        } else if is_running {
          "Stop Server".to_string()
        } else {
          "Start Server".to_string()
        };

        if ui.add_enabled(!is_disabled, egui::Button::new(button_text)).clicked() {
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
    // ServerManager will automatically shutdown when dropped
    log::info!("GUI window closing, ServerManager will handle cleanup");
  }
}
