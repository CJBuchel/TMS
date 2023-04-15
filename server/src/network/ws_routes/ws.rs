use warp::hyper::Method;

use crate::network::security::Security;


pub struct TmsWebsocket {
  security: Security
}

impl TmsWebsocket {
  pub fn new(security: Security) -> Self {
    Self {
      security
    }
  }

  pub async fn start(&self) {
    let cors = warp::cors().allow_any_origin()
        .allow_headers(vec!["Access-Control-Allow-Headers", "Access-Control-Request-Method", "Access-Control-Request-Headers", "Origin", "Accept", "X-Requested-With", "Content-Type"])
        .allow_methods(&[Method::GET, Method::POST, Method::PUT, Method::PATCH, Method::DELETE, Method::OPTIONS, Method::HEAD]);
  }
}