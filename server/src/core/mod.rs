use anyhow::{Ok, Result};

use crate::TmsConfig;

pub struct TmsServer {
  _config: TmsConfig,
}

impl TmsServer {
  pub fn new(config: Option<TmsConfig>) -> Self {
    let config = match config {
      Some(config) => config,
      None => TmsConfig::parse_from_cli(),
    };
    TmsServer { _config: config }
  }

  pub async fn run(&self) -> Result<()> {
    log::info!("Server Startup");

    // wait 5 seconds
    tokio::time::sleep(tokio::time::Duration::from_secs(5)).await;

    Ok(())
  }
}
