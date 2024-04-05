use std::env;

use local_ip_address::local_ip;
use tms_server::network::ClientMap;
use tms_server::database::*;
use tms_server::network::*;
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

  // create clients
  let clients = ClientMap::new(tokio::sync::RwLock::new(std::collections::HashMap::new()));

  // create database
  let db = SharedDatabase::new_instance(ServerArgs::get_port(), DEFAULT_DB_PATH.to_string(), ServerArgs::get_addr());
  db.write().await.create_trees().await;
  db.write().await.create_roles().await;

  // startup the backup service
  db.write().await.start_backup_service();

  // create network
  let network = Network::new(db.clone(), clients.clone(), ip.clone(), ServerArgs::get_tls(), ServerArgs::get_port());

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
    local_ip: Some(ip),
  };

  // get main web/network routes
  let network_routes = network.get_network_routes();
  let echo_tree_routes = db.read().await.get_echo_tree_routes(ServerArgs::get_tls()).await;

  // combine routes
  let routes = echo_tree_routes.or(network_routes);
  
  // start main web server, including the routes
  let web_server = WebServer::new(web_config, certs);
  web_server.start(routes).await;

  // stop the backup service
  db.write().await.stop_backup_service().await;
}