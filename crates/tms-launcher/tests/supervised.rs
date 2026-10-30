//! The supervision protocol, against the real `tms` program: status lines out, commands in.

use std::io::{BufRead, BufReader, Write};
use std::net::TcpListener;
use std::path::PathBuf;
use std::process::{Child, ChildStdin, Command, Stdio};
use std::sync::mpsc;
use std::time::Duration;

fn scratch(name: &str) -> PathBuf {
  let dir = std::env::temp_dir().join(format!("tms-supervised-{name}-{}", std::process::id()));
  let _ = std::fs::remove_dir_all(&dir);
  dir
}

fn free_port() -> u16 {
  TcpListener::bind("127.0.0.1:0").unwrap().local_addr().unwrap().port()
}

struct Supervised {
  child: Child,
  stdin: Option<ChildStdin>,
  lines: mpsc::Receiver<serde_json::Value>,
}

impl Supervised {
  fn start(dir: &PathBuf, port: u16, extra: &[&str]) -> Self {
    let mut child = Command::new(env!("CARGO_BIN_EXE_tms"))
      .args(["--headless", "--supervised", "--bind", "127.0.0.1", "--no-qr"])
      .arg("--data-dir")
      .arg(dir)
      .arg("--port")
      .arg(port.to_string())
      .arg("--web-dir")
      .arg(dir.join("no-web"))
      .args(extra)
      .stdin(Stdio::piped())
      .stdout(Stdio::piped())
      .spawn()
      .unwrap();
    let stdout = child.stdout.take().unwrap();
    let (tx, lines) = mpsc::channel();
    std::thread::spawn(move || {
      for line in BufReader::new(stdout).lines().map_while(Result::ok) {
        let value: serde_json::Value =
          serde_json::from_str(&line).unwrap_or_else(|e| panic!("stdout must be JSON lines only ({e}): {line}"));
        if tx.send(value).is_err() {
          return;
        }
      }
    });
    Self {
      stdin: child.stdin.take(),
      child,
      lines,
    }
  }

  /// The next status, failing after 60 s.
  fn next(&self) -> serde_json::Value {
    self.lines.recv_timeout(Duration::from_secs(60)).expect("a status line")
  }

  fn expect(&self, status: &str) -> serde_json::Value {
    let line = self.next();
    assert_eq!(line["status"], status, "{line}");
    line
  }

  fn send(&mut self, command: &str) {
    let stdin = self.stdin.as_mut().unwrap();
    writeln!(stdin, "{command}").unwrap();
    stdin.flush().unwrap();
  }

  fn wait(&mut self) -> i32 {
    for _ in 0..300 {
      if let Some(status) = self.child.try_wait().unwrap() {
        return status.code().unwrap_or(-1);
      }
      std::thread::sleep(Duration::from_millis(100));
    }
    self.child.kill().unwrap();
    panic!("tms did not exit within 30 s");
  }
}

#[test]
fn reports_each_step_backs_up_on_request_and_stops_on_command() {
  let dir = scratch("protocol");
  let mut tms = Supervised::start(&dir, free_port(), &["--backup-interval", "0"]);
  tms.expect("starting_database");
  tms.expect("migrating");
  let password = tms.expect("admin_password");
  assert_eq!(
    password["password"], "admin",
    "a first start with no password gives admin the password admin"
  );
  let listening = tms.expect("listening");
  assert!(listening["urls"][0].as_str().unwrap().starts_with("http://127.0.0.1:"));

  tms.send("backup");
  let created = tms.expect("backup_created");
  let file = PathBuf::from(created["file"].as_str().unwrap());
  assert!(file.starts_with(dir.join("backups")) && file.exists(), "{created}");

  tms.send("stop");
  tms.expect("stopping");
  tms.expect("stopped");
  assert_eq!(tms.wait(), 0);
  let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn stops_when_the_launcher_goes_away() {
  let dir = scratch("orphan");
  let mut tms = Supervised::start(&dir, free_port(), &[]);
  while tms.next()["status"] != "listening" {}
  drop(tms.stdin.take());
  tms.expect("stopping");
  tms.expect("stopped");
  assert_eq!(tms.wait(), 0);
  let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn a_fatal_error_is_reported_with_a_message() {
  let dir = scratch("fatal");
  let busy = TcpListener::bind("127.0.0.1:0").unwrap();
  let mut tms = Supervised::start(&dir, busy.local_addr().unwrap().port(), &[]);
  let fatal = loop {
    let line = tms.next();
    if line["status"] == "fatal" {
      break line;
    }
  };
  assert!(fatal["message"].as_str().unwrap().contains("in use"), "{fatal}");
  assert_ne!(tms.wait(), 0);
  let _ = std::fs::remove_dir_all(&dir);
}
