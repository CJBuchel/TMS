use network_schema::{DataSchemeExtensions, ErrorMessage};
use warp::http::StatusCode;

use crate::filters::Unauthorized;

pub async fn handle_rejection(err: warp::Rejection) -> Result<impl warp::Reply, warp::Rejection> {
  let code;
  let message;

  if err.is_not_found() {
    code = StatusCode::NOT_FOUND;
    message = "Not Found";
  } else if let Some(_) = err.find::<Unauthorized>() {
    code = StatusCode::UNAUTHORIZED;
    message = "Unauthorized";
  } else {
    code = StatusCode::INTERNAL_SERVER_ERROR;
    message = "Internal Server Error";
  }

  let m = ErrorMessage {
    code: code.as_u16(),
    message: message.to_string(),
  };

  let json = warp::reply::json(&m.to_json());

  Ok(warp::reply::with_status(json, code))
}