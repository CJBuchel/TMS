use super::{role_manager::RoleManager, hierarchy::Hierarchy, tree_map::TreeMap};

pub struct DatabaseConfig {
  pub db_path: String,
  pub metadata_path: String,
}

impl Default for DatabaseConfig {
  fn default() -> Self {
    DatabaseConfig {
      db_path: "tree.kvdb".to_string(),
      metadata_path: "metadata".to_string(),
    }
  }
}

pub struct Database {
  hierarchy: Hierarchy,
  trees: TreeMap,
  role_manager: RoleManager,
  db: sled::Db,
  pub config: DatabaseConfig,
}

impl Database {
  pub fn new(config: DatabaseConfig) -> Database {
    let db: sled::Db =
      sled::open(config.db_path.clone()).expect(format!("open failed for {}", config.db_path).as_str());
      let hierarchy = Hierarchy::open(&db, config.metadata_path.clone());
      let role_manager = RoleManager::open(&db, config.metadata_path.clone());
      
      // create the maps from the hierarchy
      let trees = hierarchy.open_tree_map();

    Database {
      hierarchy,
      trees,
      role_manager,
      config,
      db,
    }
  }

  pub async fn get_inner_db(&self) -> &sled::Db {
    &self.db
  }

  pub async fn get_hierarchy(&self) -> &Hierarchy {
    &self.hierarchy
  }

  pub async fn get_tree_map(&self) -> &TreeMap {
    &self.trees
  }

  pub async fn get_tree_map_mut(&mut self) -> &mut TreeMap {
    &mut self.trees
  }

  pub async fn get_role_manager(&self) -> &RoleManager {
    &self.role_manager
  }

  // clears all the values in every tree (does not delete the trees themselves)
  pub async fn clear(&mut self) {
    self.trees.clear();
    self.hierarchy.clear();
    self.role_manager.clear();
  }

  // drops all the trees, not recoverable unless new hierarchy is created and new trees are opened
  pub async fn drop_db(&mut self) {
    self.trees.drop();
    self.hierarchy.drop();
    self.role_manager.drop();
  }

  pub async fn add_tree(&mut self, tree_name: String, schema: String) {
    self.hierarchy.insert_tree_schema(tree_name.clone(), schema);
    self.trees.open_tree(tree_name);
  }

  pub async fn remove_tree(&mut self, tree_name: String) {
    self.hierarchy.remove_tree_schema(tree_name.clone());
    self.trees.remove_tree(tree_name);
  }
}
