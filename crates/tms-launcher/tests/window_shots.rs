//! Pictures of the launcher window for a person to look at, not an assertion. Rendered without a screen (a
//! software Vulkan driver is enough). Run with:
//!
//! ```text
//! TMS_SHOTS=/some/folder cargo test -p tms-launcher --test window_shots -- --ignored
//! ```

#![cfg(feature = "gui")]

use std::net::TcpListener;
use std::path::PathBuf;
use std::time::{Duration, Instant};

use egui_kittest::Harness;
use egui_kittest::kittest::Queryable;
use tms_launcher::gui::LauncherApp;
use tms_launcher::settings::ServeArgs;

#[test]
#[ignore = "writes screenshots; run on demand"]
fn screenshots_of_every_tab() {
  let out = PathBuf::from(std::env::var("TMS_SHOTS").unwrap_or_else(|_| "launcher-shots".into()));
  std::fs::create_dir_all(&out).unwrap();
  let dir = std::env::temp_dir().join(format!("tms-shots-{}", std::process::id()));
  let _ = std::fs::remove_dir_all(&dir);
  let args = ServeArgs {
    data_dir: Some(dir.clone()),
    web_dir: Some(dir.join("no-web")),
    port: Some(TcpListener::bind("127.0.0.1:0").unwrap().local_addr().unwrap().port()),
    backup_interval: Some(0),
    ..ServeArgs::default()
  };
  let ctx = eframe::egui::Context::default();
  let app = LauncherApp::new(&ctx, PathBuf::from(env!("CARGO_BIN_EXE_tms")), args).unwrap();
  let mut harness = Harness::builder()
    .with_size([600.0, 720.0])
    .wgpu()
    .build_ui_state(|ui, app: &mut LauncherApp| app.draw(ui), app);
  let shot = |harness: &mut Harness<'_, LauncherApp>, name: &str| {
    harness.step();
    harness.render().unwrap().save(out.join(format!("{name}.png"))).unwrap();
  };
  shot(&mut harness, "01-stopped");
  harness.get_by_label("Start").click_accesskit();
  let deadline = Instant::now() + Duration::from_secs(90);
  while harness.query_all_by_label_contains("Running for").next().is_none() {
    assert!(Instant::now() < deadline);
    harness.step();
    std::thread::sleep(Duration::from_millis(100));
  }
  shot(&mut harness, "02-connect");
  for (i, tab) in ["Server", "Database", "Backups", "Logs"].into_iter().enumerate() {
    harness.get_by_label(tab).click_accesskit();
    harness.step();
    if tab == "Backups" {
      harness.get_by_label("Create now").click_accesskit();
      for _ in 0..30 {
        harness.step();
        std::thread::sleep(Duration::from_millis(100));
      }
    }
    shot(&mut harness, &format!("{:02}-{}", i + 3, tab.to_lowercase()));
  }
  harness.get_by_label("Stop").click_accesskit();
  while harness.query_all_by_label("Stopped").next().is_none() {
    harness.step();
    std::thread::sleep(Duration::from_millis(100));
  }
  drop(harness);
  let _ = std::fs::remove_dir_all(&dir);
}
