use axum::Json;
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use tms_core::dto::ApiErrorBody;

/// Every handler error. The `code` is a stable machine-readable string; the message is for humans.
#[derive(Debug, thiserror::Error)]
pub enum ApiError {
  #[error("{1}")]
  BadRequest(&'static str, String),
  /// Input that is well formed but has several problems, listed in `details` (422).
  #[error("{1}")]
  Invalid(&'static str, String, Vec<String>),
  #[error("authentication required")]
  Unauthenticated,
  #[error("invalid credentials")]
  InvalidCredentials,
  #[error("missing role")]
  Forbidden,
  #[error("the password must be changed before doing anything else")]
  PasswordChangeRequired,
  #[error("too many failed attempts; wait a few minutes and try again")]
  RateLimited,
  #[error("{0} not found")]
  NotFound(&'static str),
  #[error("{1}")]
  Conflict(&'static str, String),
  #[error(transparent)]
  Internal(#[from] anyhow::Error),
}

impl From<sqlx::Error> for ApiError {
  fn from(e: sqlx::Error) -> Self {
    if let Some(db) = e.as_database_error() {
      if db.is_unique_violation() {
        return ApiError::Conflict("conflict.duplicate", "a record with that value already exists".into());
      }
      if db.is_foreign_key_violation() {
        return ApiError::Conflict(
          "conflict.in_use",
          "it is still used by the schedule or another record".into(),
        );
      }
    }
    ApiError::Internal(e.into())
  }
}

impl ApiError {
  fn status_and_code(&self) -> (StatusCode, &'static str) {
    match self {
      ApiError::BadRequest(code, _) => (StatusCode::BAD_REQUEST, code),
      ApiError::Invalid(code, _, _) => (StatusCode::UNPROCESSABLE_ENTITY, code),
      ApiError::Unauthenticated => (StatusCode::UNAUTHORIZED, "auth.required"),
      ApiError::InvalidCredentials => (StatusCode::UNAUTHORIZED, "auth.invalid_credentials"),
      ApiError::Forbidden => (StatusCode::FORBIDDEN, "auth.forbidden"),
      ApiError::PasswordChangeRequired => (StatusCode::FORBIDDEN, "auth.password_change_required"),
      ApiError::RateLimited => (StatusCode::TOO_MANY_REQUESTS, "auth.rate_limited"),
      ApiError::NotFound(_) => (StatusCode::NOT_FOUND, "not_found"),
      ApiError::Conflict(code, _) => (StatusCode::CONFLICT, code),
      ApiError::Internal(_) => (StatusCode::INTERNAL_SERVER_ERROR, "internal"),
    }
  }
}

impl IntoResponse for ApiError {
  fn into_response(self) -> Response {
    let (status, code) = self.status_and_code();
    let message = if let ApiError::Internal(e) = &self {
      tracing::error!(error = ?e, "internal error");
      "internal server error".to_owned()
    } else {
      self.to_string()
    };
    let details = if let ApiError::Invalid(_, _, details) = self {
      details
    } else {
      Vec::new()
    };
    (
      status,
      Json(ApiErrorBody {
        code: code.to_owned(),
        message,
        details,
      }),
    )
      .into_response()
  }
}

pub type ApiResult<T> = Result<T, ApiError>;
