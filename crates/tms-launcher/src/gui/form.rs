//! The Server and Database tab fields, and how they become the server's flags, the equivalent command line,
//! and `tms.toml`, so a later `tms --headless` in the same folder uses the same settings.

use std::fmt::Write as _;
use std::net::{IpAddr, Ipv4Addr, SocketAddr};
use std::path::{Path, PathBuf};

use crate::settings::{DEFAULT_PORT, DEFAULT_TLS_PORT, Settings};

pub const LOG_LEVELS: [&str; 5] = ["error", "warn", "info", "debug", "trace"];

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ServerForm {
  pub bind: String,
  pub port: String,
  pub https: bool,
  pub tls_cert: String,
  pub tls_key: String,
  pub tls_port: String,
  pub public_host: String,
  pub external_db: bool,
  pub database_url: String,
  pub db_port: String,
  pub log_level: String,
  pub backup_interval: String,
  pub backup_retain: String,
}

/// The form turned into values, checked.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Checked {
  /// Flags that differ from the defaults, in a stable order.
  pub flags: Vec<(String, String)>,
  pub health: SocketAddr,
}

fn path_text(path: Option<&PathBuf>) -> String {
  path.map(|p| p.display().to_string()).unwrap_or_default()
}

impl ServerForm {
  pub fn from_settings(s: &Settings) -> Self {
    Self {
      bind: s.bind.to_string(),
      port: s.port.to_string(),
      https: s.tls.is_some(),
      tls_cert: path_text(s.tls.as_ref().map(|t| &t.cert)),
      tls_key: path_text(s.tls.as_ref().map(|t| &t.key)),
      tls_port: s.tls.as_ref().map_or(DEFAULT_TLS_PORT, |t| t.port).to_string(),
      public_host: s.public_host.clone().unwrap_or_default(),
      external_db: s.database_url.is_some(),
      database_url: s.database_url.clone().unwrap_or_default(),
      db_port: s.db_port.map(|p| p.to_string()).unwrap_or_default(),
      log_level: s.log_level.clone(),
      backup_interval: s.backup_interval_minutes.to_string(),
      backup_retain: s.backup_retain.to_string(),
    }
  }

  /// Checks every field and lists the flags to pass. Errors are sentences for the person.
  pub fn check(&self) -> Result<Checked, String> {
    let mut flags = Vec::new();
    let bind: IpAddr = self
      .bind
      .trim()
      .parse()
      .map_err(|_| format!("\"{}\" is not an IP address to listen on.", self.bind.trim()))?;
    if bind != IpAddr::V4(Ipv4Addr::UNSPECIFIED) {
      flags.push(("--bind".into(), bind.to_string()));
    }
    let port = port_value(&self.port, "HTTP port")?;
    if port != DEFAULT_PORT {
      flags.push(("--port".into(), port.to_string()));
    }
    if self.https {
      if self.tls_cert.trim().is_empty() || self.tls_key.trim().is_empty() {
        return Err("HTTPS needs a certificate file and a key file.".into());
      }
      flags.push(("--tls-cert".into(), self.tls_cert.trim().into()));
      flags.push(("--tls-key".into(), self.tls_key.trim().into()));
      let tls_port = port_value(&self.tls_port, "HTTPS port")?;
      if tls_port != DEFAULT_TLS_PORT {
        flags.push(("--tls-port".into(), tls_port.to_string()));
      }
    }
    if !self.public_host.trim().is_empty() {
      flags.push(("--public-host".into(), self.public_host.trim().into()));
    }
    if self.external_db {
      let url = self.database_url.trim();
      if !(url.starts_with("postgres://") || url.starts_with("postgresql://")) {
        return Err("The database URL starts with postgres://".into());
      }
      flags.push(("--database-url".into(), url.into()));
    } else if !self.db_port.trim().is_empty() {
      flags.push((
        "--db-port".into(),
        port_value(&self.db_port, "Database port")?.to_string(),
      ));
    }
    if !LOG_LEVELS.contains(&self.log_level.as_str()) {
      return Err("Choose a log level.".into());
    }
    if self.log_level != "info" {
      flags.push(("--log-level".into(), self.log_level.clone()));
    }
    let interval: u32 = self
      .backup_interval
      .trim()
      .parse()
      .map_err(|_| "Backup interval is a number of minutes (0 for none).".to_owned())?;
    if interval != 10 {
      flags.push(("--backup-interval".into(), interval.to_string()));
    }
    let retain: usize = self
      .backup_retain
      .trim()
      .parse()
      .ok()
      .filter(|n| *n > 0)
      .ok_or("Keep at least one automatic backup.")?;
    if retain != 20 {
      flags.push(("--backup-retain".into(), retain.to_string()));
    }
    let health_host = if bind.is_unspecified() {
      IpAddr::V4(Ipv4Addr::LOCALHOST)
    } else {
      bind
    };
    Ok(Checked {
      flags,
      health: SocketAddr::new(health_host, port),
    })
  }

  /// `tms.toml` with the same settings, so `tms --headless` in this folder behaves the same.
  pub fn toml(&self) -> Result<String, String> {
    let checked = self.check()?;
    let mut text =
      String::from("# Written by the TMS launcher window. Every key is optional; `tms --help` lists them.\n");
    for (flag, value) in checked.flags {
      let key = flag.trim_start_matches("--");
      let numeric = value.parse::<u64>().is_ok() && key != "public-host";
      let value = if numeric { value } else { toml_string(&value) };
      let _ = writeln!(text, "{key} = {value}");
    }
    Ok(text)
  }

  pub fn save(&self, data_dir: &Path) -> Result<(), String> {
    let text = self.toml()?;
    std::fs::create_dir_all(data_dir).map_err(|e| e.to_string())?;
    std::fs::write(data_dir.join("tms.toml"), text).map_err(|e| format!("Saving tms.toml: {e}"))
  }
}

fn port_value(text: &str, what: &str) -> Result<u16, String> {
  text
    .trim()
    .parse::<u16>()
    .ok()
    .filter(|p| *p > 0)
    .ok_or_else(|| format!("{what} is a number from 1 to 65535."))
}

fn toml_string(value: &str) -> String {
  format!("\"{}\"", value.replace('\\', "\\\\").replace('"', "\\\""))
}

/// The same flags as a command a person can paste into a terminal.
pub fn command_line(flags: &[(String, String)], data_dir: Option<&Path>) -> String {
  let mut parts = vec!["tms".to_owned(), "--headless".to_owned()];
  if let Some(dir) = data_dir {
    parts.push("--data-dir".into());
    parts.push(shell_quote(&dir.display().to_string()));
  }
  for (flag, value) in flags {
    parts.push(flag.clone());
    parts.push(shell_quote(value));
  }
  parts.join(" ")
}

fn shell_quote(value: &str) -> String {
  if !value.is_empty()
    && value
      .chars()
      .all(|c| c.is_ascii_alphanumeric() || "-_./:@=+".contains(c))
  {
    value.to_owned()
  } else {
    format!("\"{}\"", value.replace('"', "\\\""))
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  fn defaults() -> ServerForm {
    ServerForm {
      bind: "0.0.0.0".into(),
      port: "8080".into(),
      https: false,
      tls_cert: String::new(),
      tls_key: String::new(),
      tls_port: "8443".into(),
      public_host: String::new(),
      external_db: false,
      database_url: String::new(),
      db_port: String::new(),
      log_level: "info".into(),
      backup_interval: "10".into(),
      backup_retain: "20".into(),
    }
  }

  #[test]
  fn defaults_need_no_flags() {
    let checked = defaults().check().unwrap();
    assert_eq!(checked.flags.len(), 0);
    assert_eq!(checked.health, "127.0.0.1:8080".parse().unwrap());
    assert_eq!(command_line(&checked.flags, None), "tms --headless");
  }

  #[test]
  fn changed_fields_become_flags_and_toml() {
    let form = ServerForm {
      port: "9000".into(),
      public_host: "tms.local".into(),
      log_level: "debug".into(),
      backup_interval: "0".into(),
      ..defaults()
    };
    let checked = form.check().unwrap();
    assert_eq!(
      command_line(&checked.flags, Some(Path::new("/srv/my tms"))),
      "tms --headless --data-dir \"/srv/my tms\" --port 9000 --public-host tms.local --log-level debug --backup-interval 0"
    );
    let toml = form.toml().unwrap();
    assert!(toml.contains("port = 9000\npublic-host = \"tms.local\"\nlog-level = \"debug\"\nbackup-interval = 0\n"));
  }

  #[test]
  fn bad_fields_are_explained() {
    assert!(
      ServerForm {
        port: "80000".into(),
        ..defaults()
      }
      .check()
      .unwrap_err()
      .contains("HTTP port")
    );
    assert!(
      ServerForm {
        https: true,
        ..defaults()
      }
      .check()
      .unwrap_err()
      .contains("certificate")
    );
    assert!(
      ServerForm {
        external_db: true,
        database_url: "mysql://x".into(),
        ..defaults()
      }
      .check()
      .unwrap_err()
      .contains("postgres://")
    );
    assert!(
      ServerForm {
        bind: "everywhere".into(),
        ..defaults()
      }
      .check()
      .is_err()
    );
  }
}
