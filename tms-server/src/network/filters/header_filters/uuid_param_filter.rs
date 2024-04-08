

use warp::Filter;

use crate::network::{filters::{ClientNotFound, HEADER_X_CLIENT_ID}, ClientMap};


pub fn with_uuid_param_filter(clients: ClientMap) -> impl Filter<Extract = (String,), Error = warp::Rejection> + Clone {
  let filter = warp::any().map(move || clients.clone());
  // check for headers, (client and token)
  filter
    .and(warp::header::<String>(HEADER_X_CLIENT_ID))
    .and_then(|clients: ClientMap, client_id: String| async move {
      match clients.read().await.get(&client_id) {
        Some(_) => {
          Ok(client_id)
        },
        None => {
          Err(warp::reject::custom(ClientNotFound))
        }
      }
    })
}