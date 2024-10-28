use std::{collections::HashMap, net::Ipv4Addr};
use echo_tree_infra::server_socket_protocol::EchoTreeEventTree;
use local_ip_address::local_ip;
use crate::{common::{client_echo::ClientEcho, ClientMap, EchoDB}, db::{backup_manager::BackupManager, db::{Database, DatabaseConfig}}, network::filters};

pub mod schema_util;
pub mod tree_manager;

#[derive(Clone)]
pub struct EchoTreeServerConfig {
  pub db_path: String,
  pub port: u16,
  pub local_ip: String,
  pub addr: Ipv4Addr, // [0,0,0,0] etc...
}

impl Default for EchoTreeServerConfig {
  fn default() -> Self {

    let local_ip: String = match local_ip() {
      Ok(ip) => ip.to_string(),
      Err(e) => {
        log::error!("Failed to get local ip: {}, using 127.0.0.1", e.to_string());
        String::from("127.0.0.1")
      }
    };

    EchoTreeServerConfig {
      db_path: "tree.kvdb".to_string(),
      port: 2121,
      local_ip,
      addr: [127,0,0,1].into(),
    }
  }
}

#[derive(Clone)]
pub struct EchoTreeServer {
  database: EchoDB,
  config: EchoTreeServerConfig,
  clients: ClientMap,
}

#[async_trait::async_trait]
pub trait SchemaUtil {
  async fn add_tree_schema(&self, tree: String, schema: String);
  async fn get_tree_schema(&self, tree: String) -> String;
  async fn validate_data_scheme(&self, tree_name: String, data: String) -> bool;
}

#[async_trait::async_trait]
pub trait TreeManager {
  async fn insert_entry(&self, tree_name: String, key: String, data: String);
  async fn get_entry(&self, tree_name: String, key: String) -> Option<String>;
  async fn remove_entry(&self, tree_name: String, key: String) -> Option<String>;
  async fn set_tree(&self, tree_name: String, tree: HashMap<String, String>);
  async fn get_tree(&self, tree_name: String) -> HashMap<String, String>;
  async fn remove_tree(&self, tree_name: String);
}

impl EchoTreeServer {
  pub fn new(config: EchoTreeServerConfig) -> Self {
    let db_config = DatabaseConfig {
      db_path: config.db_path.clone(),
      metadata_path: "metadata".to_string(),
    };


    let database: EchoDB = std::sync::Arc::new(tokio::sync::RwLock::new(Database::new(db_config)));
    let echo_tree_clients = std::sync::Arc::new(tokio::sync::RwLock::new(std::collections::HashMap::new()));
    EchoTreeServer {
      database,
      config,
      clients: echo_tree_clients,
    }
  }

  pub async fn get_role_manager(&self) -> crate::db::role_manager::RoleManager {
    self.database.read().await.get_role_manager().await.clone()
  }

  pub fn get_clients(&self) -> ClientMap {
    self.clients.clone()
  }

  pub fn get_internal_routes(&self, tls: bool) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
    filters::client_filter::client_filter(self.clients.clone(), self.database.clone(), self.config.local_ip.clone(), tls, self.config.port)
  }

  pub async fn clear(&mut self) {
    let mut db = self.database.write().await;
    db.clear().await;

    // echo change to all clients
    let echo_trees: Vec<EchoTreeEventTree> = db.get_tree_map().await.iter().map(|(tree_name, tree)| {
      EchoTreeEventTree {
        tree_name: tree_name.clone(),
        tree: tree.get_as_hashmap().unwrap_or_default(),
      }
    }).collect();

    self.clients.read().await.echo_tree(echo_trees);
  }

  pub async fn drop(&mut self) {
    let mut db = self.database.write().await;
    db.drop_db().await;
  }

  pub async fn get_backups(&self, backup_path: &str) -> Vec<String> {
    let db = self.database.read().await;
    db.get_backup_file_names(backup_path).await.unwrap_or_default()
  }

  pub async fn backup_db(&self, backup_path: &str, retain_backups: usize) -> Result<(), Box<dyn std::error::Error>> {
    let db = self.database.read().await;
    db.backup_db(backup_path, retain_backups).await
  }

  pub async fn restore_db(&self, backup_path: &str) -> Result<(), Box<dyn std::error::Error>> {
    let mut db = self.database.write().await;
    db.restore_db(backup_path).await?;

    // recalculate checksums
    db.get_tree_map_mut().await.iter_mut().for_each(|(tree_name, tree)| {
      tree.calculate_checksum();
      log::info!("Restored tree [{}] with checksum: {}", tree_name, tree.get_checksum());
    });
    
    // echo change to all clients
    let echo_trees: Vec<EchoTreeEventTree> = db.get_tree_map().await.iter().map(|(tree_name, tree)| {
      EchoTreeEventTree {
        tree_name: tree_name.clone(),
        tree: tree.get_as_hashmap().unwrap_or_default(),
      }
    }).collect();

    self.clients.read().await.echo_tree(echo_trees);
    Ok(())
  }
}