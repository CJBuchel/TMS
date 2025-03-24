use anyhow::Result;

///
/// Services are background tasks that may run on separate threads, unrelated to the main web server.
/// I.e, the backup service, or a service that listens to a message queue.
///
pub struct Services;

impl Services {
  pub fn new() -> Self {
    Services
  }

  pub async fn start(&self) -> Result<()> {
    log::info!("Starting services");
    Ok(())
  }
}
