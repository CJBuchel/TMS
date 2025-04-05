use async_graphql::Guard;

use crate::core::permissions::Role;

use super::client_context::ClientContext;

pub struct RoleGuard(pub Vec<Role>);

impl RoleGuard {
  pub fn new(roles: Vec<Role>) -> Self {
    Self(roles)
  }
}

impl Guard for RoleGuard {
  async fn check(&self, ctx: &async_graphql::Context<'_>) -> async_graphql::Result<()> {
    if ctx
      .data_opt::<ClientContext>()
      .map(|ctx| ctx.check_permissions(self.0.clone()))
      .unwrap_or(false)
    {
      Ok(())
    } else {
      Err(format!("Unauthorized: Missing required permissions: {:?}", self.0).into())
    }
  }
}
