use echo_tree_rs::echo_tree_server::{EchoTreeServer, EchoTreeServerConfig};


#[tokio::main]
async fn main() {

  let config = EchoTreeServerConfig {
    db_path: "tree.kvdb".to_string(),
    port: 2121,
    addr: [127,0,0,1].into(),
  };

  let server = EchoTreeServer::new(config);

  
}