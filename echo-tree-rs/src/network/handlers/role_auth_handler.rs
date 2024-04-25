use tms_infra::EchoTreeRoleAuthenticateRequest;

use crate::common::{ClientMap, EchoDB, ResponseResult};


pub async fn role_auth_handler(client_uuid: String, body: EchoTreeRoleAuthenticateRequest, clients: ClientMap, database: EchoDB) -> ResponseResult<impl warp::reply::Reply> {
  // token authentication should already be handled by the auth_token_filter

  // handle new role authentication
  let role_id = body.role_id;
  let password = body.password;

  let db = database.read().await;

  // check authentication
  let role_read_trees = match db.get_role_manager().await.authenticate_role(role_id.clone(), password.clone()) {
    true => db.get_role_manager().await.get_role_read_access(role_id.clone()),
    false => {
      return Err(warp::reject::reject());
    },
  };

  let role_read_write_trees = match db.get_role_manager().await.authenticate_role(role_id.clone(), password) {
    true => db.get_role_manager().await.get_role_read_write_access(role_id),
    false => {
      return Err(warp::reject::reject());
    },
  };

  // update client role access
  let mut client = match clients.write().await.get(&client_uuid).cloned() {
    Some(client) => client,
    None => {
      return Err(warp::reject::not_found());
    }
  };

  client.role_read_access_trees = role_read_trees;
  client.role_read_write_access_trees = role_read_write_trees;
  clients.write().await.insert(client_uuid, client);

  Ok(warp::reply::reply())
}