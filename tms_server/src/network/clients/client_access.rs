use tms_infra::*;

use crate::database::*;

use super::client::Client;

pub enum ClientAccessResult {
  Success,
  AuthenticationRequired,
  Unauthorized,
}

#[async_trait::async_trait]
pub trait ClientAccess {
  async fn has_role_access(&self, db: SharedDatabase, roles: Vec<String>) -> ClientAccessResult;
}

#[async_trait::async_trait]
impl ClientAccess for Client {
  // check if client has access to any of the provided roles
  async fn has_role_access(&self, db: SharedDatabase, roles: Vec<String>) -> ClientAccessResult {
    // add admin role (admin should always have access)
    let mut roles = roles;
    roles.push(ADMIN_ROLE.to_string());

    let db = db.read().await;
    let user = db.get_inner().read().await.get_entry(":users".to_string(), self.user_id.clone()).await;
    match user {
      // if user is found, check if user has any of the roles required
      Some(user) => {
        let user = User::from_json_string(&user);
        for role in roles {
          if user.has_role_access(vec![role.to_string()]) {
            return ClientAccessResult::Success;
          }
        }
      }
      None => {
        return ClientAccessResult::AuthenticationRequired;
      }
    }

    return ClientAccessResult::Unauthorized;
  }
}
