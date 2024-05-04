use log::{error, info, warn};
use echo_tree_infra::EchoTreeRole;

#[derive(Clone)]
pub struct RoleManager {
  db: sled::Db,
  roles: sled::Tree,
}

impl RoleManager {
  pub fn open(db: &sled::Db, metadata_path: String) -> RoleManager {
    let manager = match db.open_tree(format!("{}:roles", metadata_path)) {
      Ok(roles) => roles,
      Err(e) => {
        panic!("open_tree failed: {}", e);
      }
    };

    RoleManager { db: db.clone(), roles: manager }
  }

  pub fn clear(&mut self) {
    match self.roles.clear() {
      Ok(_) => warn!("cleared roles tree"),
      Err(e) => error!("clear failed: {}", e)
    }
  }

  pub fn drop(&mut self) {
    match self.db.drop_tree(self.roles.name()) {
      Ok(_) => warn!("dropped roles tree"),
      Err(e) => error!("drop failed: {}", e)
    }
  }

  pub fn insert_role(&self, role: EchoTreeRole) {
    let key = role.role_id.clone();
    
    let value = match serde_json::to_string(&role) {
      Ok(v) => v,
      Err(e) => {
        error!("to_string failed: {}", e);
        return;
      }
    };

    match self.roles.insert(key.as_bytes(), value.as_bytes()) {
      Ok(_) => {
        info!("inserted role: {}", key);
      },
      Err(e) => error!("insert failed: {}", e)
    }
  }

  pub fn remove_role(&self, role_id: String) {
    match self.roles.remove(role_id.as_bytes()) {
      Ok(_) => {
        info!("removed role: {}", role_id);
      },
      Err(e) => error!("remove failed: {}", e)
    }
  }

  pub fn get_role(&self, role_id: String) -> Option<EchoTreeRole> {
    match self.roles.get(role_id.as_bytes()) {
      Ok(v) => {
        match v {
          Some(v) => {
            match serde_json::from_slice(&v) {
              Ok(v) => Some(v),
              Err(e) => {
                error!("from_slice failed: {}", e);
                None
              }
            }
          },
          None => None
        }
      },
      Err(e) => {
        error!("get failed: {}", e);
        None
      }
    }
  }

  pub fn get_role_read_access(&self, role_id: String) -> Vec<String> {
    if role_id.is_empty() {
      return vec![]
    }

    match self.get_role(role_id.clone()) {
      Some(v) => v.read_echo_trees,
      None => {
        warn!("role not found: {}", role_id);
        vec![]
      }
    }
  }

  pub fn get_role_read_write_access(&self, role_id: String) -> Vec<String> {
    match self.get_role(role_id.clone()) {
      Some(v) => v.read_write_echo_trees,
      None => {
        warn!("role not found: {}", role_id);
        vec![]
      }
    }
  }

  pub fn authenticate_role(&self, role_id: String, password: String) -> bool {
    // get the role if it exists
    let role = match self.get_role(role_id.clone()) {
      Some(v) => v,
      None => {
        warn!("role not found: {}", role_id);
        return false;
      }
    };

    // compare the password
    if role.password == password {
      return true
    } else {
      return false
    }
  }
}

