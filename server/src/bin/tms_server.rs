
// Main steps for server client connection
// Broadcast a udp packet on port 2122 with the server ip and status (tells client where server is)
// Client will then connect to port 2121 on websocket.
// Server will accept the connection and store the UUID in a tabled map
// Client will request public key
// Client will send it's own public key to server (encrypted)
// Server store this public key along with the UUID of the client

// <-> Two way communication pub sub messaging

use tms_server::{db::db::TmsDB};


#[tokio::main]
async fn main() {
  pretty_env_logger::init();
  println!("Starting TMS Server");

  let tms_database = TmsDB::start();

  // @todo start up http routes
  // @todo start up ws routes

  // let tms_routes = Router::new(tms_database);
  
  // tms_routes.start().await;
}