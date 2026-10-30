use std::path::Path;
use std::sync::Arc;

use axum::Router;
use axum::http::HeaderValue;
use axum::http::header::CACHE_CONTROL;
use sqlx::PgPool;
use tower_http::services::{ServeDir, ServeFile};
use tower_http::set_header::SetResponseHeader;
use tower_http::trace::TraceLayer;

use crate::assets;
use crate::auth::AuthState;
use crate::auth::limiter::LoginLimiter;
use crate::bus::Bus;
use crate::issues::IssueHub;
use crate::presence::PresenceHub;
use crate::timer::TimerService;

#[derive(Clone)]
pub struct AppState {
  pub pool: PgPool,
  pub bus: Bus,
  pub auth: Arc<AuthState>,
  pub login_limiter: Arc<LoginLimiter>,
  pub timers: Arc<TimerService>,
  pub presence: Arc<PresenceHub>,
  pub issues: Arc<IssueHub>,
}

impl AppState {
  /// Loads the token signing key and current revocations from the database, and resumes a match timer that was
  /// running when the server stopped.
  pub async fn new(pool: PgPool) -> anyhow::Result<Self> {
    Self::with_timer_speedup(pool, 1).await
  }

  /// As `new`, with match timings divided by `speedup`, so tests can run a whole match in milliseconds.
  pub async fn with_timer_speedup(pool: PgPool, speedup: u32) -> anyhow::Result<Self> {
    let auth = Arc::new(AuthState::load(&pool).await?);
    let bus = Bus::new(1024);
    let state = Self {
      pool,
      presence: Arc::new(PresenceHub::new(bus.clone())),
      issues: Arc::new(IssueHub::new(bus.clone())),
      bus,
      auth,
      login_limiter: Arc::default(),
      timers: Arc::new(TimerService::new(speedup)),
    };
    crate::timer::resume(&state).await?;
    Ok(state)
  }
}

/// `/api/v1/*` REST, `/ws` live feed, and everything else is the web client with an SPA fallback to index.html.
/// Files under `/assets` have content hashes in their names, so browsers keep them; everything else, index.html
/// included, is checked again on each load so a new release shows up straight away.
pub fn router(state: AppState, web_dir: &Path) -> Router {
  let api = Router::new()
    .nest("/api/v1", crate::http::routes())
    .route("/ws", axum::routing::get(crate::ws::handler))
    .route("/healthz", axum::routing::get(crate::http::system::healthz));

  let app = if assets::has_client(web_dir) {
    let hashed = ServeDir::new(web_dir.join("assets"))
      .precompressed_br()
      .precompressed_gzip();
    let spa = ServeDir::new(web_dir)
      .precompressed_br()
      .precompressed_gzip()
      .fallback(ServeFile::new(web_dir.join("index.html")));
    api
      .nest_service(
        "/assets",
        SetResponseHeader::overriding(
          hashed,
          CACHE_CONTROL,
          HeaderValue::from_static("public, max-age=31536000, immutable"),
        ),
      )
      .fallback_service(SetResponseHeader::overriding(
        spa,
        CACHE_CONTROL,
        HeaderValue::from_static("no-cache"),
      ))
  } else {
    tracing::warn!(web_dir = %web_dir.display(), "no web client found; pages explain how to add it");
    let dir = web_dir.to_path_buf();
    api.fallback(move || {
      let page = assets::missing_client_page(&dir);
      async move { page }
    })
  };
  app.layer(TraceLayer::new_for_http()).with_state(state)
}
