use crate::core::permissions::Role;

pub struct ClientContext {
  pub roles: Vec<Role>,
}

impl ClientContext {
  pub fn new() -> Self {
    Self { roles: Vec::new() }
  }

  pub fn has_role(&self, role: &Role) -> bool {
    self.roles.contains(role)
  }

  pub fn check_permissions(&self, required: Vec<Role>) -> bool {
    let authenticated = self
      .roles
      .iter()
      .any(|role| required.iter().any(|required_role| role.has_permission(required_role)));

    authenticated
  }
}
