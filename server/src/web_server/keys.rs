use std::net::{IpAddr, Ipv4Addr};

use local_ip_address::linux::local_ip;
use structopt::StructOpt;

use crate::ServerArgs;

pub struct CertificateKeys {
  pub cert: String, // actual cert, not the path
  pub key: String, // actual key, not the path
}

impl CertificateKeys {
  pub fn new(cert_path: Option<String>, key_path: Option<String>) -> CertificateKeys {
    // check if user provided certificate and key (command line)
    let opt = ServerArgs::from_args();

    // check if user provided certificate and key first (command line)
    if opt.cert_path.is_some() && opt.key_path.is_some() {
      // check the files exist
      let cert_path = opt.cert_path.unwrap();
      let key_path = opt.key_path.unwrap();
      log::info!("Using user provided certificate and key, {}, {}", cert_path, key_path);

      if !std::path::Path::new(&cert_path).exists() {
        log::error!("Certificate file does not exist: {}", cert_path);
        std::process::exit(1);
      }

      if !std::path::Path::new(&key_path).exists() {
        log::error!("Key file does not exist: {}", key_path);
        std::process::exit(1);
      }

      return CertificateKeys {
        cert: std::fs::read_to_string(cert_path).unwrap_or_default(),
        key: std::fs::read_to_string(key_path).unwrap_or_default(),
      }
    } else if cert_path.is_some() && key_path.is_some() { // check parameter provided certificate and key
      // read the certificate and key from the file
      return CertificateKeys {
        cert: std::fs::read_to_string(cert_path.unwrap_or_default()).unwrap_or_default(),
        key: std::fs::read_to_string(key_path.unwrap_or_default()).unwrap_or_default(),
      }
    } else { // generate a self-signed certificate
      // get local IP address
      let local_ip = match local_ip() {
        Ok(ip) => ip,
        Err(e) => {
          log::error!("Failed to get local IP address: {}", e);
          IpAddr::V4(Ipv4Addr::new(127, 0, 0, 1))
        }
      };
      
      // provide generic hosts and ip for certificate
      let subject_alt_names = vec![
        "localhost".to_string(),
        "127.0.0.1".to_string(),
        local_ip.to_string(),
      ];

      // generate a self-signed certificate
      let certificate = rcgen::generate_simple_self_signed(subject_alt_names).unwrap();

      // return the certificate and key
      return CertificateKeys {
        cert: certificate.cert.pem(),
        key: certificate.key_pair.serialize_pem(),
      }
    }
  }

  pub fn get_keys(&self) -> (String, String) {
    (self.cert.clone(), self.key.clone())
  }
}