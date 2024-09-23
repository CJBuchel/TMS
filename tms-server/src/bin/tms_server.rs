use std::env;

use local_ip_address::local_ip;
use tms_server::database::*;
use tms_server::multicast_dns::*;
use tms_server::network::ClientMap;
use tms_server::network::*;
use tms_server::services::SharedServices;
use tms_server::services::SharedServicesTrait;
use tms_server::web_server::certificates::CertificateKeys;
use tms_server::web_server::web_server::WebConfig;
use tms_server::web_server::web_server::WebServer;
use tms_server::ServerArgs;
use warp::Filter;

const DEFAULT_DB_PATH: &str = "tms.kvdb";

#[tokio::main]
async fn main() {
  // initialize log env
  #[cfg(debug_assertions)]
  env::set_var("RUST_LOG", "debug");
  #[cfg(not(debug_assertions))]
  env::set_var("RUST_LOG", "info");

  // initialize logger
  #[cfg(debug_assertions)]
  log4rs::init_file("log_config/debug_log4rs.yaml", Default::default()).unwrap();
  #[cfg(not(debug_assertions))]
  log4rs::init_file("log_config/release_log4rs.yaml", Default::default()).unwrap();
  log::info!("TMS Start...");

  //
  // -- Start --
  //

  // get local ip (if possible)
  let ip = match local_ip() {
    Ok(ip) => ip.to_string(),
    Err(_) => {
      log::error!("Could not get local IP address");
      String::from("127.0.0.1")
    }
  };

  // broadcast server
  let mut m_dns = MulticastDnsBroadcaster::new(ip.clone(), ServerArgs::get_port(), ServerArgs::get_tls());
  if ServerArgs::get_mdns() {
    m_dns.start();
  } else {
    log::warn!("Multicast DNS Service Disabled");
  }

  // create clients
  let clients = ClientMap::new(tokio::sync::RwLock::new(std::collections::HashMap::new()));

  // create database
  let mut db = SharedDatabase::new_instance(ip.clone(), ServerArgs::get_port(), DEFAULT_DB_PATH.to_string(), ServerArgs::get_addr());
  db.write().await.initial_setup().await;

  // startup the backup service
  db.write().await.start_backup_service();

  // startup the integrity check service
  db.start_integrity_check_service().await;

  // create services
  let services = SharedServices::new_instance(db.clone(), clients.clone());

  // create network
  let network = Network::new(db.clone(), clients.clone(), services, ip.clone(), ServerArgs::get_tls(), ServerArgs::get_port());

  // check arguments for certificates
  let cert_path = ServerArgs::get_cert_path();
  let key_path = ServerArgs::get_key_path();
  let certs: CertificateKeys;

  if cert_path.is_none() && key_path.is_none() {
    certs = CertificateKeys::new(Some("cert.pem".to_string()), Some("key.rsa".to_string()), Some(ip.clone()));
    #[cfg(not(debug_assertions))]
    certs.write_to_location("cert.pem", "key.rsa");
  } else {
    certs = CertificateKeys::new(cert_path, key_path, Some(ip.clone()));
  }

  // create web server
  let web_config = WebConfig {
    port: ServerArgs::get_port(),
    addr: ServerArgs::get_addr(),
    tls: ServerArgs::get_tls(),
    local_ip: ip,
  };

  // get main web/network routes
  let network_routes = network.get_network_routes();
  let echo_tree_routes = db.read().await.get_echo_tree_routes(ServerArgs::get_tls()).await;

  // combine routes
  let routes = echo_tree_routes.or(network_routes);

  // start main web server, including the routes
  let web_server = WebServer::new(web_config, certs);
  web_server.start(routes).await;

  //
  // Stop all services
  //

  // stop the multicast dns service
  m_dns.stop();
  // stop the backup service
  db.write().await.stop_backup_service().await;
  db.stop_integrity_check_service().await;
}
