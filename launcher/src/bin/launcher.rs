use std::env;

use launcher::logging;

// tokio main
#[tokio::main]
async fn main() {
  // initialize log env
  #[cfg(debug_assertions)]
  env::set_var("RUST_LOG", "debug");
  #[cfg(not(debug_assertions))]
  env::set_var("RUST_LOG", "info");

  // initialize logger
  logging::init_logger().expect("Failed to initialize logger");

  let args = server::TmsConfig::parse_from_cli();
}
