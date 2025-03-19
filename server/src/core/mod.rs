use anyhow::{Ok, Result};

use crate::TmsConfig;

pub struct TmsServer {
  config: TmsConfig,
}

impl TmsServer {
  pub fn new(config: Option<TmsConfig>) -> Self {
    let config = match config {
      Some(config) => config,
      None => TmsConfig::parse_from_cli(),
    };
    TmsServer { config }
  }

  pub async fn run(&self) -> Result<()> {
    log::info!("Server Startup");

    Ok(())
  }
}
