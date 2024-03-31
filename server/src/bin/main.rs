use database::Database;
// use echo_tree_rs::echo_tree_server::{EchoTreeServer, EchoTreeServerConfig};
use server::web_server::web_server::{WebConfig, WebServer};
use warp::Filter;
use std::{env, path::PathBuf};

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

  log::debug!("This is a debug message");
  log::info!("Start TMS...");
  log::warn!("This is a warning");
  log::error!("This is an error");

  match env::current_dir() {
    Ok(path) => {
      log::info!("Current directory: {:?}", path);
    }
    Err(e) => {
      log::error!("Failed to get current directory: {:?}", e);
    }
  }

  let static_files_path = PathBuf::from("client").join("build").join("web");
  let static_files = warp::fs::dir(static_files_path).map(|reply| {
    warp::reply::with_header(reply, "Cache-Control", "public, max-age=86400")
  });

  let root_route = warp::path::end().map(|| {
    warp::redirect(warp::http::Uri::from_static("/ui"))
  });

  let web_route = warp::path("ui").and(static_files).or(root_route);
  // let routes = web_route.or(echo_tree_routes);

  // #[cfg(debug_assertions)]
  // {
  //   let config = WebConfig::default();
  //   WebServer::new(8080, config).start(routes).await;
  // }

  // #[cfg(not(debug_assertions))]
  // {
  //   let config = WebConfig::default();
  //   WebServer::new(8080, config).start_tls(routes).await;
  // }
}