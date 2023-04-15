use crate::{schemas::SocketMessage, db::db::TmsDB};


pub mod teams;

// dispatch requests to each of their respective requests to the server/db
pub fn request_controller(message: SocketMessage, db: TmsDB) {
  match message.topic.as_str() {
    _ => println!("Unknown Topic {:?}", message.topic),
  }
}