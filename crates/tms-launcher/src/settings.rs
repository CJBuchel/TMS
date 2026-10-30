//! Server settings. Each value comes from, in order: a command-line flag, a `TMS_*` environment variable,
//! `tms.toml`, then the built-in default. clap handles the first two; this module adds the file.

use std::net::{IpAddr, Ipv4Addr};
use std::path::{Path, PathBuf};

use anyhow::Context;
use serde::Deserialize;

#[derive(Debug, Clone, Default, clap::Args)]
pub struct ServeArgs {
  /// Folder for the configuration file, embedded database, logs and backups. Default: `data` next to the program.
  #[arg(long, env = "TMS_DATA_DIR")]
  pub data_dir: Option<PathBuf>,
  /// Use this PostgreSQL server instead of the embedded one.
  #[arg(long, env = "TMS_DATABASE_URL")]
  pub database_url: Option<String>,
  /// Port for the embedded PostgreSQL on 127.0.0.1. Default: any free port.
  #[arg(long, env = "TMS_DB_PORT")]
  pub db_port: Option<u16>,
  /// Configuration file. Default: tms.toml in the data folder, if it exists.
  #[arg(long, env = "TMS_CONFIG")]
  pub config: Option<PathBuf>,
  /// Address to listen on. Default 0.0.0.0 (every network interface).
  #[arg(long, env = "TMS_BIND")]
  pub bind: Option<IpAddr>,
  /// HTTP port. With TLS, this port redirects to HTTPS. Default 8080.
  #[arg(long, env = "TMS_PORT")]
  pub port: Option<u16>,
  /// PEM certificate chain. Together with --tls-key, serves HTTPS.
  #[arg(long, env = "TMS_TLS_CERT")]
  pub tls_cert: Option<PathBuf>,
  /// PEM private key for --tls-cert.
  #[arg(long, env = "TMS_TLS_KEY")]
  pub tls_key: Option<PathBuf>,
  /// HTTPS port. Default 8443.
  #[arg(long, env = "TMS_TLS_PORT")]
  pub tls_port: Option<u16>,
  /// Hostname or IP to print in the join URL and QR code. Default: this machine's LAN addresses.
  #[arg(long, env = "TMS_PUBLIC_HOST")]
  pub public_host: Option<String>,
  /// Password for the first `admin` user. Only used when no users exist; it must be changed at first login.
  /// Sets the `admin` user's password at start, creating or re-enabling it if needed.
  #[arg(long, env = "TMS_ADMIN_PASSWORD")]
  pub admin_password: Option<String>,
  /// Log level: error, warn, info, debug or trace. Default info.
  #[arg(long, env = "TMS_LOG")]
  pub log_level: Option<String>,
  /// The web client folder. Default: `web` next to the program.
  #[arg(long, env = "TMS_WEB_DIR")]
  pub web_dir: Option<PathBuf>,
  /// Minutes between automatic backups; 0 turns them off. Default 10.
  #[arg(long, env = "TMS_BACKUP_INTERVAL")]
  pub backup_interval: Option<u32>,
  /// How many automatic backups to keep; manual ones are always kept. Default 20.
  #[arg(long, env = "TMS_BACKUP_RETAIN")]
  pub backup_retain: Option<usize>,
  /// Do not print the QR code at start.
  #[arg(long)]
  pub no_qr: bool,
}

/// The same settings, as written in tms.toml. Every key is optional.
#[derive(Debug, Default, Deserialize)]
#[serde(deny_unknown_fields, rename_all = "kebab-case")]
struct FileConfig {
  bind: Option<IpAddr>,
  port: Option<u16>,
  tls_cert: Option<PathBuf>,
  tls_key: Option<PathBuf>,
  tls_port: Option<u16>,
  public_host: Option<String>,
  database_url: Option<String>,
  db_port: Option<u16>,
  admin_password: Option<String>,
  log_level: Option<String>,
  web_dir: Option<PathBuf>,
  backup_interval: Option<u32>,
  backup_retain: Option<usize>,
}

#[derive(Debug, Clone)]
pub struct Tls {
  pub cert: PathBuf,
  pub key: PathBuf,
  pub port: u16,
}

#[derive(Debug, Clone)]
pub struct Settings {
  pub data_dir: PathBuf,
  pub bind: IpAddr,
  pub port: u16,
  pub tls: Option<Tls>,
  pub public_host: Option<String>,
  pub database_url: Option<String>,
  pub db_port: Option<u16>,
  pub admin_password: Option<String>,
  pub log_level: String,
  pub web_dir: PathBuf,
  pub backup_interval_minutes: u32,
  pub backup_retain: usize,
  pub show_qr: bool,
}

pub const DEFAULT_PORT: u16 = 8080;
pub const DEFAULT_TLS_PORT: u16 = 8443;

/// The folder the `tms` program is in. A release is one folder, so the program finds its `web` and `data` folders
/// here however it was started: double-click, shortcut, or a terminal in another folder.
fn program_dir() -> PathBuf {
  std::env::current_exe()
    .ok()
    .and_then(|exe| exe.parent().map(Path::to_path_buf))
    .unwrap_or_else(|| PathBuf::from("."))
}

pub fn default_data_dir() -> PathBuf {
  program_dir().join("data")
}

/// `web` next to the program. A debug build without one (`cargo run`) uses the workspace's `dx build` output.
pub fn default_web_dir() -> PathBuf {
  let beside = program_dir().join("web");
  #[cfg(debug_assertions)]
  if !beside.exists() {
    return PathBuf::from(concat!(
      env!("CARGO_MANIFEST_DIR"),
      "/../../target/dx/tms-client/debug/web/public"
    ));
  }
  beside
}

impl ServeArgs {
  pub fn resolve(self) -> anyhow::Result<Settings> {
    let data_dir = self.data_dir.clone().unwrap_or_else(default_data_dir);
    let default_file = data_dir.join("tms.toml");
    let file = match &self.config {
      Some(path) => read_file(path)?,
      None if default_file.exists() => read_file(&default_file)?,
      None => FileConfig::default(),
    };

    let tls_cert = self.tls_cert.or(file.tls_cert);
    let tls_key = self.tls_key.or(file.tls_key);
    let tls = match (tls_cert, tls_key) {
      (Some(cert), Some(key)) => Some(Tls {
        cert,
        key,
        port: self.tls_port.or(file.tls_port).unwrap_or(DEFAULT_TLS_PORT),
      }),
      (None, None) => None,
      _ => anyhow::bail!("HTTPS needs both a certificate (--tls-cert) and a key (--tls-key)"),
    };

    Ok(Settings {
      data_dir,
      bind: self.bind.or(file.bind).unwrap_or(IpAddr::V4(Ipv4Addr::UNSPECIFIED)),
      port: self.port.or(file.port).unwrap_or(DEFAULT_PORT),
      tls,
      public_host: self.public_host.or(file.public_host),
      database_url: self.database_url.or(file.database_url),
      db_port: self.db_port.or(file.db_port),
      admin_password: self.admin_password.or(file.admin_password),
      log_level: self.log_level.or(file.log_level).unwrap_or_else(|| "info".to_owned()),
      web_dir: self.web_dir.or(file.web_dir).unwrap_or_else(default_web_dir),
      backup_interval_minutes: self.backup_interval.or(file.backup_interval).unwrap_or(10),
      backup_retain: self.backup_retain.or(file.backup_retain).unwrap_or(20),
      show_qr: !self.no_qr,
    })
  }
}

impl Settings {
  pub fn backups_dir(&self) -> PathBuf {
    self.data_dir.join("backups")
  }

  pub fn db_source(&self) -> tms_db::Source {
    match &self.database_url {
      Some(url) => tms_db::Source::External { url: url.clone() },
      None => tms_db::Source::Embedded {
        dir: self.data_dir.join("postgres"),
        port: self.db_port,
      },
    }
  }
}

fn read_file(path: &Path) -> anyhow::Result<FileConfig> {
  let text = std::fs::read_to_string(path).with_context(|| format!("reading {}", path.display()))?;
  toml::from_str(&text).with_context(|| format!("in {}", path.display()))
}

#[cfg(test)]
mod tests {
  use super::*;

  fn args_with_file(contents: &str) -> (ServeArgs, PathBuf) {
    let dir = std::env::temp_dir().join(format!("tms-settings-{}-{}", std::process::id(), contents.len()));
    std::fs::create_dir_all(&dir).unwrap();
    std::fs::write(dir.join("tms.toml"), contents).unwrap();
    let args = ServeArgs {
      data_dir: Some(dir.clone()),
      ..ServeArgs::default()
    };
    (args, dir)
  }

  #[test]
  fn defaults() {
    let (args, _) = args_with_file("");
    let s = args.resolve().unwrap();
    assert_eq!(s.bind, IpAddr::V4(Ipv4Addr::UNSPECIFIED));
    assert_eq!(s.port, DEFAULT_PORT);
    assert!(s.tls.is_none());
    assert!(s.database_url.is_none());
    assert_eq!(s.log_level, "info");
  }

  #[test]
  fn file_fills_gaps_and_flags_win() {
    let (mut args, _) = args_with_file("port = 9000\nlog-level = \"debug\"\npublic-host = \"tms.local\"\n");
    args.port = Some(9100);
    let s = args.resolve().unwrap();
    assert_eq!(s.port, 9100, "a flag beats the file");
    assert_eq!(s.log_level, "debug", "the file beats the default");
    assert_eq!(s.public_host.as_deref(), Some("tms.local"));
  }

  #[test]
  fn tls_needs_both_parts() {
    let (mut args, _) = args_with_file("");
    args.tls_cert = Some("cert.pem".into());
    assert!(args.clone().resolve().is_err());
    args.tls_key = Some("key.pem".into());
    let tls = args.resolve().unwrap().tls.unwrap();
    assert_eq!(tls.port, DEFAULT_TLS_PORT);
  }

  #[test]
  fn unknown_keys_are_rejected() {
    let (args, _) = args_with_file("prot = 9000\n");
    let err = format!("{:#}", args.resolve().unwrap_err());
    assert!(err.contains("prot"), "{err}");
  }
}
