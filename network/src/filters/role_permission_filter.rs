use database::SharedDatabase;
use warp::Filter;

use crate::{clients::{client_access::ClientAccess, ClientMap}, filters::FailAuth};

use super::HEADER_X_CLIENT_ID;


pub fn role_permission_filter<'a>(clients: ClientMap, db: SharedDatabase, roles: Vec<&str>) -> impl Filter<Extract = (), Error = warp::Rejection> + Clone + 'a {
  // let filter = warp::any().map(move || clients.clone());

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
          if client.has_role_access(db, roles.clone()).await {
            log::debug!("Client has role access: {}, roles: {}", client_id, roles.join(", "));
            return Ok(());
          } else {
            log::warn!("Client role auth failed: {}, roles: {}", client_id, roles.join(", "));
            return Err(warp::reject::custom(FailAuth));
          }
        },
        None => {
          log::debug!("Client not found: {}", client_id);
          return Err(warp::reject::custom(FailAuth));
        },
      }
    }).untuple_one()
}