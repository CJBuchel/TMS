use echo_tree_rs::echo_tree_server::{EchoTreeServer, EchoTreeServerConfig};
use server::web_server::WebServer;
use warp::Filter;
use std::{env, path::PathBuf};

#[tokio::main]
async fn main() {

  // initialize log env
  #[cfg(debug_assertions)]
  env::set_var("RUST_LOG", "debug");
  #[cfg(not(debug_assertions))]
  env::set_var("RUST_LOG", "info");

  // initialize logger
  pretty_env_logger::init();

  log::info!("Start TMS...");

  let config = EchoTreeServerConfig {
    db_path: "tree.kvdb".to_string(),
    port: 8080,
    addr: [0,0,0,0].into(),
  };

  let db_server = EchoTreeServer::new(config);

  #[cfg(debug_assertions)]
  let echo_tree_routes = db_server.get_internal_routes();

  #[cfg(not(debug_assertions))]
  let echo_tree_routes = db_server.get_internal_tls_routes();

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
  let routes = web_route.or(echo_tree_routes);

  #[cfg(debug_assertions)]
  WebServer::new(8080).start(routes).await;

  #[cfg(not(debug_assertions))]
  WebServer::new(8080).start_tls(routes).await;
}