use std::net::IpAddr;

use anyhow::Result;

pub struct TmsWeb {
  addr: IpAddr,
  port: u16,
  enable_playground: bool,
}

impl TmsWeb {
  pub fn new(addr: IpAddr, port: u16, enable_playground: bool) -> Self {
    TmsWeb {
      addr,
      port,
      enable_playground,
    }
  }

  pub async fn run(&self) -> Result<()> {
    log::info!("Web Server Starting on {}:{}", self.addr, self.port);

    if self.enable_playground {
      log::warn!("GraphQL Playground Enabled, this should only be used for development/debugging!");
    }

    // wait 5 seconds
    tokio::time::sleep(tokio::time::Duration::from_secs(5)).await;

    Ok(())
  }
}
