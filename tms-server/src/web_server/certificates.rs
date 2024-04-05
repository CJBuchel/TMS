
pub struct CertificateKeys {
  pub cert: String, // actual cert, not the path
  pub key: String, // actual key, not the path
}

impl CertificateKeys {
  pub fn new(cert_path: Option<String>, key_path: Option<String>, local_ip: Option<String>) -> Self {
    // check if the user provided a certificate and key
    if cert_path.is_some() && key_path.is_some() {
      // check if the files exist
      let cert_path = cert_path.unwrap();
      let key_path = key_path.unwrap();

      log::info!("Using provided certificate and key, {}, {}", cert_path, key_path);

      if !std::path::Path::new(&cert_path).exists() {
        log::error!("Certificate file does not exist: {}", cert_path);
      }

      if !std::path::Path::new(&key_path).exists() {
        log::error!("Key file does not exist: {}", key_path);
      }

      if std::path::Path::new(&cert_path).exists() && std::path::Path::new(&key_path).exists() {
        return CertificateKeys {
          cert: std::fs::read_to_string(cert_path).unwrap_or_default(),
          key: std::fs::read_to_string(key_path).unwrap_or_default(),
        }
      }
    }

    // generate self signed
    log::info!("Generating self-signed certificate");
    let subject_alt_names = vec![
      "localhost".to_string(), // local machine
      local_ip.unwrap_or("127.0.0.1".to_string()), // local IP
    ];

    let certificate = rcgen::generate_simple_self_signed(subject_alt_names).unwrap();

    return CertificateKeys {
      cert: certificate.cert.pem(),
      key: certificate.key_pair.serialize_pem(),
    }
  }

  pub fn write_to_location(&self, cert_path: &str, key_path: &str) {
    std::fs::write(cert_path, &self.cert).unwrap();
    std::fs::write(key_path, &self.key).unwrap();
  }
}