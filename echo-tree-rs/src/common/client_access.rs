use super::client::Client;


pub trait ClientAccess {
  // has access to a tree
  fn has_read_access_to_tree(&self, tree: &str) -> bool;
  fn has_read_write_access_to_tree(&self, tree: &str) -> bool;

  // is subscribed to a tree
  fn is_subscribed_to_tree(&self, tree: &str) -> bool;

  // has access to a tree and is subscribed to it
  fn has_read_access_and_subscribed_to_tree(&self, tree: &str) -> bool;

  // filters out the trees that the client has access to
  fn filter_read_accessible_trees(&self, trees: Vec<String>) -> Vec<String>;

  // filter out the trees that the client does not have access to
  fn filter_unauthorized_read_write_trees(&self, trees: Vec<String>) -> Vec<String>;
}

impl ClientAccess for Client {
  // check if this client has access to a tree
  fn has_read_access_to_tree(&self, tree: &str) -> bool {
    // access is based on file system standards. If a user has access to `/a/` then they have access to `/a/b/` but not /b/
    self.role_read_access_trees.iter().any(|t| tree.starts_with(t)) || self.role_read_write_access_trees.iter().any(|t| tree.starts_with(t))
  }

  fn has_read_write_access_to_tree(&self, tree: &str) -> bool {
    self.role_read_write_access_trees.iter().any(|t| tree.starts_with(t))
  }

  // check if this client is subscribed to a tree
  fn is_subscribed_to_tree(&self, tree: &str) -> bool {
    // access is based on file system standards. If a user has access to `/a/` then they have access to `/a/b/` but not /b/
    self.subscribed_trees.iter().any(|t| tree.starts_with(t))
  }

  // check if this client has access to a tree and is subscribed to it
  fn has_read_access_and_subscribed_to_tree(&self, tree: &str) -> bool {
    self.has_read_access_to_tree(tree) && self.is_subscribed_to_tree(tree)
  }

  // filters out the trees that the client has access to
  fn filter_read_accessible_trees(&self, trees: Vec<String>) -> Vec<String> {
    trees
      .iter()
      .filter(|t| self.has_read_access_to_tree(t))
      .map(|t| t.to_string())
      .collect()
  }

  // returns the unauthorized trees of the given trees
  fn filter_unauthorized_read_write_trees(&self, trees: Vec<String>) -> Vec<String> {
    trees
      .iter()
      .filter(|t| !self.has_read_write_access_to_tree(t))
      .map(|t| t.to_string())
      .collect()
  }
}