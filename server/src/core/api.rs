use std::{net::SocketAddr, time::Duration};

use anyhow::Result;
use tonic::transport::Server;
use tonic_web::GrpcWebLayer;
use tower_http::cors::{Any, CorsLayer};

use crate::{
  core::{auth_interceptors::auth_interceptor, shutdown::ShutdownNotifier},
  generated::api::{tournament_service_server::TournamentServiceServer, user_service_server::UserServiceServer},
  modules::{tournament::TournamentApi, user::UserApi},
};

pub struct Api {
  addr: SocketAddr,
}

impl Api {
  pub fn new(addr: SocketAddr) -> Self {
    Self { addr }
  }

  pub async fn serve(&self) -> Result<()> {
    let mut shutdown_rx = ShutdownNotifier::get().subscribe();

    let cors = CorsLayer::new()
      .allow_origin(Any)
      .allow_headers(Any)
      .allow_methods(Any)
      .expose_headers(Any);

    let router = Server::builder()
      // Enable HTTP/1.1 for gRPC-Web (browsers)
      .accept_http1(true)
      // HTTP/2 Keepalive settings (for native clients)
      .http2_keepalive_interval(Some(Duration::from_secs(30)))
      .http2_keepalive_timeout(Some(Duration::from_secs(10)))
      // TCP Keepalive (detect broken connections)
      .tcp_keepalive(Some(Duration::from_secs(60)))
      // Connection Timeout
      .timeout(Duration::from_secs(30))
      // Max concurrent streams per connection
      .initial_stream_window_size(Some(1024 * 1024)) // 1MB
      .initial_connection_window_size(Some(1024 * 1024 * 2)) // 2MB
      // Add CORS layer for web clients
      .layer(cors)
      // Add gRPC-Web layer support
      .layer(GrpcWebLayer::new())
      // Add services
      .add_service(UserServiceServer::with_interceptor(UserApi {}, auth_interceptor))
      .add_service(TournamentServiceServer::with_interceptor(
        TournamentApi {},
        auth_interceptor,
      ));

    match router
      .serve_with_shutdown(self.addr, async move {
        shutdown_rx.recv().await.ok();
      })
      .await
    {
      Ok(()) => Ok(()),
      Err(e) => {
        log::error!("Error: {:?}", e);
        Err(anyhow::Error::msg("Failed to serve API"))
      }
    }
  }
}
