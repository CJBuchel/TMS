use std::net::{IpAddr, Ipv4Addr};

use local_ip_address::linux::local_ip;

pub struct WebServer {
  ip_address: IpAddr,
  cert: String,
  key: String,
  port: u16,
}

impl WebServer {
  pub fn new(port: u16) -> WebServer {
    
    let local_ip = match local_ip() {
      Ok(ip) => ip,
      Err(e) => {
        log::error!("Failed to get local IP address: {}", e);
        IpAddr::V4(Ipv4Addr::new(127, 0, 0, 1))
      }
    };

    let subject_alt_names = vec!["localhost".to_string(), "127.0.0.1".to_string(), local_ip.to_string(), "0.0.0.0".to_string()];

    let cert = rcgen::generate_simple_self_signed(subject_alt_names).unwrap();
    let serialized_cert = cert.cert.pem();
    let serialized_key = cert.key_pair.serialize_pem();

    // // write the certificate to a file
    std::fs::write("cert.pem", serialized_cert.clone()).unwrap_or_default();
    std::fs::write("key.rsa", serialized_key.clone()).unwrap_or_default();

    WebServer {
      ip_address: local_ip,
      cert: serialized_cert,
      key: serialized_key,
      port,
    }
  }

  pub fn get_cert(&self) -> String {
    self.cert.clone()
  }

  pub fn get_key(&self) -> String {
    self.key.clone()
  }

  pub fn get_ip(&self) -> IpAddr {
    self.ip_address.clone()
  }

  pub async fn start_tls<F, R>(&self, routes: F)
  where
  F: warp::Filter<Extract = R, Error = warp::Rejection> + Clone + Send + Sync + 'static,
  R: warp::Reply,
   {
    // start the web server with TLS
    warp::serve(routes)
      .tls()
      .cert_path("cert.pem")
      .key_path("key.rsa")
      .run(([127,0,0,1], self.port))
      .await;
  }

  pub async fn start<F, R>(&self, routes: F)
  where
    F: warp::Filter<Extract = R, Error = warp::Rejection> + Clone + Send + Sync + 'static,
    R: warp::Reply,
  {
    // start the web server
    warp::serve(routes)
      .run(([0,0,0,0], self.port))
      .await;
  }
}
