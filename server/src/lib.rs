use structopt::StructOpt;

#[derive(Debug, StructOpt)]
pub struct ServerArgs {
  #[structopt(long = "port", help = "Port to listen on, --port 8080")]
  pub port: Option<u16>,

  #[structopt(long = "addr", help = "Address to listen on, --addr 0.0.0.0")]
  pub addr: Option<String>,

  #[structopt(long = "no-tls", help = "Use insecure connection, http/ws instead of https/wss, --no-tls")]
  pub no_tls: bool,

  #[structopt(long = "cert", help = "Path to the certificate file, --cert cert.pem")]
  pub cert_path: Option<String>,

  #[structopt(long = "key", help = "Path to the key file, --key key.rsa")]
  pub key_path: Option<String>,
}

pub mod web_server;