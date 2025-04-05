use std::{
  collections::{HashMap, HashSet},
  fmt,
};

use once_cell::sync::Lazy;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Role {
  Admin,
  Referee,
  HeadReferee,
  Judge,
  JudgeAdvisor,
  // ScoreKeeper,
  // Emcee,
  // Av,
}

impl fmt::Display for Role {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    match self {
      Role::Admin => write!(f, "admin"),
      Role::Referee => write!(f, "referee"),
      Role::HeadReferee => write!(f, "head_referee"),
      Role::Judge => write!(f, "judge"),
      Role::JudgeAdvisor => write!(f, "judge_advisor"),
      // Role::ScoreKeeper => write!(f, "score_keeper"),
      // Role::Emcee => write!(f, "emcee"),
      // Role::Av => write!(f, "av"),
    }
  }
}

impl Role {
  pub fn has_permission(&self, required: &Role) -> bool {
    // Check if the role is in the role graph
    ROLE_GRAPH.has_permission(self, required)
  }
}

// Role hierarchy as a DAG (Directed Acyclic Graph)
pub static ROLE_GRAPH: Lazy<RoleGraph> = Lazy::new(|| {
  log::info!("Initializing role graph");
  let mut graph = RoleGraph::new();

  //
  // Define roles and their parents
  //

  // Super users
  graph.add_role_with_parents(Role::Admin, vec![]);

  // Referee roles
  graph.add_role_with_parents(Role::Referee, vec![]);
  graph.add_role_with_parents(Role::HeadReferee, vec![Role::Referee]);

  // Judge roles
  graph.add_role_with_parents(Role::Judge, vec![]);
  graph.add_role_with_parents(Role::JudgeAdvisor, vec![Role::Judge]);

  graph
});

// RoleGraph represents the inheritance graph of roles
pub struct RoleGraph {
  inheritance: HashMap<Role, HashSet<Role>>,
}

impl RoleGraph {
  pub fn new() -> Self {
    Self {
      inheritance: HashMap::new(),
    }
  }

  // Add a role with no parents
  pub fn add_role(&mut self, role: Role) {
    self.inheritance.entry(role).or_insert_with(HashSet::new);
  }

  // Add a role with parents
  pub fn add_role_with_parents(&mut self, role: Role, parents: Vec<Role>) {
    let entry = self.inheritance.entry(role).or_insert_with(HashSet::new);
    for parent in parents {
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
    let mut queue = vec![role.clone()];
    let mut visited = HashSet::new();
    visited.insert(role.clone());

    while let Some(current_role) = queue.pop() {
      // Check direct parents
      if let Some(parents) = self.inheritance.get(&current_role) {
        for parent in parents {
          if parent == required {
            return true;
          }

          if visited.insert(parent.clone()) {
            queue.push(parent.clone());
          }
        }
      }
    }

    false
  }
}
