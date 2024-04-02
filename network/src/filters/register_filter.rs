use database::SharedDatabase;
use warp::Filter;

use crate::{clients::{with_clients, with_db, ClientMap}, handlers::register_handler};


pub fn register_filter(clients: ClientMap, db: SharedDatabase) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  warp::path("register")
    .and(warp::post())
    .and(warp::body::json())
    .and(with_clients(clients.clone()))
    .and(with_db(db.clone()))
    .and_then(register_handler)
}