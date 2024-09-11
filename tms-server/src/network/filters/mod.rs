use super::ClientMap;
use crate::{database::SharedDatabase, services::SharedServices};
use warp::Filter;

pub const HEADER_X_AUTH_TOKEN: &str = "X-Auth-Token";
pub const HEADER_X_CLIENT_ID: &str = "X-Client-Id";

pub fn with_clients(clients: ClientMap) -> impl warp::Filter<Extract = (ClientMap,), Error = std::convert::Infallible> + Clone {
  warp::any().map(move || clients.clone())
}

pub fn with_db(db: SharedDatabase) -> impl warp::Filter<Extract = (SharedDatabase,), Error = std::convert::Infallible> + Clone {
  warp::any().map(move || db.clone())
}

pub fn with_services(services: SharedServices) -> impl warp::Filter<Extract = (SharedServices,), Error = std::convert::Infallible> + Clone {
  warp::any().map(move || services.clone())
}

mod header_filters; // private for network only

mod login_filter;
pub use login_filter::*;

mod pulse_filter;
pub use pulse_filter::*;

mod register_filter;
pub use register_filter::*;

mod robot_game_matches_filter;
pub use robot_game_matches_filter::*;

mod robot_game_tables_filter;
pub use robot_game_tables_filter::*;

mod robot_game_timer_filter;
pub use robot_game_timer_filter::*;

mod robot_game_scoring_filter;
pub use robot_game_scoring_filter::*;

mod tournament_blueprint_filter;
pub use tournament_blueprint_filter::*;

mod tournament_config_filter;
pub use tournament_config_filter::*;

mod tournament_schedule_filter;
pub use tournament_schedule_filter::*;

mod websocket_filter;
pub use websocket_filter::*;

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
impl warp::reject::Reject for UnauthorizedLogin {}

#[derive(Debug)]
pub struct BadRequestWithMessage {
  pub message: String,
}

impl warp::reject::Reject for BadRequestWithMessage {}
