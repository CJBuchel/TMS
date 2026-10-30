//! Runs the server as a child process (`tms --headless --supervised`) and follows its status lines, its exit,
//! and its health. Commands go to its stdin; if the launcher dies, the closed stdin stops the server.

use std::io::{BufRead, BufReader, Read, Write};
use std::net::{SocketAddr, TcpStream};
use std::path::PathBuf;
use std::process::{Child, ChildStdin, Command as Process, Stdio};
use std::sync::mpsc::{self, Receiver, Sender};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

use crate::status::{Command, Status};

const STOP_GRACE: Duration = Duration::from_secs(10);
const HEALTH_EVERY: Duration = Duration::from_secs(5);

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ServerState {
  Stopped,
  /// The step it is on: starting the database, migrating.
  Starting(String),
  Running {
    since: Instant,
    urls: Vec<String>,
  },
  NotResponding {
    urls: Vec<String>,
  },
  Stopping,
  /// Exited by itself with this code, after a clean stop.
  Exited(i32),
  /// Exited with an error: the message from its last status, the exit code.
  Crashed {
    message: String,
    code: Option<i32>,
  },
}

impl ServerState {
  pub fn is_up(&self) -> bool {
    matches!(
      self,
      ServerState::Starting(_)
        | ServerState::Running { .. }
        | ServerState::NotResponding { .. }
        | ServerState::Stopping
    )
  }

  pub fn urls(&self) -> &[String] {
    match self {
      ServerState::Running { urls, .. } | ServerState::NotResponding { urls } => urls,
      _ => &[],
    }
  }
}

/// Something worth telling the person, beyond the state itself.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Notice {
  AdminPassword(String),
  BackupCreated(String),
  BackupFailed(String),
  Crashed { message: String, code: Option<i32> },
}

enum Event {
  Status(Status),
  Exited(Option<i32>),
  Health(bool),
}

pub struct Supervisor {
  child: Option<Arc<Mutex<Child>>>,
  stdin: Option<ChildStdin>,
  events: Receiver<Event>,
  sender: Sender<Event>,
  state: ServerState,
  last_fatal: Option<String>,
  stop_requested_at: Option<Instant>,
  health: Option<SocketAddr>,
  /// The last lines the server wrote to stderr (panics end up there), for the crash report.
  stderr: Arc<Mutex<Vec<String>>>,
  wake: Arc<dyn Fn() + Send + Sync>,
}

impl Supervisor {
  /// `wake` is called from background threads whenever there is news, to repaint the window.
  pub fn new(wake: Arc<dyn Fn() + Send + Sync>) -> Self {
    let (sender, events) = mpsc::channel();
    Self {
      child: None,
      stdin: None,
      events,
      sender,
      state: ServerState::Stopped,
      last_fatal: None,
      stop_requested_at: None,
      health: None,
      stderr: Arc::default(),
      wake,
    }
  }

  pub fn state(&self) -> &ServerState {
    &self.state
  }

  pub fn stderr_tail(&self) -> Vec<String> {
    self.stderr.lock().map(|lines| lines.clone()).unwrap_or_default()
  }

  /// Starts `program --headless --supervised <args>`. `health` is where its HTTP port answers.
  pub fn start(
    &mut self,
    program: PathBuf,
    args: &[String],
    env: Vec<(String, String)>,
    health: SocketAddr,
  ) -> anyhow::Result<()> {
    if self.state.is_up() {
      return Ok(());
    }
    let mut command = Process::new(program);
    command
      .arg("--headless")
      .arg("--supervised")
      .args(args)
      .envs(env)
      .stdin(Stdio::piped())
      .stdout(Stdio::piped())
      .stderr(Stdio::piped());
    #[cfg(windows)]
    {
      use std::os::windows::process::CommandExt;
      const CREATE_NO_WINDOW: u32 = 0x0800_0000;
      command.creation_flags(CREATE_NO_WINDOW);
    }
    let mut child = command.spawn()?;
    let stdout = child.stdout.take().expect("piped stdout");
    let stderr = child.stderr.take().expect("piped stderr");
    self.stdin = child.stdin.take();
    let child = Arc::new(Mutex::new(child));
    self.child = Some(Arc::clone(&child));
    self.state = ServerState::Starting("Starting".into());
    self.last_fatal = None;
    self.stop_requested_at = None;
    self.health = Some(health);
    if let Ok(mut lines) = self.stderr.lock() {
      lines.clear();
    }

    let (sender, wake) = (self.sender.clone(), Arc::clone(&self.wake));
    std::thread::spawn(move || {
      for line in BufReader::new(stdout).lines().map_while(Result::ok) {
        let Ok(status) = serde_json::from_str::<Status>(&line) else {
          continue;
        };
        if sender.send(Event::Status(status)).is_err() {
          return;
        }
        wake();
      }
    });
    // Panics land on stderr. Keep the last lines, and keep reading so the child never blocks on a full pipe.
    let kept = Arc::clone(&self.stderr);
    std::thread::spawn(move || {
      for line in BufReader::new(stderr).lines().map_while(Result::ok) {
        if let Ok(mut lines) = kept.lock() {
          lines.push(line);
          let excess = lines.len().saturating_sub(20);
          lines.drain(..excess);
        }
      }
    });
    let (sender, wake) = (self.sender.clone(), Arc::clone(&self.wake));
    std::thread::spawn(move || {
      loop {
        let exited = child.lock().map(|mut c| c.try_wait()).ok().and_then(Result::ok);
        if let Some(Some(status)) = exited {
          let _ = sender.send(Event::Exited(status.code()));
          wake();
          return;
        }
        std::thread::sleep(Duration::from_millis(200));
      }
    });
    let (sender, wake) = (self.sender.clone(), Arc::clone(&self.wake));
    std::thread::spawn(move || {
      loop {
        std::thread::sleep(HEALTH_EVERY);
        if sender.send(Event::Health(healthy(health))).is_err() {
          return;
        }
        wake();
      }
    });
    Ok(())
  }

  /// Asks the server to stop. It is killed if it hasn't exited after 10 seconds.
  pub fn stop(&mut self) {
    if !self.state.is_up() {
      return;
    }
    self.send(Command::Stop);
    self.stdin = None;
    self.state = ServerState::Stopping;
    self.stop_requested_at = Some(Instant::now());
  }

  /// Asks the running server for a backup now.
  pub fn backup(&mut self) {
    self.send(Command::Backup);
  }

  fn send(&mut self, command: Command) {
    if let Some(stdin) = self.stdin.as_mut() {
      let _ = writeln!(stdin, "{}", command.line());
      let _ = stdin.flush();
    }
  }

  /// Applies what the background threads reported. Call once per frame.
  pub fn poll(&mut self) -> Vec<Notice> {
    let mut notices = Vec::new();
    while let Ok(event) = self.events.try_recv() {
      match event {
        Event::Status(status) => self.on_status(status, &mut notices),
        Event::Exited(code) => {
          self.child = None;
          self.stdin = None;
          self.health = None;
          self.state = match (self.last_fatal.take(), code) {
            (Some(message), code) => {
              notices.push(Notice::Crashed {
                message: message.clone(),
                code,
              });
              ServerState::Crashed { message, code }
            }
            (None, Some(0)) => ServerState::Exited(0),
            (None, code) if self.stop_requested_at.is_some() => ServerState::Exited(code.unwrap_or(-1)),
            (None, code) => {
              let message = "The server stopped unexpectedly.".to_owned();
              notices.push(Notice::Crashed {
                message: message.clone(),
                code,
              });
              ServerState::Crashed { message, code }
            }
          };
        }
        Event::Health(ok) => {
          let urls = self.state.urls().to_vec();
          match (&self.state, ok) {
            (ServerState::Running { .. }, false) => self.state = ServerState::NotResponding { urls },
            (ServerState::NotResponding { .. }, true) => {
              self.state = ServerState::Running {
                since: Instant::now(),
                urls,
              };
            }
            _ => {}
          }
        }
      }
    }
    if let (Some(at), Some(child)) = (self.stop_requested_at, &self.child)
      && at.elapsed() > STOP_GRACE
      && let Ok(mut child) = child.lock()
    {
      let _ = child.kill();
    }
    notices
  }

  fn on_status(&mut self, status: Status, notices: &mut Vec<Notice>) {
    match status {
      Status::StartingDatabase => self.state = ServerState::Starting("Starting the database".into()),
      Status::Migrating => self.state = ServerState::Starting("Updating the database".into()),
      Status::AdminPassword { password } => notices.push(Notice::AdminPassword(password)),
      Status::Listening { urls } => {
        self.state = ServerState::Running {
          since: Instant::now(),
          urls,
        };
      }
      Status::BackupCreated { file } => notices.push(Notice::BackupCreated(file)),
      Status::BackupFailed { message } => notices.push(Notice::BackupFailed(message)),
      Status::Stopping => self.state = ServerState::Stopping,
      Status::Stopped => {}
      Status::Fatal { message } => self.last_fatal = Some(message),
    }
  }
}

impl Drop for Supervisor {
  /// Closing the window stops the server: closing stdin is the stop signal.
  fn drop(&mut self) {
    self.stop();
  }
}

/// `GET /healthz` with short timeouts. Plain HTTP; with HTTPS on, the HTTP port only redirects, which still
/// proves the server answers.
fn healthy(address: SocketAddr) -> bool {
  let Ok(mut stream) = TcpStream::connect_timeout(&address, Duration::from_secs(2)) else {
    return false;
  };
  let _ = stream.set_read_timeout(Some(Duration::from_secs(3)));
  if stream
    .write_all(b"GET /healthz HTTP/1.0\r\nHost: 127.0.0.1\r\n\r\n")
    .is_err()
  {
    return false;
  }
  let mut head = [0u8; 12];
  if stream.read_exact(&mut head).is_err() {
    return false;
  }
  // "HTTP/1.x 2.." or "HTTP/1.x 3..".
  head.starts_with(b"HTTP/1.") && matches!(head[9], b'2' | b'3')
}
