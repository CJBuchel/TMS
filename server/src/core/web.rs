use std::net::SocketAddr;

use anyhow::Result;
use axum::{Router, routing::get};
use tower::ServiceBuilder;
use tower_http::{
  cors::{Any, CorsLayer},
  services::{ServeDir, ServeFile},
};

use crate::core::shutdown::ShutdownNotifier;

pub struct Web {
  addr: SocketAddr,
  static_dir: String,
}

impl Web {
  pub fn new(addr: SocketAddr, static_dir: String) -> Self {
    Self { addr, static_dir }
  }

  pub async fn serve(&self) -> Result<()> {
    let mut shutdown_rx = ShutdownNotifier::get().subscribe();

    let cors = CorsLayer::new()
      .allow_origin(Any)
      .allow_headers(Any)
      .allow_methods(Any)
      .expose_headers(Any);

    // Create router with static file serving
    let app = Router::new()
      .route("/health", get(|| async { "OK" }))
      // Static file serving as fallback
      .fallback_service(
        ServiceBuilder::new()
          .layer(cors)
          .service(ServeDir::new("client/build/web").fallback(ServeFile::new("client/build/web/index.html"))),
      )
      // fallback to error 404
      .layer(CorsLayer::permissive());

    // Create TCP listener
    let listener = tokio::net::TcpListener::bind(self.addr).await?;

    log::info!("Web server listening on http://{}", self.addr);
    log::info!("Serving static files from: {}", self.static_dir);

    // Serve with graceful shutdown
    match axum::serve(listener, app)
      .with_graceful_shutdown(async move {
        shutdown_rx.recv().await.ok();
      })
      .await
    {
      Ok(()) => Ok(()),
      Err(e) => {
        log::error!("Web server error: {:?}", e);
        Err(anyhow::Error::msg("Failed to serve web"))
      }
    }
  }
}
