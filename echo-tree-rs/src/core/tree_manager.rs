use std::collections::HashMap;

use echo_tree_infra::server_socket_protocol::{EchoItemEvent, EchoTreeEventTree};

use crate::common::client_echo::ClientEcho;

use super::{EchoTreeServer, SchemaUtil, TreeManager};



#[async_trait::async_trait]
impl TreeManager for EchoTreeServer {
  async fn insert_entry(&self, tree_name: String, key: String, data: String) {
    if !self.validate_data_scheme(tree_name.clone(), data.clone()).await {
      log::error!("Data does not match schema, k: {}, v: {}", key, data);
      return;
    }

    let mut write_db = self.database.write().await;
    match write_db.get_tree_map_mut().await.get_tree_mut(tree_name.clone()) {
      Some(tree) => {
        match tree.insert(key.as_bytes(), data.as_bytes()) {
          Ok(_) => {
            // echo the event
            let echo_event = EchoItemEvent {
              tree_name,
              key,
              data,
            };

            self.clients.read().await.echo_item(echo_event);
          },
          Err(e) => {
            log::error!("Failed to insert k: {}, v: {}, {}", key, data, e);
            return
          }
        }
      },
      None => {
        log::warn!("Tree does not exist, k: {}, v: {}", key, data);
        return;
      }
    };
  }
  
  async fn set_tree(&self, tree_name: String, map: HashMap<String, String>) {
    // Check if the schemas are valid
    for (k, v) in map.iter() {
      if !self.validate_data_scheme(tree_name.clone(), v.clone()).await {
        log::error!("Data does not match schema, k: {}, v: {}", k, v);
        return;
      }
    }

    let mut write_db = self.database.write().await;
    let tree = match write_db.get_tree_map_mut().await.get_tree_mut(tree_name.clone()) {
      Some(tree) => tree,
      None => {
        log::warn!("Tree does not exist: {}", tree_name);
        return;
      }
    };

    if let Err(e) = tree.set_from_hashmap(map) {
      log::error!("Failed to set tree: {}, {}", tree_name, e);
      return;
    }

    if let Ok(map) = tree.get_as_hashmap() {
      // Echo the event
      let echo_event = EchoTreeEventTree {
        tree_name,
        tree: map,
      };

      self.clients.read().await.echo_tree(vec![echo_event]);
    } else {
      log::error!("Failed to get tree as hashmap: {}", tree_name);
    }
  }

  async fn get_entry(&self, tree_name: String, key: String) -> Option<String> {
    let read_db = self.database.read().await;
    if let Some(tree) = read_db.get_tree_map().await.get_tree(tree_name.clone()) {
      if let Ok(data) = tree.get(key.as_bytes()) {
        if let Some(data) = data {
          if let Ok(data) = String::from_utf8(data.to_vec()) {
            return Some(data);
          } else {
            log::error!("Failed to convert data to string: {}", key);
          }
        } else {
          log::warn!("Key does not exist: {}", key);
        }
      } else {
        log::warn!("Failed to get entry: {}", key);
      }
    } else {
      log::warn!("Tree does not exist: {}", tree_name);
    }
    None
  }


  async fn remove_entry(&self, tree_name: String, key: String) -> Option<String> {
    let mut write_db = self.database.write().await;
    if let Some(tree) = write_db.get_tree_map_mut().await.get_tree_mut(tree_name.clone()) {
      if let Ok(data) = tree.remove(key.as_bytes()) {
        if let Some(data) = data {
          if let Ok(data) = String::from_utf8(data.to_vec()) {
            // echo the event
            let echo_event = EchoItemEvent {
              tree_name,
              key: key.clone(),
              data: data.clone(),
            };

            self.clients.read().await.echo_item(echo_event);
            return Some(data);
          } else {
            log::error!("Failed to convert data to string: {}", key);
          }
        } else {
          log::warn!("Key does not exist: {}", key);
        }
      } else {
        log::warn!("Failed to remove entry: {}", key);
      }
    } else {
      log::warn!("Tree does not exist: {}", tree_name);
    }
    None
  }

  async fn get_tree(&self, tree_name: String) -> HashMap<String, String> {
    let read_db = self.database.read().await;
    if let Some(tree) = read_db.get_tree_map().await.get_tree(tree_name.clone()) {
      if let Ok(map) = tree.get_as_hashmap() {
        return map;
      } else {
        log::error!("Failed to get tree as hashmap: {}", tree_name);
      }
    } else {
      log::warn!("Tree does not exist: {}", tree_name);
    }
    HashMap::new()
  }
  
  async fn remove_tree(&self, tree_name: String) {
    let mut write_db = self.database.write().await;
    write_db.remove_tree(tree_name.clone()).await;

    // echo the event
    let echo_event = EchoTreeEventTree {
      tree_name,
      tree: HashMap::new(),
    };

    self.clients.read().await.echo_tree(vec![echo_event]);
  }
}