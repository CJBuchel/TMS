pub const HEADER_X_AUTH_TOKEN: &str = "X-Auth-Token";
pub const HEADER_X_CLIENT_ID: &str = "X-Client-Id";

mod header_filters; // private for network only
pub mod pulse_filter;
pub mod register_filter;
pub mod login_filter;
pub mod websocket_filter;
pub mod tournament_config_filter;

#[derive(Debug)]
pub struct UnauthorizedToken;
impl warp::reject::Reject for UnauthorizedToken {}

#[derive(Debug)]
pub struct UnauthorizedClient;
impl warp::reject::Reject for UnauthorizedClient {}

#[derive(Debug)]
pub struct ClientNotFound;
impl warp::reject::Reject for ClientNotFound {}

#[derive(Debug)]
pub struct UnauthorizedLogin;
impl warp::reject::Reject for UnauthorizedLogin{}