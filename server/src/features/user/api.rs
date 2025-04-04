use async_graphql::{FieldResult, Object};

use super::{model::User, repository::UserRepository};

pub struct UserAPI(pub String, pub User);

//
// API Types
//

#[Object]
impl UserAPI {
  async fn id(&self) -> &str {
    &self.0
  }

  async fn username(&self) -> &str {
    &self.1.username
  }

  async fn password(&self) -> &str {
    &self.1.password
  }
}

//
// Queries
//
#[derive(Default)]
pub struct UserQueries;
#[Object]
impl UserQueries {
  async fn user(&self, id: String) -> FieldResult<UserAPI> {
    let user = match User::get(&id).await {
      Ok(user) => user,
      Err(e) => {
        log::error!("Failed to get user: {}", e);
        return Err(e.into());
      }
    };

    let user = match user {
      Some(user) => user,
      None => return Err("User not found".into()),
    };

    Ok(UserAPI(id, user))
  }

  async fn users(&self) -> FieldResult<Vec<UserAPI>> {
    let users = match User::get_all().await {
      Ok(users) => users,
      Err(e) => {
        log::error!("Failed to get users: {}", e);
        return Err(e.into());
      }
    };

    let mut user_apis = Vec::new();
    for (id, user) in users {
      user_apis.push(UserAPI(id, user));
    }

    Ok(user_apis)
  }
}
