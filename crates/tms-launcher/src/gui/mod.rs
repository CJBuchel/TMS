//! The launcher window: start and stop the server, show how to connect, manage backups, read the logs.

mod app;
mod form;
mod jobs;
mod logs;
mod qr;
mod supervisor;

pub use app::LauncherApp;

use eframe::egui;

use crate::settings::ServeArgs;

pub fn run(args: ServeArgs) -> anyhow::Result<()> {
  let program = std::env::current_exe()?;
  let options = eframe::NativeOptions {
    viewport: egui::ViewportBuilder::default()
      .with_title("TMS")
      .with_inner_size([600.0, 720.0])
      .with_min_inner_size([480.0, 520.0]),
    ..Default::default()
  };
  eframe::run_native(
    "TMS",
    options,
    Box::new(move |cc| Ok(Box::new(LauncherApp::new(&cc.egui_ctx, program, args)?))),
  )
  .map_err(|e| anyhow::anyhow!("opening the launcher window: {e}"))
}
