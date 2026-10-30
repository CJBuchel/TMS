//! `tms`: the launcher window, and the server it supervises. Settings are flags (or `TMS_*` environment
//! variables, or `tms.toml` in the data folder); `tms --help` lists them.
//!
//! - `tms` opens the launcher window, which starts and stops the server for you.
//! - `tms --headless` (or `--no-gui`) runs the server in the terminal.

#[cfg(feature = "gui")]
pub mod gui;
pub mod join;
pub mod logging;
pub mod serve;
pub mod settings;
pub mod status;

use clap::Parser;
use settings::ServeArgs;

#[derive(Parser)]
#[command(name = "tms", version, about = "FIRST LEGO League tournament management server")]
pub struct Cli {
  /// Run the server in this terminal without the launcher window.
  #[arg(long, visible_alias = "no-gui")]
  pub headless: bool,
  /// Set by the launcher window: report status as JSON lines and take commands on stdin.
  #[arg(long, hide = true, requires = "headless")]
  pub supervised: bool,
  #[command(flatten)]
  pub serve: ServeArgs,
}

/// Runs whatever the command line asks for.
pub fn run(cli: Cli) -> anyhow::Result<()> {
  #[cfg(feature = "gui")]
  if !cli.headless {
    return gui::run(cli.serve);
  }
  let runtime = tokio::runtime::Builder::new_multi_thread().enable_all().build()?;
  let result = runtime.block_on(serve::run(cli.serve, cli.supervised));
  // A supervised server may still be waiting on stdin, which never returns on its own; don't wait for it.
  runtime.shutdown_background();
  result
}
