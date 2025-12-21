use std::{
  collections::{HashMap, HashSet},
  fmt, vec,
};

use once_cell::sync::Lazy;

use crate::generated::common::Role;

impl fmt::Display for Role {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    write!(f, "{}", self.as_str_name())
  }
}

// RoleGraph represents the inheritance graph of roles
pub struct RoleGraph {
  inheritance: HashMap<Role, HashSet<Role>>,
}

impl Default for RoleGraph {
  fn default() -> Self {
    Self::new()
  }
}

impl RoleGraph {
  pub fn new() -> Self {
    Self {
      inheritance: HashMap::new(),
    }
  }

  // Add a role with no inheritance
  pub fn add_role(&mut self, role: Role) {
    self.inheritance.entry(role).or_default();
  }

  // Add a role with inheritance
  pub fn add_role_with_inheritance(&mut self, role: Role, inherited_roles: Vec<Role>) {
    let entry = self.inheritance.entry(role).or_default();
    for parent in inherited_roles {
      entry.insert(parent);
    }
  }

  // Check if role has the required permissions, including inheritance
  pub fn has_permission(&self, role: &Role, required: &Role) -> bool {
    // If the role is admin, bypass all checks
    if role == &Role::Admin {
      return true;
    }

    // Direct match
    if role == required {
      return true;
    }

    // BFS to check for inheritance
    let mut queue = vec![*role];
    let mut visited = HashSet::new();
    visited.insert(*role);

    while let Some(current_role) = queue.pop() {
      // Check direct inheritance
      if let Some(inheritance) = self.inheritance.get(&current_role) {
        for parent in inheritance {
          if parent == required {
            return true;
          }

          if visited.insert(*parent) {
            queue.push(*parent);
          }
        }
      }
    }

    false
  }
}

pub static ROLE_GRAPH: Lazy<RoleGraph> = Lazy::new(|| {
  log::info!("Initializing role graph");
  let mut graph = RoleGraph::new();

  //
  // Define roles that have parent roles
  // (we don't care about dangling roles as they get checked 1:1)
  //

  // Referee roles
  graph.add_role_with_inheritance(Role::Referee, vec![]);
  graph.add_role_with_inheritance(Role::HeadReferee, vec![Role::Referee]);

  // Judge roles
  graph.add_role_with_inheritance(Role::Judge, vec![]);
  graph.add_role_with_inheritance(Role::JudgeAdvisor, vec![Role::Judge]);

  graph
});

pub trait RolePermissions {
  fn has_permission(&self, required: &Role) -> bool;
}

impl RolePermissions for Role {
  fn has_permission(&self, required: &Role) -> bool {
    // Check against the role graph
    ROLE_GRAPH.has_permission(self, required)
  }
}
