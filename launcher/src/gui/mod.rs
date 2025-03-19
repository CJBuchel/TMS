use std::{net::IpAddr, str::FromStr, sync::Arc};

use anyhow::Result;
use launcher::Launcher;
use parking_lot::Mutex;
use server::TmsConfig;
use tokio::sync::mpsc::Sender;

use crate::{GuiMessage, ServerState};
mod app;
mod launcher;
mod qr_code;

#[derive(Debug, Clone)]
struct ConfigFields {
  port: String,
  bind_address: String,
}

impl From<ConfigFields> for TmsConfig {
  fn from(fields: ConfigFields) -> Self {
    TmsConfig {
      no_gui: false,
      addr: IpAddr::from_str(&fields.bind_address).unwrap(),
      web_port: fields.port.parse().unwrap(),
      db_path: "tms.db".to_string(),
      cert_path: "cert.pem".to_string(),
      key_path: "key.pem".to_string(),
    }
  }
}

impl From<TmsConfig> for ConfigFields {
  fn from(config: TmsConfig) -> Self {
    ConfigFields {
      port: config.web_port.to_string(),
      bind_address: config.addr.to_string(),
    }
  }
}

pub fn run_gui(
  message_sender: Sender<GuiMessage>,
  server_state: Arc<Mutex<ServerState>>,
  config: TmsConfig,
) -> Result<()> {
  let size = [640.0, 380.0];
  let options = eframe::NativeOptions {
    viewport: egui::ViewportBuilder::default()
      .with_inner_size(size)
      .with_min_inner_size(size)
      .with_max_inner_size(size),
    ..Default::default()
  };

  let res = eframe::run_native(
    "TMS Launcher",
    options,
    Box::new(|cc| {
      egui_extras::install_image_loaders(&cc.egui_ctx);
      Ok(Box::<Launcher>::new(Launcher::new(
        message_sender,
        server_state,
        config,
        cc,
      )))
    }),
  );

  match res {
    Ok(_) => Ok(()),
    Err(e) => Err(anyhow::Error::msg(e.to_string())),
  }
}
