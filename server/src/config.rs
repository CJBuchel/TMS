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
  pub web_port: u16,

  // /// The port to bind the GraphQL API to
  // #[arg(short, long, default_value_t = 2121)]
  // pub gql_port: u16,

  // /// The port to bind the WebSocket API to
  // #[arg(short, long, default_value_t = 2122)]
  // pub sock_port: u16,
  /// The path to the Key Value DB
  #[arg(short, long, default_value = "tms.db")]
  pub db_path: String,

  // certificate paths
  /// The path to the certificate
  #[arg(short, long, default_value = "cert.pem")]
  pub cert_path: String,

  /// The path to the private key
  #[arg(short, long, default_value = "key.pem")]
  pub key_path: String,
}

impl TmsConfig {
  pub fn parse_from_cli() -> Self {
    TmsConfig::parse()
  }
}
