use tokio::sync::mpsc::UnboundedSender;
use warp::filters::ws::Message;

type ClientSender = UnboundedSender<Result<Message, warp::Error>>;

#[derive(Clone)]
pub struct Client {
  pub auth_token: String,           // auth token to match against
  pub user_id: String,              // user id to match to in the db. (used to get roles and access)
  pub sender: Option<ClientSender>, // sender to send messages to the client
}

impl Client {
  pub fn new(auth_token: String, user_id: String, sender: Option<ClientSender>) -> Self {
    Self { auth_token, user_id, sender }
  }

  pub fn send_message(&self, msg: String) {
    // send message to client
    if let Some(sender) = &self.sender {
      match sender.send(Ok(Message::text(msg))) {
        Ok(_) => log::trace!("Message sent to client"),
        Err(e) => log::error!("Error sending message to client: {:?}", e),
      }
    }
  }
}
