use std::collections::HashMap;

use log::{error, warn};

use super::managed_tree::ManagedTree;


pub struct TreeMap {
  db: sled::Db,
  tree_map: HashMap<String, ManagedTree>,
  metadata_path: String,
}

impl TreeMap {
  pub fn new(db: &sled::Db, metadata_path: String) -> TreeMap {
    TreeMap {
      db: db.clone(),
      tree_map: HashMap::new(),
      metadata_path,
    }
  }

  // clears all the values in every tree (does not delete the trees themselves)
  pub fn clear(&mut self) {
    // clear the trees in the map
    warn!("Clearing Trees");
    self.tree_map.iter_mut().for_each(|(k, v)| {
      match v.clear() {
        Ok(_) => warn!("Cleared Tree: {}", k),
        Err(e) => {
          error!("Clear Failed: {}", e);
        }
      }
    });
  }

  // drops all the trees, not recoverable unless new trees are created
  pub fn drop(&mut self) {
    // drop the trees in the map
    for (k, v) in self.tree_map.iter_mut() {
      match v.drop() {
        Ok(_) => warn!("dropped tree: {}", k),
        Err(e) => error!("drop_tree failed for {}: {}", k, e)
      };
    }

    self.tree_map.clear();
  }


  pub fn open_tree(&mut self, tree: String) {
    if self.tree_map.contains_key(&tree) {
      warn!("tree already exists: {}", tree);
      return
    }

    if tree.starts_with(self.metadata_path.as_str()) {
      warn!("metadata trees are forbidden: {}", tree);
      return
    }

    let managed_tree = match ManagedTree::new(&self.db, tree.clone()) {
      Ok(t) => t,
      Err(e) => {
        error!("ManagedTree::new failed for {}: {}", tree, e);
        return
      }
    };

    self.tree_map.insert(tree, managed_tree);
  }

  pub fn remove_tree(&mut self, tree: String) -> Option<ManagedTree> {
    if !self.tree_map.contains_key(&tree) {
      warn!("tree does not exist: {}", tree);
      return None
    }

    if tree.starts_with(self.metadata_path.as_str()) {
      warn!("metadata trees are forbidden: {}", tree);
      return None
    }

    let managed_tree = match self.tree_map.get_mut(&tree) {
      Some(t) => t,
      None => {
        warn!("tree not found: {}", tree);
        return None
      }
    };

    let cloned_tree = managed_tree.clone();
    match managed_tree.drop() {
      Ok(_) => (),
      Err(e) => {
        error!("drop_tree failed for {}: {}", tree, e);
        return None
      }
    };
    self.tree_map.remove(&tree);

    Some(cloned_tree)
  }

  pub fn get_tree(&self, tree: String) -> Option<&ManagedTree> {
    self.tree_map.get(&tree)
  }

  pub fn get_tree_mut(&mut self, tree: String) -> Option<&mut ManagedTree> {
    self.tree_map.get_mut(&tree)
  }

  pub fn iter(&self) -> std::collections::hash_map::Iter<String, ManagedTree> {
    self.tree_map.iter()
  }

  pub fn iter_mut(&mut self) -> std::collections::hash_map::IterMut<String, ManagedTree> {
    self.tree_map.iter_mut()
  }
}