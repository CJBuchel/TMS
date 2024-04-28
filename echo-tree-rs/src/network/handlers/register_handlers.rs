use log::{debug, error};
use tms_infra::{EchoTreeRegisterRequest, EchoTreeRegisterResponse};
use rand::Rng;
use crate::common::{client::Client, ClientMap, EchoDB, ResponseResult};

async fn register_client(uuid: String, auth_token:String, subscribed_trees: Vec<String>, role_read_trees: Vec<String>, role_read_write_trees: Vec<String>, clients: ClientMap) {
  debug!("registering client with uuid: {}", uuid);
  clients.write().await.insert(uuid, Client::new(auth_token, role_read_trees, role_read_write_trees, subscribed_trees, None));
}

fn generate_auth_token() -> String {
  rand::thread_rng().sample_iter(&rand::distributions::Alphanumeric).take(30).map(char::from).collect()
}

pub async fn register_handler(body: EchoTreeRegisterRequest, clients: ClientMap, db: EchoDB, local_ip: String, tls: bool, port: u16, remote_addr: Option<std::net::SocketAddr>) -> ResponseResult<impl warp::reply::Reply> {
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

  let url = format!("{}://{}:{}/echo_tree/ws/{}", if tls { "wss" } else { "ws" }, ip, port, uuid);

  let db = db.read().await;

  // let role_read_trees: Vec<String>;
  // let role_read_write_trees: Vec<String>;
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

  register_client(uuid.clone(), auth_token.clone(), body.echo_trees, role_read_trees, role_read_write_trees, clients).await;

  let hierarchy = match db.get_hierarchy().await.get_trees_as_hashmap() {
    Ok(h) => h,
    Err(e) => {
      error!("get_as_hashmap failed: {}", e);
      std::collections::HashMap::new()
    }
  };

  Ok(
    warp::reply::json(&EchoTreeRegisterResponse {
      uuid, // used to connect to the websocket, i.e ws://localhost:2121/ws/{uuid}
      url,
      auth_token,
      hierarchy,
    })
  )
}

pub async fn unregister_handler(client_uuid: String, clients: ClientMap) -> ResponseResult<impl warp::reply::Reply> {
  debug!("un-registering client with uuid: {}", client_uuid);
  clients.write().await.remove(&client_uuid);
  Ok(warp::http::StatusCode::OK)
}