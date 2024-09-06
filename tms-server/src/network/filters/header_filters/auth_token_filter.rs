use warp::Filter;

use crate::network::{
  filters::{ClientNotFound, UnauthorizedToken, HEADER_X_AUTH_TOKEN, HEADER_X_CLIENT_ID},
  ClientMap,
};

pub fn check_auth_token_filter(clients: ClientMap) -> impl Filter<Extract = (), Error = warp::Rejection> + Clone {
  let filter = warp::any().map(move || clients.clone());
  // check for headers, (client and token)
  filter
    .and(warp::header::<String>(HEADER_X_CLIENT_ID))
    .and(warp::header::<String>(HEADER_X_AUTH_TOKEN))
    .and_then(|clients: ClientMap, client_id: String, auth_token: String| async move {
      // check auth token matches
      match clients.read().await.get(&client_id) {
        Some(client) => {
          if client.auth_token == auth_token {
            log::debug!("Client authorized: {}", client_id);
            return Ok(());
          } else {
            log::warn!("Client auth failed: {}", client_id);
            Err(warp::reject::custom(UnauthorizedToken))
          }
        }
        None => {
          log::debug!("Client not found: {}", client_id);
          Err(warp::reject::custom(ClientNotFound))
        }
      }
    })
    .untuple_one()
}
