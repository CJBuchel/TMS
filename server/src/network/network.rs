use std::{sync::{Arc, RwLock}, collections::HashMap, convert::Infallible};

// extern crate openssl;
use openssl::{rsa::{Rsa, Padding}, asn1::Asn1Time, x509::X509Builder, hash::MessageDigest, pkey::Private};
use tokio::sync::mpsc;
use warp::{ws::Message, Rejection, Filter, hyper::Method};

pub type Result<T> = std::result::Result<T, Rejection>;
pub type Clients = Arc<RwLock<HashMap<String, Client>>>;

use super::{ws, mdns_broadcaster::start_broadcast};
use super::handler;
use super::mdns_broadcaster;

#[derive(Debug, Clone)]
pub struct Client {
  pub user_id: String,
  pub topics: Vec<String>,
  pub sender: Option<mpsc::UnboundedSender<std::result::Result<Message, warp::Error>>>
}

fn with_clients(clients: Clients) -> impl Filter<Extract = (Clients,), Error = Infallible> + Clone {
  warp::any().map(move || clients.clone())
}

pub struct Network {
  private_key: Vec<u8>,
  public_key: Vec<u8>,
  rsa: Rsa<Private>
}

impl Network {
  pub fn new() -> Self {
    // Generate the RSA Key
    let rsa = Rsa::generate(2048).unwrap();
    let raw_private_key = openssl::pkey::PKey::from_rsa(rsa.clone()).unwrap();
    let raw_public_key = rsa.public_key_to_pem().unwrap();
    let raw_public_key = openssl::pkey::PKey::public_key_from_pem(raw_public_key.as_slice()).unwrap();

    // Time
    let not_before = Asn1Time::days_from_now(0).unwrap();
    let not_after = Asn1Time::days_from_now(3690).unwrap();

    // Name builder
    let mut x509_name = openssl::x509::X509NameBuilder::new().unwrap();
    x509_name.append_entry_by_text("C", "AU").unwrap();
    x509_name.append_entry_by_text("ST", "CA").unwrap();
    x509_name.append_entry_by_text("O", "TMS").unwrap();
    x509_name.append_entry_by_text("CN", "TMS Host").unwrap();
    let x509_name = x509_name.build();

    // x509 Builder
    let mut x509_builder = X509Builder::new().unwrap();
    // x509_builder.set_version(2).unwrap();
    x509_builder.set_subject_name(&x509_name).unwrap();
    x509_builder.set_issuer_name(&x509_name).unwrap();
    x509_builder.set_pubkey(&raw_public_key).unwrap();
    x509_builder.set_not_before(&not_before).unwrap();
    x509_builder.set_not_after(&not_after).unwrap();
    x509_builder.sign(&raw_private_key, MessageDigest::sha256()).unwrap();
    let x509_cert = x509_builder.build();
    
    // Create the mdns service to broadcast server

    Self { 
      private_key: rsa.private_key_to_pem().unwrap(),
      public_key: x509_cert.to_pem().unwrap(),
      rsa: rsa
    }
    // Start warp server
  }

  pub async fn start(&self) {
    let cors = warp::cors().allow_any_origin()
        .allow_headers(vec!["Access-Control-Allow-Headers", "Access-Control-Request-Method", "Access-Control-Request-Headers", "Origin", "Accept", "X-Requested-With", "Content-Type"])
        .allow_methods(&[Method::GET, Method::POST, Method::PUT, Method::PATCH, Method::DELETE, Method::OPTIONS, Method::HEAD]);

    let clients: Clients = Arc::new(RwLock::new(HashMap::new()));
    let health_route = warp::path!("health").and_then(handler::health_handler);

    let register = warp::path("register");
    let register_routes = register
      .and(warp::post())
      .and(warp::body::json())
      .and(with_clients(clients.clone()))
      .and_then(handler::register_handler)
      .or(register
        .and(warp::delete())
        .and(warp::path::param())
        .and(with_clients(clients.clone()))
        .and_then(handler::unregister_handler)
      );

    let publish = warp::path!("publish")
      .and(warp::body::json())
      .and(with_clients(clients.clone()))
      .and_then(handler::publish_handler);

    let ws_route = warp::path("ws")
        .and(warp::ws())
        .and(warp::path::param())
        .and(with_clients(clients.clone()))
        .and_then(handler::ws_handler);

    let routes =
        health_route
        .or(register_routes)
        .or(ws_route)
        .or(publish)
        .with(cors);
  
    
    // Start mDNS server
    start_broadcast("_mdns-tms-server".to_string());
    warp::serve(routes).run(([0, 0, 0, 0], 2121)).await;
  }

  pub async fn encrypt(&self, data: String) -> Vec<u8> {
    let mut buf: Vec<u8> = vec![0; self.rsa.size() as usize];
    let _ = self.rsa.public_encrypt(data.as_bytes(), &mut buf, Padding::PKCS1).unwrap();
    return buf;
  }

  pub async fn decrypt(&self, buf: Vec<u8>) -> String {
    let mut data: Vec<u8> = vec![0; self.rsa.size() as usize];
    let _ = self.rsa.private_decrypt(&buf, &mut data, Padding::PKCS1);
    return String::from_utf8(data).unwrap();
  }
}