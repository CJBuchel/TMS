use anyhow::Result;

use crate::{
  core::web::TmsWeb,
  features::{Team, TeamRepository},
  TmsConfig,
};

use super::db::initialize_db;

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
    // Initialize the database
    initialize_db(&self.config.db_path).await?;

    // @TODO: Start backup service

    // Start web on main thread
    let web = TmsWeb::new(self.config.addr, self.config.port, self.config.api_playground);
    web.run().await
  }
}
