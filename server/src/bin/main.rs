use database::Database;
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
  log4rs::init_file("config/debug_log4rs.yaml", Default::default()).unwrap();
  #[cfg(not(debug_assertions))]
  log4rs::init_file("config/release_log4rs.yaml", Default::default()).unwrap();

  log::info!("TMS Start...");

  // create database
  let mut db = Database::new(port, DEFAULT_DB_PATH.to_string(), DEFAULT_ADDR);
  db.create_trees().await;
  db.create_roles().await;

  // create web server
  let web_config = WebConfig {
    port: port,
    addr: DEFAULT_ADDR,
    cert_path: None,
    key_path: None,
  };

  let web_server = WebServer::new(web_config);
  let default_route = warp::path::end().map(|| warp::reply::html("Hello, World!"));
  
  let _ = db.get_inner().backup_db("backups/backup.zip").await;
  let _ = db.get_inner().restore_db("backups/backup.zip").await;
  web_server.start(default_route, db).await;
}