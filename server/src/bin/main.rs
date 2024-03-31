use database::Database;
// use echo_tree_rs::echo_tree_server::{EchoTreeServer, EchoTreeServerConfig};
use server::web_server::web_server::{WebConfig, WebServer};
use warp::Filter;
use std::env;

const DB_PATH: &str = "tms.kvdb";
const PORT: u16 = 8080;
const ADDR: [u8; 4] = [0,0,0,0];

#[tokio::main]
async fn main() {

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

  log::info!("Start TMS...");

  // create database
  let mut db = Database::new(PORT, DB_PATH.to_string(), ADDR);
  db.create_trees().await;

  // create webserver
  let web_config = WebConfig {
    port: PORT,
    addr: ADDR,
    cert_path: None,
    key_path: None,
  };

  let web_server = WebServer::new(web_config);
  let default_route = warp::path::end().map(|| warp::reply::html("Hello, World!"));
  
  let _ = db.get_inner().backup_db("backups/backup.zip").await;
  let _ = db.get_inner().restore_db("backups/backup.zip").await;
  web_server.start(default_route, db).await;
}