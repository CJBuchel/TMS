use std::net::IpAddr;

use clap::Parser;

#[derive(Parser, Debug, Clone)]
#[command(version, about, long_about = None)]
pub struct TmsConfig {
  /// Run the server without the GUI
  #[arg(short, long, default_value_t = false)]
  pub no_gui: bool,

  /// The address to bind the server to
  #[arg(short, long, default_value = "0.0.0.0")]
  pub addr: IpAddr,

  /// The port to bind the web server to
  #[arg(short, long, default_value_t = 8080)]
  pub port: u16,

  /// Enable API Playground (GraphQL HTML Page)
  #[arg(long, default_value_t = false)]
  pub api_playground: bool,

  /// The path to the Key Value DB
  #[arg(long, default_value = "tms.db")]
  pub db_path: String,

  /// Backup path for the DB
  #[arg(long, default_value = "backups")]
  pub backup_path: String,

  /// Enable TLS Security (HTTPS)
  #[arg(long, default_value_t = false)]
  pub tls: bool,

  /// The path to the certificate
  #[arg(long, default_value = "cert.pem")]
  pub cert_path: String,

  /// The path to the private key
  #[arg(long, default_value = "key.pem")]
  pub key_path: String,
}

impl TmsConfig {
  pub fn parse_from_cli() -> Self {
    TmsConfig::parse()
  }
}
