
// Main steps for server client connection
// Broadcast a udp packet on port 2122 with the server ip and status (tells client where server is)
// Client will then connect to port 2121 on websocket.
// Server will accept the connection and store the UUID in a tabled map
// Client will request public key
// Client will send it's own public key to server (encrypted)
// Server store this public key along with the UUID of the client

// <-> Two way communication pub sub messaging

use tms_server::{db::db::TmsDB, network::network::Network};


#[tokio::main]
async fn main() {
  pretty_env_logger::init();
  println!("Starting TMS Server");

  let mut tms_database = TmsDB::start();
  let mut tms_network = Network::new();

  
  // let data = "A quick brown fox and all";
  // let encrypted_data: Vec<u8> = tms_network.encrypt(data.to_string()).await;
  
  // println!("Encrypted data: {:?}", encrypted_data);
  
  // let decrypted_data = tms_network.decrypt(encrypted_data).await;
  // println!("Decrypted data: {}", decrypted_data);
  
  tms_network.start().await;
}