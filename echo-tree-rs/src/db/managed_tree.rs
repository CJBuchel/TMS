use std::collections::HashMap;

use sled::IVec;


#[derive(Debug, Clone)]
pub struct ManagedTree {
  db: sled::Db,
  tree_name: String, // e.g :public:teams
  tree: sled::Tree,
  checksum: u32,
}

impl ManagedTree {
  pub fn new(db: &sled::Db, tree_name: String) -> Result<Self, sled::Error> {
    if tree_name.contains('/') {
      log::error!("tree name cannot contain '/' for {}, try using ':' instead", tree_name);
      return Err(sled::Error::Unsupported("tree name cannot contain /".to_string()));
    }

    let tree = match db.open_tree(tree_name.clone()) {
      Ok(t) => t,
      Err(e) => {
        log::error!("open_tree failed for {}: {}", tree_name, e);
        return Err(e);
      }
    };


    let checksum = match tree.checksum() {
      Ok(c) => c,
      Err(e) => {
        log::error!("checksum failed for {}: {}", tree_name, e);
        0
      }
    };

    Ok(ManagedTree { db: db.clone(), tree_name, tree, checksum })
  }

  fn checksum(&mut self) {
    match self.tree.checksum() {
      Ok(c) => self.checksum = {
        log::debug!("{}: checksum: {}", self.tree_name, c);
        c
      },
      Err(e) => log::error!("checksum failed for {}: {}", self.tree_name, e)
    }
  }

  pub fn drop(&mut self) -> Result<bool, sled::Error> {
    self.db.drop_tree(self.tree_name.as_str())
  }

  pub fn get_checksum(&self) -> u32 {
    self.checksum
  }

  pub fn insert(&mut self, key: &[u8], value: &[u8]) -> Result<Option<IVec>, sled::Error> {
    let result = self.tree.insert(key, value);

    // checksum after each time
    if result.is_ok() {
      self.checksum();
    }

    result
  }

  pub fn get(&self, key: &[u8]) -> Result<Option<IVec>, sled::Error> {
    self.tree.get(key)
  }

  pub fn remove(&mut self, key: &[u8]) -> Result<Option<IVec>, sled::Error> {
    let result = self.tree.remove(key);

    // checksum after each time
    if result.is_ok() {
      self.checksum();
    }

    result
  }

  pub fn clear(&mut self) -> Result<(), sled::Error> {
    let result = self.tree.clear();

    // checksum after each time
    if result.is_ok() {
      log::debug!("cleared tree: {}", self.tree_name);
      self.checksum();
    }

    result
  }

  pub fn iter(&self) -> sled::Iter {
    self.tree.iter()
  }

  pub fn set_from_hashmap(&mut self, map: HashMap<String, String>) -> Result<(), sled::Error> {
    self.clear()?;

    for (k, v) in map.iter() {
      self.insert(k.as_bytes(), v.as_bytes())?;
    }

    // recalculate the checksum
    self.checksum();

    Ok(())
  }

  pub fn get_as_hashmap(&self) -> Result<HashMap<String, String>, sled::Error> {
    let mut map: HashMap<String, String> = HashMap::new();

    for item in self.tree.iter() {
      let (k, v) = match item {
        Ok((k, v)) => (k, v),
        Err(e) => {
          log::error!("iter failed: {}", e);
          return Err(e);
        }
      };

      let key_str = String::from_utf8(k.to_vec()).unwrap_or_default();
      let value_str = String::from_utf8(v.to_vec()).unwrap_or_default();
      map.insert(key_str, value_str);
    }

    Ok(map)
  }

  pub fn get_name(&self) -> String {
    self.tree_name.clone()
  }
}