use log::debug;

use crate::common::ResponseResult;

mod broker;
pub mod register_handlers;
pub mod role_auth_handler;
pub mod ws_handlers;

pub fn pulse_handler() -> impl futures::Future<Output = ResponseResult<impl warp::reply::Reply>> {
  debug!("pulse");
  futures::future::ready(Ok(warp::http::StatusCode::OK))
}