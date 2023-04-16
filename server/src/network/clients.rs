use std::{sync::{RwLock, Arc}, collections::HashMap, hash::Hash};

use tokio::sync::mpsc;
use warp::{ws::Message, Rejection};

#[derive(Clone)]
pub struct Client {
  pub user_id: String, // the uuid for the client (client generated)
  pub key: String, // public key for this client
  pub ws_sender: Option<mpsc::UnboundedSender<std::result::Result<Message, warp::Error>>> // socket sender used for dispatching messages
}

pub type ClientResult<T> = std::result::Result<T, Rejection>;
pub type Clients = Arc<RwLock<HashMap<String, Client>>>;

pub fn new_clients_map() -> Clients {
  return Arc::new(RwLock::new(HashMap::new()));
}