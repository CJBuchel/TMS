use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::schemas::User;

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct UsersRequest {
  pub auth_token: String
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct UsersResponse {
  pub users: Vec<User>
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct AddUserRequest {
  pub auth_token: String,
  pub user: User
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct DeleteUserRequest {
  pub auth_token: String,
  pub username: String
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct UpdateUserRequest {
  pub auth_token: String,
  pub username: String,
  pub updated_user: User
}
