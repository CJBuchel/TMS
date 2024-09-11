use warp::Filter;

use crate::{database::SharedDatabase, network::{handlers::websocket_handler, with_clients, with_db, ClientMap}};

pub fn websocket_filter(clients: ClientMap, db: SharedDatabase) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  warp::path("ws")
    .and(warp::ws())
    .and(warp::path::param())
    .and(with_clients(clients.clone()))
    .and(with_db(db.clone()))
    .and_then(websocket_handler)
}