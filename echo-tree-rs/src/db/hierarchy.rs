use std::collections::HashMap;

use log::{error, info, warn};

use super::{managed_tree::ManagedTree, tree_map::TreeMap};


pub struct Hierarchy {
  db: sled::Db,
  tree_hierarchy: ManagedTree,
  metadata_path: String,
}

impl Hierarchy {
  pub fn open(db: &sled::Db, metadata_path: String) -> Hierarchy {
    let tree_hierarchy = match ManagedTree::new(db, format!("{}:hierarchy:trees", metadata_path)) {
      Ok(h) => h,
      Err(e) => {
        error!("ManagedTree::new failed: {}", e);
        panic!("ManagedTree::new failed");
      }
    };

    Hierarchy { 
      db: db.clone(), 
      tree_hierarchy,
      metadata_path 
    }
  }

  pub fn open_tree_map(&self) -> TreeMap {
    let mut tree_map = TreeMap::new(&self.db, self.metadata_path.clone());

    self.tree_hierarchy.iter().for_each(|branch| {
      let (k, _) = branch.unwrap_or_default();
      let k = std::str::from_utf8(&k).unwrap();
      info!("opening tree: {}", k);

      if !k.starts_with(self.metadata_path.as_str()) {
        tree_map.open_tree(k.to_string());
      } else {
        warn!("skipping metadata tree: {}", k);
      }
    });

    tree_map
  }

  pub fn get_trees_as_hashmap(&self) -> Result<HashMap<String, String>, sled::Error> {
    self.tree_hierarchy.get_as_hashmap()
  }

  // clears all the values in the hierarchy tree (does not delete the tree itself)
  pub fn clear(&mut self) {
    match self.tree_hierarchy.clear() {
      Ok(_) => warn!("cleared hierarchy tree"),
      Err(e) => error!("clear failed: {}", e)
    }
  }

  // drops the hierarchy tree, not recoverable unless a new hierarchy tree is created
  pub fn drop(&self) {
    match self.db.drop_tree(self.tree_hierarchy.get_name()) {
      Ok(_) => warn!("dropped hierarchy tree"),
      Err(e) => error!("drop failed: {}", e)
    }
  }

  pub fn insert_tree_schema(&mut self, tree: String, schema: String) {
    // update the hierarchy tree with the new tree
    let schema = schema.to_string();
    match self.tree_hierarchy.insert(tree.as_bytes(), schema.as_bytes()) {
      Ok(_) => info!("inserted schema: {}", tree),
      Err(e) => error!("insert failed: {}", e)
    }
  }

  pub fn get_tree_schema(&self, tree: String) -> String {
    // get the schema from the hierarchy tree
    let schema = match self.tree_hierarchy.get(tree.as_bytes()) {
      Ok(schema) => schema,
      Err(e) => {
        error!("get failed: {}", e);
        panic!("get failed");
      }
    };

    match schema {
      Some(schema) => std::str::from_utf8(&schema).unwrap().to_string(),
      None => "".to_string()
    }
  }

  pub fn remove_tree_schema(&mut self, tree: String) {
    match self.tree_hierarchy.remove(tree.as_bytes()) {
      Ok(_) => info!("removed schema: {}", tree),
      Err(e) => error!("remove failed: {}", e)
    }
  }
}