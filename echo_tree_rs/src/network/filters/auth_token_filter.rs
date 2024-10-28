use log::{debug, warn};
use warp::Filter;

use crate::common::ClientMap;

use super::{HEADER_X_AUTH_TOKEN, HEADER_X_CLIENT_ID};

pub fn check_auth(clients: ClientMap) -> impl Filter<Extract = (), Error = warp::Rejection> + Clone {
  let filter = warp::any().map(move || clients.clone());

  filter
    .and(warp::header::<String>(HEADER_X_CLIENT_ID))
    .and(warp::header::<String>(HEADER_X_AUTH_TOKEN))
    .and_then(|clients: ClientMap, client_id: String, auth_token: String| async move {
      // check auth token
      match clients.read().await.get(&client_id) {
        Some(client) => {
          if client.auth_token == auth_token {
            Ok(())
          } else {
            warn!("client failed auth: {}", client_id);
            Err(warp::reject::custom(FailAuth))
          }
        }
        None => {
          debug!("client not found: {}", client_id);
          Err(warp::reject::custom(FailAuth))
        }
      }
    })
    .untuple_one()
}

#[derive(Debug)]
pub struct FailAuth;
impl warp::reject::Reject for FailAuth {}