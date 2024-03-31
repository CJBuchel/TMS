use std::path::PathBuf;
use database::Database;
use structopt::StructOpt;
use warp::Filter;
use crate::ServerArgs;

use super::keys;

#[derive(Debug, Clone)]
pub struct WebConfig {
  pub port: u16,
  pub addr: [u8; 4],

  // if you have your own certificate and key instead, you can specify the paths here
  pub cert_path: Option<String>,
  pub key_path: Option<String>,
}

impl Default for WebConfig {
  fn default() -> WebConfig {
    WebConfig {
      port: 8080,
      addr: [0,0,0,0],
      cert_path: None,
      key_path: None,
    }
  }
}

pub struct WebServer {
  port: u16,
  addr: [u8; 4],
  certificates: keys::CertificateKeys,
  no_tls: bool,
}

impl WebServer {
  pub fn new(config: WebConfig) -> WebServer {
    
    // users check for user args first
    let opt = ServerArgs::from_args();
    log::info!("{:?}", opt);
    // check if user provided port
    let port = opt.port.unwrap_or(config.port);
    let no_tls = opt.no_tls;

    // users have their own certificate and key
    if config.cert_path.is_some() && config.key_path.is_some() {
      return WebServer {
        port,
        addr: config.addr,
        certificates: keys::CertificateKeys::new(config.cert_path, config.key_path),
        no_tls,
      };
    }

    // otherwise, generate a self-signed certificate
    let certificates = keys::CertificateKeys::new(config.cert_path.clone(), config.key_path.clone());
    
    WebServer {
      port,
      addr: config.addr,
      certificates,
      no_tls,
    }
  }

  async fn start_tls<F, R>(&self, routes: F)
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
      .run((self.addr, self.port))
      .await;
  }

  async fn start_no_tls<F, R>(&self, routes: F)
  where
    F: warp::Filter<Extract = R, Error = warp::Rejection> + Clone + Send + Sync + 'static,
    R: warp::Reply,
  {
    // start the web server
    warp::serve(routes)
      .run((self.addr, self.port))
      .await;
  }

  pub async fn start<F, R>(&self, routes: F, db: Database)
  where
    F: warp::Filter<Extract = R, Error = warp::Rejection> + Clone + Send + Sync + 'static,
    R: warp::Reply,
  {

    // static files for web hosting
    let static_files_path = PathBuf::from("client").join("build").join("web");
    let static_files = warp::fs::dir(static_files_path).map(|reply| {
      warp::reply::with_header(reply, "Cache-Control", "public, max-age=86400")
    });

    // redirect to /ui
    let root_route = warp::path::end().map(|| {
      warp::redirect(warp::http::Uri::from_static("/ui"))
    });

    let web_route = warp::path("ui").and(static_files).or(root_route);
    let routes = web_route.or(routes);

    if self.no_tls {
      log::warn!("Starting server without TLS. Using http/ws... This is insecure!");
      let echo_tree_routes = db.get_inner().get_internal_routes();
      self.start_no_tls(routes.or(echo_tree_routes)).await;
    } else {
      log::info!("Starting server with TLS. Using with https/wss...");
      let echo_tree_routes = db.get_inner().get_internal_tls_routes();
      self.start_tls(routes.or(echo_tree_routes)).await;
    }
  }
}
