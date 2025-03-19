use std::{net::IpAddr, process::Child, str::FromStr};

use eframe::Result;
use egui::{epaint, Color32, ColorImage, CornerRadius, RichText, TextureHandle, Visuals};
use launcher::{qr_code, server_process::ServerProcess};
use local_ip_address::local_ip;
use qrcodegen::{QrCode, QrCodeEcc, QrSegment};
use tokio::runtime::Runtime;

enum ServerStatus {
  Ok(RichText),
  Error(RichText),
}

struct LauncherApp {
  port: String,
  bind_address: String,
  server: ServerProcess,
  status_message: ServerStatus,
}

impl LauncherApp {
  fn new(cc: &eframe::CreationContext<'_>) -> Self {
    let mut visuals = Visuals::dark();
    visuals.panel_fill = Color32::from_hex("#2A2D3E").unwrap_or_default();
    visuals.window_fill = Color32::from_hex("#2A2D3E").unwrap_or_default();
    visuals.extreme_bg_color = Color32::from_hex("#20222f").unwrap_or_default();
    cc.egui_ctx.set_visuals(visuals);

    Self {
      port: "8080".to_string(),
      bind_address: "0.0.0.0".parse().unwrap(),
      server: ServerProcess { child: None },
      status_message: ServerStatus::Ok(RichText::new("Server not running")),
    }
  }
}

impl eframe::App for LauncherApp {
  fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
    let local_ip = local_ip().unwrap_or(IpAddr::V4(std::net::Ipv4Addr::new(127, 0, 0, 1)));

    // server url
    let server_url = format!("http://{}:{}", local_ip, self.port);

    // Teal header panel
    let teal_color = Color32::from_hex("#009485").unwrap_or_default();

    // check on server status
    match self.status_message {
      ServerStatus::Ok(_) => {
        if self.server.is_running() {
          self.status_message = ServerStatus::Ok(RichText::new("Server running").color(Color32::GREEN));
        } else {
          self.status_message = ServerStatus::Ok(RichText::new("Server not running"));
        }
      }
      _ => {}
    };

    let status_text = match &self.status_message {
      ServerStatus::Ok(text) => text.clone(),
      ServerStatus::Error(text) => text.clone(),
    };

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

    egui::CentralPanel::default().show(ctx, |ui| {
      // Configuration section
      ui.heading("Configuration");
      ui.add_space(10.0);

      // Server binding
      ui.horizontal(|ui| {
        ui.label("Binding:");
        ui.add(egui::TextEdit::singleline(&mut self.bind_address).desired_width(150.0));
        if IpAddr::from_str(&self.bind_address).is_err() {
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
        ui.label(status_text);
        ui.add_space(10.0);

        // Start/Stop server button
        let button_text = if self.server.is_running() {
          "Stop Server"
        } else {
          "Start Server"
        };
        if ui.button(button_text).clicked() {
          if self.server.is_running() {
            self.server.stop().unwrap();
          } else {
            let port = self.port.parse::<u16>().unwrap();
            let bind_address = self.bind_address.parse().unwrap();

            match self.server.start(port, bind_address) {
              Ok(_) => {
                self.status_message = ServerStatus::Ok(RichText::new("Server running").color(Color32::GREEN));
              }
              Err(e) => {
                self.status_message = ServerStatus::Error(RichText::new(e).color(Color32::RED));
              }
            }
          }
        }
      });
    });
  }
}

// fn main() -> Result<(), eframe::Error> {
//   let size = [640.0, 380.0];
//   let options = eframe::NativeOptions {
//     viewport: egui::ViewportBuilder::default()
//       .with_inner_size(size)
//       .with_min_inner_size(size)
//       .with_max_inner_size(size),
//     ..Default::default()
//   };

//   eframe::run_native(
//     "TMS Launcher",
//     options,
//     Box::new(|cc| {
//       egui_extras::install_image_loaders(&cc.egui_ctx);
//       Ok(Box::<LauncherApp>::new(LauncherApp::new(cc)))
//     }),
//   )
// }
