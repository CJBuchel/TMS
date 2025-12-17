use std::net::IpAddr;

use clap::Parser;

#[derive(Parser, Debug, Clone)]
#[command(version, about, long_about = None)]
pub struct TmsConfig {
  /// Run the server without the GUI
  #[arg(short, long, default_value_t = false)]
  pub no_gui: bool,

  /// Binding Ip Address
  #[arg(short, long, default_value = "0.0.0.0")]
  pub addr: IpAddr,

  /// Binding Port for the web server
  #[arg(short, long, default_value_t = 8080)]
  pub web_port: u16,

  /// Binding Port for the gRPC endpoint
  #[arg(long, default_value_t = 50051)]
  pub api_port: u16,

  /// The path to the Key Value Store
  #[arg(long, default_value = "tms.db")]
  pub db_path: String,

  /// The path for the backups directory
  #[arg(long, default_value = "backups")]
  pub backups_path: String,

  /// Enable TLS Security (HTTPS)
  #[arg(long, default_value_t = false)]
  pub tls: bool,

  /// The path to the certificate
  #[arg(long, default_value = "cert.pem")]
  pub cert_path: String,

  /// The path to the private key
  #[arg(long, default_value = "key.pem")]
  pub key_path: String,

  /// Admin password
  #[arg(long, default_value = "admin")]
  pub admin_password: String,

  /// TMS Mobi Reverse Proxy Token
  #[arg(long)]
  pub proxy_token: Option<String>,

  /// TMS Mobi Reverse Proxy Sub-Domain
  #[arg(long)]
  pub proxy_domain: Option<String>,
}

impl TmsConfig {
  pub fn parse_from_cli() -> Self {
    Self::parse()
  }
}
