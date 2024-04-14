use structopt::StructOpt;

pub mod database;
pub mod multicast_dns;
pub mod network;
pub mod web_server;

#[derive(Debug, StructOpt)]
pub struct ServerArgs {
  #[structopt(default_value = "0.0.0.0",long = "addr", help = "Address to listen on, --addr 0.0.0.0")]
  pub addr: String,

  #[structopt(default_value = "8080", long = "port", help = "Port to listen on, --port 8080")]
  pub port: u16,

  #[structopt(long = "no-tls", help = "Use insecure connection, http/ws instead of https/wss, --no-tls")]
  pub no_tls: bool,

  #[structopt(long = "cert", help = "Path to the certificate file, --cert=cert.pem")]
  pub cert_path: Option<String>,

  #[structopt(long = "key", help = "Path to the key file, --key=key.rsa")]
  pub key_path: Option<String>,
}

impl ServerArgs {
  pub fn get_port() -> u16 {
    ServerArgs::from_args().port
  }

  pub fn get_addr() -> [u8; 4] {
    let arg_addr = ServerArgs::from_args().addr;
    let mut addr = [0; 4];
    let parts: Vec<&str> = arg_addr.split('.').collect();
    for i in 0..4 {
      addr[i] = parts[i].parse().unwrap();
    }
    addr
  }

  pub fn get_tls() -> bool {
    !ServerArgs::from_args().no_tls
  }

  pub fn get_cert_path() -> Option<String> {
    ServerArgs::from_args().cert_path
  }

  pub fn get_key_path() -> Option<String> {
    ServerArgs::from_args().key_path
  }
}