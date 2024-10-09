use crate::db::db::Database;
use warp::Filter;

use self::client::Client;

pub mod client;
pub mod client_access;
pub mod client_echo;

pub type ClientHashMap = std::collections::HashMap<String, Client>; // client id, client
pub type ClientMap = std::sync::Arc<tokio::sync::RwLock<ClientHashMap>>;

pub type ResponseResult<T> = std::result::Result<T, warp::reject::Rejection>;
pub type EchoDB = std::sync::Arc<tokio::sync::RwLock<Database>>;

pub fn with_clients(
  clients: ClientMap,
) -> impl warp::Filter<Extract = (ClientMap,), Error = std::convert::Infallible> + Clone {
  warp::any().map(move || clients.clone())
}

pub fn with_db(db: EchoDB) -> impl warp::Filter<Extract = (EchoDB,), Error = std::convert::Infallible> + Clone {
  warp::any().map(move || db.clone())
}