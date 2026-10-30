//! The supervision protocol between the launcher window and `tms --headless --supervised`.
//!
//! The server writes one JSON status line to stdout per step; its logs go to the log file only. The launcher
//! writes commands to the server's stdin, one per line: `stop` or `backup`. A closed stdin means the launcher has
//! gone, and the server stops, so it never runs unowned.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "status", rename_all = "snake_case")]
pub enum Status {
  StartingDatabase,
  Migrating,
  /// First start only, when no password was given: the `admin` user's starting password.
  AdminPassword {
    password: String,
  },
  Listening {
    urls: Vec<String>,
  },
  BackupCreated {
    file: String,
  },
  BackupFailed {
    message: String,
  },
  Stopping,
  Stopped,
  Fatal {
    message: String,
  },
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Command {
  Stop,
  Backup,
}

impl Command {
  pub fn line(self) -> &'static str {
    match self {
      Command::Stop => "stop",
      Command::Backup => "backup",
    }
  }

  pub fn parse(line: &str) -> Option<Self> {
    match line.trim() {
      "stop" => Some(Command::Stop),
      "backup" => Some(Command::Backup),
      _ => None,
    }
  }
}

/// Where status goes: JSON lines for the launcher, or nothing extra for a person at a terminal (who reads the
/// printed join URLs and the log).
#[derive(Debug, Clone, Copy)]
pub struct Reporter {
  pub supervised: bool,
}

impl Reporter {
  pub fn send(self, status: &Status) {
    if self.supervised {
      use std::io::Write;
      let line = serde_json::to_string(status).expect("statuses always serialise");
      // A launcher that has gone away closes the pipe; the server still has to shut down cleanly.
      let _ = writeln!(std::io::stdout().lock(), "{line}");
    }
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn wire_format() {
    let s = Status::Listening {
      urls: vec!["http://10.0.0.5:8080".into()],
    };
    assert_eq!(
      serde_json::to_string(&s).unwrap(),
      r#"{"status":"listening","urls":["http://10.0.0.5:8080"]}"#
    );
    assert_eq!(
      serde_json::from_str::<Status>(r#"{"status":"starting_database"}"#).unwrap(),
      Status::StartingDatabase
    );
    assert_eq!(Command::parse(" stop\n"), Some(Command::Stop));
    assert_eq!(Command::parse("dance"), None);
  }
}
