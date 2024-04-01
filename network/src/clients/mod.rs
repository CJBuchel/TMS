use self::client::Client;

pub mod client_access;
pub mod client;

pub type ClientHashMap = std::collections::HashMap<String, Client>;
pub type ClientMap = std::sync::Arc<tokio::sync::RwLock<ClientHashMap>>;

pub type ResponseResult<T> = std::result::Result<T, warp::reject::Rejection>;