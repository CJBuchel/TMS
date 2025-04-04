use async_graphql::{FieldResult, InputObject, Object, SimpleObject};

use crate::{
  core::auth::Auth,
  features::{User, UserRepository},
};

//
// API Types
//
#[derive(SimpleObject)]
pub struct AuthPayload {
  token: String,
}

// #[derive(InputObject)]
// pub struct LoginInput {
//   username: String,
//   password: String,
// }

//
// Mutations
//
#[derive(Default)]
pub struct AuthMutations;
#[Object]
impl AuthMutations {
  async fn login(&self, username: String, password: String) -> FieldResult<AuthPayload> {
    // Check if valid input
    if username.is_empty() || password.is_empty() {
      return Err("Username or password cannot be empty".into());
    }

    // Check for matching users
    let user: User = match User::get_by_username(&username).await {
      Ok(users) => {
        // convert to vec
        if users.is_empty() {
          return Err("User not found".into());
        }

        if users.len() > 1 {
          return Err("Multiple users found with the same username".into());
        }

        let (_, user) = match users.into_iter().next() {
          Some(user) => user,
          None => return Err("Failed to get user from map".into()),
        };

        user
      }
      Err(e) => {
        log::error!("Failed to get user: {}", e);
        return Err(e.into());
      }
    };

    // Check if password matches
    if user.password != password {
      return Err("Invalid password".into());
    }

    // Generate token
    let token = match Auth::generate_token(&username) {
      Ok(token) => token,
      Err(e) => {
        log::error!("Failed to generate token: {}", e);
        return Err(e.into());
      }
    };

    Ok(AuthPayload { token })
  }
}
