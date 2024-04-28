use tms_infra::EchoTreeRoleAuthenticateRequest;

use crate::common::{ClientMap, EchoDB, ResponseResult};


pub async fn role_auth_handler(client_uuid: String, body: EchoTreeRoleAuthenticateRequest, clients: ClientMap, database: EchoDB) -> ResponseResult<impl warp::reply::Reply> {
  // token authentication should already be handled by the auth_token_filter

  let db = database.read().await;

  // check authentication
  let role_read_trees: Vec<String> = body.roles.iter().flat_map(|(role_id, password)| {
    let read_trees = futures::executor::block_on(async {
      match db.get_role_manager().await.authenticate_role(role_id.clone(), password.clone()) {
        true => {
          let trees = db.get_role_manager().await.get_role_read_access(role_id.clone());
          log::debug!("role found: {}, with read trees: {:?}", role_id.clone(), trees);
          trees
        },
        false => {
          log::info!("role not found: {}", role_id.clone());
          [].to_vec()
        },
      }
    });

    read_trees
  }).collect();

  let role_read_write_trees: Vec<String> = body.roles.iter().flat_map(|(role_id, password)| {
    let read_write_trees = futures::executor::block_on(async {
      match db.get_role_manager().await.authenticate_role(role_id.clone(), password.clone()) {
        true => {
          let trees = db.get_role_manager().await.get_role_read_write_access(role_id.clone());
          log::debug!("role found: {}, with read-write trees: {:?}", role_id.clone(), trees);
          trees
        },
        false => {
          log::info!("role not found: {}", role_id.clone());
          [].to_vec()
        },
      }
    });

    read_write_trees
  }).collect();

  // update client role access
  let mut client = match clients.write().await.get(&client_uuid).cloned() {
    Some(client) => client,
    None => {
      return Err(warp::reject::not_found());
    }
  };

  // add read trees the client doesn't already have
  for tree in role_read_trees.iter() {
    if !client.role_read_access_trees.contains(tree) {
      client.role_read_access_trees.push(tree.clone());
    }
  }

  // add read-write trees the client doesn't already have
  for tree in role_read_write_trees.iter() {
    if !client.role_read_write_access_trees.contains(tree) {
      client.role_read_write_access_trees.push(tree.clone());
    }
  }

  // update client
  clients.write().await.insert(client_uuid, client);
  Ok(warp::reply::reply())
}