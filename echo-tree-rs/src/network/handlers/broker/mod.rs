// use log::warn;
use tms_infra::client_socket_protocol::{EchoTreeClientSocketEvent, EchoTreeClientSocketMessage};

use crate::common::{ClientMap, EchoDB};

mod subscribe_broker;
mod unsubscribe_broker;
mod checksum_broker;
mod insert_broker;
mod get_broker;
mod delete_broker;
mod set_tree_broker;
mod get_tree_broker;

/**
 * Broker for the echo message
 * Breakout for each echo message method
 */
pub async fn echo_message_broker(uuid:String, msg: EchoTreeClientSocketMessage, clients: &ClientMap, db: &EchoDB) {
  match msg.message_event {
    // option events
    EchoTreeClientSocketEvent::ChecksumEvent => {
      checksum_broker::checksum_broker(uuid, msg, clients, db).await;
    },

    // subscription events
    EchoTreeClientSocketEvent::SubscribeEvent => {
      subscribe_broker::subscribe_broker(uuid, msg, clients).await;
    },
    EchoTreeClientSocketEvent::UnsubscribeEvent => {
      unsubscribe_broker::unsubscribe_broker(uuid, msg, clients).await;
    },

    // data item events
    EchoTreeClientSocketEvent::InsertEvent => {
      insert_broker::insert_broker(uuid, msg, clients, db).await;
    },
    EchoTreeClientSocketEvent::GetEvent => {
      get_broker::get_broker(uuid, msg, clients, db).await;
    },
    EchoTreeClientSocketEvent::DeleteEvent => {
      delete_broker::delete_broker(uuid, msg, clients, db).await;
    },


    // data tree events
    EchoTreeClientSocketEvent::SetTreeEvent => {
      set_tree_broker::set_tree_broker(uuid, msg, clients, db).await;
    },
    EchoTreeClientSocketEvent::GetTreeEvent => {
      get_tree_broker::get_tree_broker(uuid, msg, clients, db).await;
    },

    // unhandled (for future issues)
    // _ => {
    //   warn!("{}: unhandled method", uuid);
    // },
  }
}