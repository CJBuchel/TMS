use log::{error, trace};
use echo_tree_infra::server_socket_protocol::{EchoTreeServerSocketEvent, EchoTreeServerSocketMessage, StatusResponseEvent};
use tokio::sync::mpsc;
use warp::filters::ws::Message;

type ClientSender = mpsc::UnboundedSender<std::result::Result<Message, warp::Error>>;

/**
 * Client structure,
 * stores information about a client as a temporary connection
 */
#[derive(Clone)]
pub struct Client {
  // security/identification
  pub auth_token: String, // unique authentication for the client. Used to check if the client is authorized to access certain echo trees
  pub role_read_access_trees: Vec<String>, // list of topics/trees the client can access
  pub role_read_write_access_trees: Vec<String>, // list of topics/trees the client can access

  // client information
  pub subscribed_trees: Vec<String>,      // list of topics/trees the client is subscribed to
  pub sender: Option<ClientSender>, // sender channel to this client
}

impl Client {
  pub fn new(
    auth_token: String,
    role_read_access_trees: Vec<String>,
    role_read_write_access_trees: Vec<String>,
    subscribed_trees: Vec<String>,
    sender: Option<ClientSender>,
  ) -> Self {
    Client {
      auth_token,
      role_read_access_trees,
      role_read_write_access_trees,
      subscribed_trees,
      sender,
    }
  }
  // send a message to the client
  pub fn send_message(&self, msg: String) {
    // send message to client
    if let Some(sender) = &self.sender {
      match sender.send(Ok(Message::text(msg.clone()))) {
        Ok(_) => trace!("message sent to client: {}", msg),
        Err(e) => error!("error sending message to client: {}", e),
      }
    }
  }

  pub fn respond(&self, res: StatusResponseEvent) {
    let echo_message = EchoTreeServerSocketMessage {
      auth_token: self.auth_token.clone(),
      message_event: EchoTreeServerSocketEvent::StatusResponseEvent,
      message: Some(serde_json::to_string(&res).unwrap_or_default()),
    };

    // send the message to the client/echo the event
    let json = serde_json::to_string(&echo_message).unwrap_or_default();
    self.send_message(json);
  }

  pub fn update_subscribed_trees(&mut self, new_tree_names: Vec<String>) {
    for tree in new_tree_names {
      if !self.subscribed_trees.contains(&tree) {
        self.subscribed_trees.push(tree);
      }
    }
  }
}