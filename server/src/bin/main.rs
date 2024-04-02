use database::{SharedDatabase, SharedDatabaseTrait, BackupService};
use network::ClientMap;
use structopt::StructOpt;
// use echo_tree_rs::echo_tree_server::{EchoTreeServer, EchoTreeServerConfig};
use server::web_server::web_server::{WebConfig, WebServer};
use warp::Filter;
use std::env;

const DEFAULT_DB_PATH: &str = "tms.kvdb";
const DEFAULT_PORT: u16 = 8080;
const DEFAULT_ADDR: [u8; 4] = [0,0,0,0];

#[tokio::main]
async fn main() {
  let opt = server::ServerArgs::from_args();

  let port: u16 = match opt.port {
    Some(p) => p,
    None => DEFAULT_PORT,
  };

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

  // create clients
  let clients = ClientMap::new(tokio::sync::RwLock::new(std::collections::HashMap::new()));

  // create database
  let db = SharedDatabase::new_instance(port, DEFAULT_DB_PATH.to_string(), DEFAULT_ADDR);
  db.write().await.create_trees().await;
  db.write().await.create_roles().await;

  // startup the backup service
  db.write().await.start_backup_service();

  // create network
  let network = network::Network::new(db.clone(), clients.clone());

  // create web server
  let web_config = WebConfig {
    port,
    addr: DEFAULT_ADDR,
    cert_path: None,
    key_path: None,
  };

  // get main web/network routes
  let network_routes = network.get_network_routes();
  let echo_tree_routes = db.read().await.get_echo_tree_routes(!opt.no_tls).await;

  let web_server = WebServer::new(web_config);
  let routes = echo_tree_routes.or(network_routes);
  

  // start main web server, including the routes
  web_server.start(routes).await;

  // stop the backup service
  db.write().await.stop_backup_service().await;
}