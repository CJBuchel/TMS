pub const HEADER_X_AUTH_TOKEN: &str = "X-Auth-Token";
pub const HEADER_X_CLIENT_ID: &str = "X-Client-Id";

pub mod pulse_filter;
pub mod auth_token_filter;
pub mod role_permission_filter;
pub mod register_filter;
pub mod websocket_filter;

#[derive(Debug)]
pub struct Unauthorized;
impl warp::reject::Reject for Unauthorized {}