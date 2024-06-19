use tms_infra::*;
use warp::http::StatusCode;

use crate::network::filters::*;

pub async fn handle_rejection(err: warp::Rejection) -> Result<impl warp::Reply, warp::Rejection> {
  let code;
  let message;

  if err.is_not_found() {
    code = StatusCode::NOT_FOUND;
    message = "Not Found";
  } else if let Some(_) = err.find::<UnauthorizedToken>() {
    code = StatusCode::UNAUTHORIZED;
    message = "Unauthorized Auth Token";
  } else if let Some(_) = err.find::<ClientNotFound>() {
    code = StatusCode::NOT_FOUND;
    message = "Client Not Found";
  } else if let Some(_) = err.find::<UnauthorizedClient>() {
    code = StatusCode::UNAUTHORIZED;
    message = "Unauthorized Client Access";
  } else if let Some(_) = err.find::<UnauthorizedLogin>() {
    code = StatusCode::UNAUTHORIZED;
    message = "Unauthorized Login";
  } else if let Some(e) = err.find::<BadRequestWithMessage>() {
    code = StatusCode::BAD_REQUEST;
    message = e.message.as_str();
  } else if let Some(_) = err.find::<AuthenticationRequired>() {
    code = StatusCode::NETWORK_AUTHENTICATION_REQUIRED;
    message = "Authentication Required";
  }

  // fallback to a generic message for unhandled errors
  else {
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