// On Windows a release build is a window program: double-clicking `tms.exe` opens no console.
#![cfg_attr(all(windows, not(debug_assertions)), windows_subsystem = "windows")]

use clap::Parser;

fn main() -> anyhow::Result<()> {
  #[cfg(windows)]
  attach_console();
  tms_launcher::run(tms_launcher::Cli::parse())
}

/// `tms --headless` typed in a terminal should print there, even though a release build has no console of its
/// own. Started from Explorer there is no parent console, and this does nothing.
#[cfg(windows)]
fn attach_console() {
  use windows_sys::Win32::System::Console::{ATTACH_PARENT_PROCESS, AttachConsole};
  // SAFETY: AttachConsole takes a process id and has no other preconditions; failure is harmless here.
  #[allow(unsafe_code)]
  unsafe {
    AttachConsole(ATTACH_PARENT_PROCESS);
  }
}
