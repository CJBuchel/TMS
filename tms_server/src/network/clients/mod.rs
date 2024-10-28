mod client_access;
pub use client_access::*;

mod client_publish;
pub use client_publish::*;

mod client;
pub use client::*;

mod events;
pub use events::*;

pub type ClientHashMap = std::collections::HashMap<String, Client>;
pub type ClientMap = std::sync::Arc<tokio::sync::RwLock<ClientHashMap>>;


pub type ResponseResult<T> = std::result::Result<T, warp::reject::Rejection>;