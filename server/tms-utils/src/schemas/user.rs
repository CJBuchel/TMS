use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct Permissions { // if none are specified, the permission is considered basic
  pub head_referee: bool,
  pub referee: bool,
  pub judge_advisor: bool,
  pub judge: bool
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct User {
  pub username: String,
  pub password: String,

  pub admin: bool,
  pub permissions: Permissions
}

pub fn create_permissions() -> Permissions {
  return Permissions { 
    head_referee: false, 
    referee: false, 
    judge_advisor: false, 
    judge: false 
  }
}

#[allow(dead_code)]
pub fn create_user() -> User {
  return User {
    username: String::from(""),
    password: String::from(""),
    admin: false,
    permissions: create_permissions()
  }
}