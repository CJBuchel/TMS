use anyhow::Result;

use crate::{core::web::TmsWeb, TmsConfig};

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
    log::info!("Server Starting...");

    // Start web on main thread
    let web = TmsWeb::new(self.config.addr, self.config.web_port, self.config.enable_playground);
    web.run().await
  }
}
