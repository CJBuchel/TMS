use clients::client::Client;
use rand::Rng;
use tms_infra::*;
use crate::{database::*, network::*};


fn generate_auth_token() -> String {
  rand::thread_rng().sample_iter(&rand::distributions::Alphanumeric).take(32).map(char::from).collect()
}

async fn register_client(uuid: String, auth_token: String, user_id: String, clients: ClientMap) {
  let mut write_clients = clients.write().await;
  write_clients.insert(uuid.clone(), Client::new(auth_token, user_id, None));
  log::debug!("Client registered: {}", uuid);
}

pub async fn register_handler(body: RegisterRequest, clients: ClientMap, db: SharedDatabase, local_ip: String, tls: bool, port: u16, remote_addr: Option<std::net::SocketAddr>) -> ResponseResult<impl warp::reply::Reply> {
  let uuid = uuid::Uuid::new_v4().to_string();
  let auth_token = generate_auth_token();

  // check if client is loopback connection (localhost)
  let ip = if let Some(remote_addr) = remote_addr {
    if remote_addr.ip().is_loopback() {
      "localhost".to_string()
    } else {
      local_ip
    }
  } else {
    local_ip
  };

  let url = format!("{}://{}:{}/ws/{}", if tls { "wss" } else { "ws" }, ip, port, uuid);

  // read db access
  let read_db = db.read().await;

  // if username/password
  if let (Some(username), Some(password)) = (body.username, body.password) {
    let result = read_db.get_inner().read().await.get_tree(":users".to_string()).await.iter().find_map(|(id, user)| {
      let user = User::from_json(user);
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
          uuid: uuid.clone(),
          url,
        }));
      }
    }

  }
  
  // register client normally without username/password
  register_client(uuid.clone(), auth_token.clone(), "".to_string(), clients).await;
  return Ok(warp::reply::json(&RegisterResponse { auth_token, uuid, url }));
}

pub async fn unregister_handler(uuid: String, clients: ClientMap) -> ResponseResult<impl warp::reply::Reply> {
  let mut write_clients = clients.write().await;
  write_clients.remove(&uuid);
  log::debug!("Client unregistered: {}", uuid);
  Ok(warp::http::StatusCode::OK)
}