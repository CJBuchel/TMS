use axum::Json;
use axum::extract::State;
use axum::http::StatusCode;
use tms_core::dto::VersionInfo;
use tms_core::ws::PROTOCOL_VERSION;

use crate::AppState;

pub async fn healthz(State(state): State<AppState>) -> StatusCode {
  match sqlx::query("select 1").execute(&state.pool).await {
    Ok(_) => StatusCode::OK,
    Err(_) => StatusCode::SERVICE_UNAVAILABLE,
  }
}

pub async fn version() -> Json<VersionInfo> {
  Json(VersionInfo {
    version: env!("CARGO_PKG_VERSION").to_owned(),
    protocol: PROTOCOL_VERSION,
  })
}
