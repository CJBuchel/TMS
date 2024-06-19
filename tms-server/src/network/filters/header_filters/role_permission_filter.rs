use warp::Filter;
use crate::{database::SharedDatabase, network::{client_access::{ClientAccess, ClientAccessResult}, filters::{ClientNotFound, UnauthorizedClient, HEADER_X_CLIENT_ID}, AuthenticationRequired, ClientMap}};


pub fn role_permission_filter(clients: ClientMap, db: SharedDatabase, roles: Vec<&str>) -> impl Filter<Extract = (), Error = warp::Rejection> + Clone {
  let roles: Vec<String> = roles.iter().map(|x| x.to_string()).collect();

  warp::any()
    .map(move || clients.clone())
    .and(warp::any().map(move || db.clone()))
    .and(warp::any().map(move || roles.clone()))
    .and(warp::header::<String>(HEADER_X_CLIENT_ID))
    .and_then(move |clients: ClientMap, db: SharedDatabase, roles: Vec<String>, client_id: String| async move {
      // check if client exists
      match clients.read().await.get(&client_id) {
        Some(client) => {
          match client.has_role_access(db, roles.clone()).await {
            ClientAccessResult::Success => {
              log::debug!("Client has role access: {}, roles: {}", client_id, roles.join(", "));
              return Ok(());
            },

            ClientAccessResult::Unauthorized => {
              log::warn!("Client role auth failed: {}, roles: {}", client_id, roles.join(", "));
              return Err(warp::reject::custom(UnauthorizedClient));
            },

            ClientAccessResult::AuthenticationRequired => {
              log::warn!("Client auth required: {}", client_id);
              return Err(warp::reject::custom(AuthenticationRequired));
            },
          }
        },
        None => {
          log::debug!("Client not found: {}", client_id);
          return Err(warp::reject::custom(ClientNotFound));
        },
      }
    }).untuple_one()
}