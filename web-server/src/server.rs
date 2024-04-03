use std::path::PathBuf;

use crate::certificates::CertificateKeys;
use warp::Filter;

#[derive(Debug, Clone)]
pub struct WebConfig {
  pub port: u16,
  pub addr: [u8; 4],
  pub tls: bool,

  // the local IP address to use in the certificate
  pub local_ip: Option<String>,

  // if you have your own certificate and key instead, you can specify the paths here
  pub cert_path: Option<String>,
  pub key_path: Option<String>,
}

impl Default for WebConfig {
  fn default() -> WebConfig {
    WebConfig {
      port: 8080,
      addr: [0,0,0,0],
      tls: false,
      local_ip: None,
      cert_path: None,
      key_path: None,
    }
  }
}

pub struct WebServer {
  port: u16,
  addr: [u8; 4],
  certificates: CertificateKeys,
  tls: bool,
}

impl WebServer {
  pub fn new(config: WebConfig) -> Self {

    let certs = CertificateKeys::new(config.cert_path, config.key_path, config.local_ip);

    WebServer {
      port: config.port,
      addr: config.addr,
      certificates: certs,
      tls: config.tls,
    }
  }

  async fn start_tls<F, R>(&self, routes: F)
  where
  F: warp::Filter<Extract = R, Error = warp::Rejection> + Clone + Send + Sync + 'static,
  R: warp::Reply,
   {
    // start the web server with TLS
    warp::serve(routes)
      .tls()
      .cert(self.certificates.cert.clone())
      .key(self.certificates.key.clone())
      .run((self.addr, self.port))
      .await;
  }

  pub async fn start_no_tls<F, R>(&self, routes: F)
  where
    F: warp::Filter<Extract = R, Error = warp::Rejection> + Clone + Send + Sync + 'static,
    R: warp::Reply,
  {
    warp::serve(routes)
      .run((self.addr, self.port))
      .await;
  }

  pub async fn start<F, R>(&self, routes: F)
  where
    F: warp::Filter<Extract = R, Error = warp::Rejection> + Clone + Send + Sync + 'static,
    R: warp::Reply,
  {

    // static files for web hosting, (add cache control header for 24 hours)
    let static_files_path = PathBuf::from("client").join("build").join("web");
    let static_files = warp::fs::dir(static_files_path).map(|reply| {
      warp::reply::with_header(reply, "Cache-Control", "public, max-age=86400")
    });

    // redirect all root traffic to /ui
    let root_route = warp::path::end().map(|| {
      warp::redirect(warp::http::Uri::from_static("/ui"))
    });

    // append the web route to provided routes
    let web_route = warp::path("ui").and(static_files).or(root_route);
    let routes = web_route.or(routes);

    if self.tls {
      self.start_tls(routes).await;
    } else {
      self.start_no_tls(routes).await;
    }
  }
}