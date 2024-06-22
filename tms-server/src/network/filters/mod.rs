use warp::Filter;
use crate::{database::SharedDatabase, services::SharedServices};
use super::ClientMap;

pub const HEADER_X_AUTH_TOKEN: &str = "X-Auth-Token";
pub const HEADER_X_CLIENT_ID: &str = "X-Client-Id";

pub fn with_clients(
  clients: ClientMap,
) -> impl warp::Filter<Extract = (ClientMap,), Error = std::convert::Infallible> + Clone {
  warp::any().map(move || clients.clone())
}

pub fn with_db(
  db: SharedDatabase,
) -> impl warp::Filter<Extract = (SharedDatabase,), Error = std::convert::Infallible> + Clone {
  warp::any().map(move || db.clone())
}

pub fn with_services(
  services: SharedServices,
) -> impl warp::Filter<Extract = (SharedServices,), Error = std::convert::Infallible> + Clone {
  warp::any().map(move || services.clone())
}

mod header_filters; // private for network only
pub mod pulse_filter;
pub mod register_filter;
pub mod login_filter;
pub mod websocket_filter;
pub mod tournament_config_filter;
pub mod tournament_schedule_filter;
pub mod robot_game_matches_filter;

#[derive(Debug)]
pub struct UnauthorizedToken;
impl warp::reject::Reject for UnauthorizedToken {}

#[derive(Debug)]
pub struct UnauthorizedClient;
impl warp::reject::Reject for UnauthorizedClient {}

#[derive(Debug)]
pub struct AuthenticationRequired;
impl warp::reject::Reject for AuthenticationRequired {}

#[derive(Debug)]
pub struct ClientNotFound;
impl warp::reject::Reject for ClientNotFound {}

#[derive(Debug)]
pub struct UnauthorizedLogin;
impl warp::reject::Reject for UnauthorizedLogin{}

#[derive(Debug)]
pub struct BadRequestWithMessage {
  pub message: String,
}

impl warp::reject::Reject for BadRequestWithMessage{}