use std::{net::IpAddr, str::FromStr, sync::Arc};

use anyhow::Result;
use egui::IconData;
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
  bind_address: String,
  port: String,
  api_playground: bool,
  tls: bool,
  db_path: String,
  cert_path: String,
  key_path: String,
}

impl From<ConfigFields> for TmsConfig {
  fn from(fields: ConfigFields) -> Self {
    TmsConfig {
      no_gui: false,
      addr: IpAddr::from_str(&fields.bind_address).unwrap(),
      port: fields.port.parse().unwrap(),
      api_playground: fields.api_playground,
      tls: fields.tls,
      db_path: fields.db_path,
      cert_path: fields.cert_path,
      key_path: fields.key_path,
    }
  }
}

impl From<TmsConfig> for ConfigFields {
  fn from(config: TmsConfig) -> Self {
    ConfigFields {
      port: config.port.to_string(),
      bind_address: config.addr.to_string(),
      api_playground: config.api_playground,
      tls: config.tls,
      db_path: config.db_path.clone(),
      cert_path: config.cert_path.clone(),
      key_path: config.key_path.clone(),
    }
  }
}

fn load_icon_data() -> IconData {
  let image_data = include_bytes!("../../assets/T_LOGO_WHITE.png");
  let image = image::load_from_memory(image_data)
    .expect("Failed to load icon image")
    .to_rgba8();

  let rgba = image.clone().into_raw();
  let (width, height) = image.dimensions();
  IconData { rgba, width, height }
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
      .with_max_inner_size(size)
      .with_icon(load_icon_data()),
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
