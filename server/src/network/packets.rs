use std::{sync::{Arc}, collections::HashMap};

use serde::{Serialize, Deserialize};
use tokio::sync::{mpsc, RwLock};
use warp::{ws::Message, Rejection};

#[derive(Debug, Clone)]
pub struct Client {
  pub user_id: usize,
  pub topics: Vec<String>,
  pub sender: Option<mpsc::UnboundedSender<std::result::Result<Message, warp::Error>>>,
}

#[derive(Deserialize, Debug)]
pub struct RegisterRequest {
  pub user_id: usize,
}

#[derive(Serialize, Debug)]
pub struct RegisterResponse {
  pub url: String,
}

#[derive(Deserialize, Debug)]
pub struct Event {
  pub topic: String,
  pub user_id: Option<usize>,
  pub message: String,
}

#[derive(Deserialize, Debug)]
pub struct TopicsRequest {
  pub topics: Vec<String>,
}

pub type Result<T> = std::result::Result<T, Rejection>;
pub type Clients = Arc<RwLock<HashMap<String, Client>>>;