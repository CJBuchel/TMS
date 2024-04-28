use tms_infra::LoginRequest;

use crate::{database::*, network::*};


pub async fn login_handler(body: LoginRequest, uuid: String, clients: ClientMap, db: SharedDatabase) -> ResponseResult<impl warp::reply::Reply> {
  match db.read().await.get_user_by_username(body.username.clone()).await {
    Some((user_id, user)) => {
      if user.password == body.password {
        // success, modify client user id
        let mut write_clients = clients.write().await;
        write_clients.get_mut(&uuid).unwrap().user_id = user_id.clone();
        
        // respond with login response and roles
        log::info!("User `{}` logged in", body.username);
        return Ok(warp::reply::json(&LoginResponse {
          roles: user.roles,
        }));
      } else {
        log::error!("Login attempt failed for `{}`, reason: BAD PASSWORD: `{}`", body.username, body.password);
        Err(warp::reject::custom(UnauthorizedLogin))
      }
    }
    None => {
      log::error!("Login attempt failed for `{}`, reason: USER NOT FOUND", body.username);
      Err(warp::reject::custom(UnauthorizedLogin))
    }
  }
}

pub async fn logout_handler(uuid: String, clients: ClientMap) -> ResponseResult<impl warp::reply::Reply> {
  log::info!("Logout request for client {}", uuid);

  // get client
  let mut write_clients = clients.write().await;
  let client = write_clients.get_mut(&uuid).ok_or_else(|| warp::reject::custom(ClientNotFound))?;
  client.user_id.clear();

  Ok(warp::http::StatusCode::OK)
}