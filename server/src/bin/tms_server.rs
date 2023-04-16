
// Main steps for server client connection
// Broadcast a mDNS on port 2123 with the server ip and status (tells client where server is)
// Client will then connect to port 2121 on http request to register itself with client user id and client public key.
// Server will accept the connection and store the UUID in a tabled map
// Server responds with the generated uuid and server public key for encrypted messaging
// Client requests data and can publish messages to pub sub using the /publish route
// Clients can subscribe to message events on the websocket port 2122

// Example of this process (Timer)
// Client requests timer start signal via http request (port 2121)
// Server processes the request and starts the timer server side.
// The server decides whether to send a copy of this message through websocket (2122) to all subscribed clients (except the origin sender, filter through uuid)
// The server will constantly be sending Time events through ws (2122) as the timer counts down, will send to all subscribed clients.

use std::env;

use log::info;
use tms_server::{db::db::TmsDB, network::{security::Security, clients::{Clients, new_clients_map}, mdns_broadcaster::MDNSBroadcaster, ws_routes::TmsWebsocket, http_routes::TmsHttpServer}};

pub struct ServerConfig {
  http_port: u16,
  ws_port: u16,
  mdns_port: u16,
  mdns_name: String
}

pub struct TmsServer {
  tms_database: TmsDB,
  mDNS: MDNSBroadcaster,
  tmsWS: TmsWebsocket,
  tmsHttp: TmsHttpServer,
}

impl TmsServer {
  pub fn new(config: ServerConfig) -> Self {

    let rsa = Security::new();
    let clients = new_clients_map();

    Self { 
      tms_database: TmsDB::start(),
      mDNS: MDNSBroadcaster::new(config.mdns_port, config.mdns_name),
      tmsWS: TmsWebsocket::new(rsa.clone(), clients.clone(), config.ws_port),
      tmsHttp: TmsHttpServer::new(rsa.clone(), clients.clone(), config.http_port)
    }
  }

  pub async fn start(&self) {
    info!("Starting TMS");
    let _ = self.mDNS.start();
    let _ = self.tmsWS.start();
    let _ = self.tmsHttp.start().await.launch().await;
  }
}


#[tokio::main]
async fn main() {
  env::set_var("RUST_LOG", "debug"); // temporary while the server is being built
  pretty_env_logger::init();
  
  let main_server = TmsServer::new(ServerConfig { 
    http_port: 2121,
    ws_port: 2122,
    mdns_port: 2123,
    mdns_name: "tms_mdns_broadcast_".to_string()
  });

  main_server.start().await;
}
