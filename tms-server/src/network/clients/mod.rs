use crate::database::SharedDatabase;

use self::client::Client;
use warp::Filter;
pub mod client_access;
pub mod client_publish;
pub mod client;

pub type ClientHashMap = std::collections::HashMap<String, Client>;
pub type ClientMap = std::sync::Arc<tokio::sync::RwLock<ClientHashMap>>;


pub type ResponseResult<T> = std::result::Result<T, warp::reject::Rejection>;

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