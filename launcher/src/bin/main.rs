#![forbid(unsafe_code)]
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use anyhow::{Ok, Result};
use launcher::{
  logging,
  runtime::{rt_gui::run_rt_gui, rt_headless::run_rt_headless},
};
use server::TmsConfig;

#[tokio::main]
async fn main() -> Result<()> {
  // Init logger
  logging::init_logging().expect("Failed to initialize logger");

  // Parse cli
  let config = TmsConfig::parse_from_cli();

  if config.no_gui {
    // Start headless server
    log::info!("Starting TMS (No GUI)");
    run_rt_headless(config).await?;
  } else {
    // Start GUI
    log::info!("Starting TMS");
    run_rt_gui(config).await?;
  }

  Ok(())
}
