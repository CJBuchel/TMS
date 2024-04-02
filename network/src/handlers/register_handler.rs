use database::SharedDatabase;
use network_schema::{RegisterRequest, RegisterResponse};
use rand::Rng;

use database::*;

use crate::clients::{client::Client, ClientMap, ResponseResult};

fn generate_auth_token() -> String {
  rand::thread_rng().sample_iter(&rand::distributions::Alphanumeric).take(32).map(char::from).collect()
}

async fn register_client(uuid: String, auth_token: String, user_id: String, clients: ClientMap) {
  let mut write_clients = clients.write().await;
  write_clients.insert(uuid.clone(), Client::new(
    auth_token,
    user_id,
    None,
  ));
}

pub async fn register_handler(body: RegisterRequest, clients: ClientMap, db: SharedDatabase) -> ResponseResult<impl warp::reply::Reply> {
  let uuid = uuid::Uuid::new_v4().to_string();
  let auth_token = generate_auth_token();

  let read_db = db.read().await;

  // if username/password
  if let (Some(username), Some(password)) = (body.username, body.password) {
    let result = read_db.get_inner().read().await.get_tree(":users".to_string()).await.iter().find_map(|(id, user)| {
      let user = User::get_from_schema(user);
      if user.username == username {
        Some((id.clone(), user))
      } else {
        None
      }
    });

    if let Some((id, user)) = result {
      if user.password == password {
        // create client
        register_client(uuid.clone(), auth_token.clone(), id, clients).await;
        return Ok(warp::reply::json(&RegisterResponse {
          auth_token,
          uuid,
          url: "@TODO".to_string(),
        }));
      }
    }
  
  // register client normally without username/password
  } else {
    register_client(uuid.clone(), auth_token.clone(), "".to_string(), clients).await;
    return Ok(warp::reply::json(&RegisterResponse {
      auth_token,
      uuid,
      url: "@TODO".to_string(),
    }));
  }


  Err(warp::reject::reject())
}