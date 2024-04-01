pub const HEADER_X_AUTH_TOKEN: &str = "X-Auth-Token";
pub const HEADER_X_CLIENT_ID: &str = "X-Client-Id";

pub mod auth_token_filter;
pub mod role_permission_filter;
pub mod register_filter;

#[derive(Debug)]
pub struct FailAuth;
impl warp::reject::Reject for FailAuth {}