use tms_infra::User;

use crate::database::*;

use super::client::Client;

#[async_trait::async_trait]
pub trait ClientAccess {
  async fn has_role_access(&self, db: SharedDatabase, roles: Vec<String>) -> bool;
}

#[async_trait::async_trait]
impl ClientAccess for Client {

  // check if client has access to any of the provided roles
  async fn has_role_access(&self, db: SharedDatabase, roles: Vec<String>) -> bool {
    let db = db.read().await;
    let user = db.get_inner().read().await.get_entry(":users".to_string(), self.user_id.clone()).await;
    match user {
      // if user is found, check if user has any of the roles required
      Some(user) => {
        let user = User::from_schema(&user);
        for role in roles {
          if user.roles.contains(&role.to_string()) {
            return true;
          }
        }
      }
      None => {
        return false;
      }
    }

    return false;
  }
}