use std::net::{IpAddr, Ipv4Addr};

use local_ip_address::linux::local_ip;


pub struct CertificateKeys {
  pub cert: String, // actual cert, not the path
  pub key: String, // actual key, not the path
}

impl CertificateKeys {
  pub fn new(cert_path: Option<String>, key_path: Option<String>) -> CertificateKeys {
    if cert_path.is_none() && key_path.is_none() {
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
    } else {
      // read the certificate and key from the file
      return CertificateKeys {
        cert: std::fs::read_to_string(cert_path.unwrap_or_default()).unwrap_or_default(),
        key: std::fs::read_to_string(key_path.unwrap_or_default()).unwrap_or_default(),
      }
    }
  }

  pub fn write_generated_to_file(&self) {
    // write the certificate to a file
    std::fs::write("cert.pem", self.cert.clone()).unwrap_or_default();
    std::fs::write("key.rsa", self.key.clone()).unwrap_or_default();
  }

  pub fn get_keys(&self) -> (String, String) {
    (self.cert.clone(), self.key.clone())
  }
}