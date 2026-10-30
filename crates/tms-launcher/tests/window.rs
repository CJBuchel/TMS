//! The launcher window, driven like a person would (through its accessibility tree, no screen needed), against
//! the real `tms` program: start, back up, stop, restore, reset a password, start again.

#![cfg(feature = "gui")]

use std::net::TcpListener;
use std::path::PathBuf;
use std::time::{Duration, Instant};

use egui_kittest::Harness;
use egui_kittest::kittest::Queryable;
use tms_launcher::gui::LauncherApp;
use tms_launcher::settings::ServeArgs;

fn scratch() -> PathBuf {
  let dir = std::env::temp_dir().join(format!("tms-window-{}", std::process::id()));
  let _ = std::fs::remove_dir_all(&dir);
  dir
}

fn free_port() -> u16 {
  TcpListener::bind("127.0.0.1:0").unwrap().local_addr().unwrap().port()
}

/// Steps frames until `what` is on screen, failing after 90 s.
fn wait_for(harness: &mut Harness<'_, LauncherApp>, what: &str) {
  let deadline = Instant::now() + Duration::from_secs(90);
  loop {
    harness.step();
    if harness.query_all_by_label_contains(what).next().is_some() {
      return;
    }
    assert!(
      Instant::now() < deadline,
      "\"{what}\" never appeared; the server is {:?}; message {:?}",
      harness.state().state(),
      harness.state().message()
    );
    std::thread::sleep(Duration::from_millis(100));
  }
}

fn click(harness: &mut Harness<'_, LauncherApp>, label: &str) {
  harness.get_all_by_label(label).last().unwrap().click_accesskit();
  harness.step();
  harness.step();
}

#[test]
fn start_backup_stop_restore_and_recover_a_password() {
  let dir = scratch();
  let args = ServeArgs {
    data_dir: Some(dir.clone()),
    web_dir: Some(dir.join("no-web")),
    bind: Some("127.0.0.1".parse().unwrap()),
    port: Some(free_port()),
    backup_interval: Some(0),
    ..ServeArgs::default()
  };
  let ctx = eframe::egui::Context::default();
  let app = LauncherApp::new(&ctx, PathBuf::from(env!("CARGO_BIN_EXE_tms")), args).unwrap();
  let mut harness = Harness::builder()
    .with_size([600.0, 720.0])
    .build_ui_state(|ui, app: &mut LauncherApp| app.draw(ui), app);
  harness.step();
  harness.get_by_label("Stopped");
  assert!(
    harness.query_all_by_label_contains("--port").next().is_some(),
    "the footer shows the equivalent command"
  );

  click(&mut harness, "Start");
  wait_for(&mut harness, "Running for");
  wait_for(&mut harness, "with the password admin");
  harness.get_by_label("Copy address");
  assert!(dir.join("tms.toml").exists(), "settings saved for headless runs");

  click(&mut harness, "Backups");
  click(&mut harness, "Create now");
  wait_for(&mut harness, "Backup created");

  click(&mut harness, "Stop");
  wait_for(&mut harness, "Stopped");

  // Restore while stopped: the launcher opens the database itself.
  click(&mut harness, "Restore");
  wait_for(&mut harness, "Restore this backup?");
  click(&mut harness, "Restore");
  wait_for(&mut harness, "Restored the backup");

  click(&mut harness, "Maintenance");
  click(&mut harness, "Reset a user's password…");
  wait_for(&mut harness, "Set a user's password");
  click(&mut harness, "Set password");
  wait_for(&mut harness, "logs in with:");
  click(&mut harness, "Done");

  click(&mut harness, "Start");
  wait_for(&mut harness, "Running for");
  click(&mut harness, "Stop");
  wait_for(&mut harness, "Stopped");
  drop(harness);
  let _ = std::fs::remove_dir_all(&dir);
}
