use std::{
  net::{IpAddr, Ipv4Addr},
  str::FromStr,
  sync::Arc,
};

use anyhow::Result;
use egui::IconData;
use parking_lot::Mutex;
use runner::GuiRunner;
use server::TmsConfig;
use tokio::sync::mpsc::Sender;

use crate::{GuiMessage, ServerState};
mod app;
mod qr_code;
mod runner;

#[derive(Debug, Clone)]
struct ConfigFields {
  bind_address: String,
  web_port: String,
  api_port: String,
  db_path: String,
  backups_path: String,
  tls: bool,
  cert_path: String,
  key_path: String,
  admin_password: String,
  proxy_token: String,
  proxy_domain: String,
}

impl From<ConfigFields> for TmsConfig {
  fn from(fields: ConfigFields) -> Self {
    TmsConfig {
      no_gui: false,
      addr: IpAddr::from_str(&fields.bind_address).unwrap_or(IpAddr::V4(Ipv4Addr::UNSPECIFIED)),
      web_port: fields.web_port.parse().unwrap_or_default(),
      api_port: fields.api_port.parse().unwrap_or_default(),
      db_path: fields.db_path,
      backups_path: fields.backups_path,
      tls: fields.tls,
      cert_path: fields.cert_path,
      key_path: fields.key_path,
      admin_password: fields.admin_password,
      proxy_token: if fields.proxy_token.is_empty() {
        None
      } else {
        Some(fields.proxy_token)
      },
      proxy_domain: if fields.proxy_domain.is_empty() {
        None
      } else {
        Some(fields.proxy_domain)
      },
    }
  }
}

impl From<TmsConfig> for ConfigFields {
  fn from(config: TmsConfig) -> Self {
    ConfigFields {
      bind_address: config.addr.to_string(),
      web_port: config.web_port.to_string(),
      api_port: config.api_port.to_string(),
      db_path: config.db_path.clone(),
      backups_path: config.backups_path.clone(),
      tls: config.tls,
      cert_path: config.cert_path.clone(),
      key_path: config.key_path.clone(),
      admin_password: config.admin_password.clone(),
      proxy_token: config.proxy_token.unwrap_or_default(),
      proxy_domain: config.proxy_domain.unwrap_or_default(),
    }
  }
}

fn load_icon_data() -> IconData {
  // Use eframe's built-in PNG loader for better compatibility
  eframe::icon_data::from_png_bytes(include_bytes!("../../assets/TMS_Logo.png")).expect("Failed to load icon")
}

pub fn run_gui(
  message_sender: Sender<GuiMessage>,
  server_state: Arc<Mutex<ServerState>>,
  config: TmsConfig,
) -> Result<()> {
  let size = [680.0, 440.0];
  let options = eframe::NativeOptions {
    viewport: egui::ViewportBuilder::default()
      .with_inner_size(size)
      .with_min_inner_size(size)
      .with_icon(std::sync::Arc::new(load_icon_data())),
    ..Default::default()
  };

  let res = eframe::run_native(
    "TMS Launcher",
    options,
    Box::new(|cc| {
      egui_extras::install_image_loaders(&cc.egui_ctx);
      Ok(Box::<GuiRunner>::new(GuiRunner::new(
        message_sender,
        server_state,
        config,
        cc,
      )))
    }),
  );

  match res {
    Ok(()) => Ok(()),
    Err(e) => Err(anyhow::Error::msg(e.to_string())),
  }
}
