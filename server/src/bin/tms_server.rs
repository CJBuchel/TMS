
// Main steps for server client connection
// Broadcast a mDNS on port 5353 with the server ip and status (tells client where server is)
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
use tms_server::{network::{mdns_broadcaster::MDNSBroadcaster, ws_routes::TmsWebsocket, http_routes::TmsHttpServer}, db::{db::TmsDB, backup_service::BackupService, backup_monitor::BackupMonitor}, event_service::TmsEventService};
use tms_utils::{new_clients_map, security::Security};

pub struct ServerConfig {
  db_name: String,
  http_port: u16,
  ws_port: u16,
  mdns_port: u16,
  mdns_name: String
}

pub struct TmsServer {
  config: ServerConfig,
}

impl TmsServer {
  pub fn new(config: ServerConfig) -> Self {
    Self { 
      config
    }
  }

  pub async fn start(&self) {
    info!("Starting TMS");

    let rsa = Security::new(4096);
    let clients = new_clients_map();
    
    // DB Services
    let tms_db = std::sync::Arc::new(
      TmsDB::start(String::from(self.config.db_name.clone()))
    );

    let tms_db_backup_service = std::sync::Arc::new(
      BackupService::new(self.config.db_name.clone(), tms_db.clone())
    );

    let tms_db_backup_monitor = std::sync::Arc::new(
      BackupMonitor::new(tms_db_backup_service.clone())
    );

    // Event Services
    let tms_event_service = std::sync::Arc::new(tokio::sync::RwLock::new(TmsEventService::new(tms_db.clone(), clients.clone())));
    let m_dns = MDNSBroadcaster::new(self.config.mdns_port, self.config.mdns_name.clone());
    let tms_ws = TmsWebsocket::new(tms_event_service.clone(), rsa.clone(), clients.clone(), self.config.ws_port);
    let tms_http = TmsHttpServer::new(
      tms_event_service.to_owned(), 
      tms_db_backup_service.clone(), 
      tms_db.to_owned(), 
      rsa.clone(), 
      clients.to_owned(), 
      self.config.http_port, 
      self.config.ws_port
    );


    tokio::spawn(async move {
      m_dns.start().await;
    });

    tokio::spawn(async move {
      tms_ws.start().await
    });

    tokio::spawn(async move {
      tms_db_backup_monitor.start().await;
    });

    let _ = tms_http.start().await.launch().await;
  }
}


#[tokio::main]
async fn main() {
  env::set_var("RUST_LOG", "warn"); // temporary while the server is being built
  pretty_env_logger::init();
  
  let main_server = TmsServer::new(ServerConfig { 
    db_name: String::from("tms.kvdb"),
    http_port: 2121, // 2121
    ws_port: 2122, // 2122
    mdns_port: 5353, // 5353
    mdns_name: "_mdns-tms-server".to_string()
  });

  main_server.start().await;
}