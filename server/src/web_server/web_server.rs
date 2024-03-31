use super::keys;

#[derive(Debug, Clone)]
pub struct WebConfig {
  pub port: u16,

  // if you have your own certificate and key instead, you can specify the paths here
  pub cert_path: Option<String>,
  pub key_path: Option<String>,
}

impl Default for WebConfig {
  fn default() -> WebConfig {
    WebConfig {
      port: 8080,
      cert_path: None,
      key_path: None,
    }
  }
}

pub struct WebServer {
  port: u16,
  certificates: keys::CertificateKeys,
}

impl WebServer {
  pub fn new(port: u16, config: WebConfig) -> WebServer {

    // users have their own certificate and key
    if config.cert_path.is_some() && config.key_path.is_some() {
      return WebServer {
        port,
        certificates: keys::CertificateKeys::new(config.cert_path, config.key_path),
      };
    }

    // otherwise, generate a self-signed certificate
    let certificates = keys::CertificateKeys::new(config.cert_path.clone(), config.key_path.clone());
    
    WebServer {
      port,
      certificates,
    }
  }

  pub async fn start_tls<F, R>(&self, routes: F)
  where
  F: warp::Filter<Extract = R, Error = warp::Rejection> + Clone + Send + Sync + 'static,
  R: warp::Reply,
   {

    let (cert, key) = self.certificates.get_keys();
    // start the web server with TLS
    warp::serve(routes)
      .tls()
      .cert(cert)
      .key(key)
      .run(([0,0,0,0], self.port))
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
