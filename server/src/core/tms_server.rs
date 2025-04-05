use anyhow::Result;

use crate::{core::web::TmsWeb, services::Services, TmsConfig};

use super::{auth::initialize_jwt_secret, db::initialize_db};

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

    // Initialize the JWT token
    initialize_jwt_secret().await?;

    // Initialize the services
    let services = Services::new();
    services.start().await?;

    // Start web on main thread
    let web = TmsWeb::new(self.config.addr, self.config.port, self.config.api_playground);
    web.run().await
  }
}
