use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct Permissions { // if none are specified, the permission is considered basic
  pub admin: bool, // by normal accounts, if admin then override all below
  pub head_referee: Option<bool>,
  pub referee: Option<bool>,
  pub judge_advisor: Option<bool>,
  pub judge: Option<bool>
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct User {
  pub username: String,
  pub password: String,
  pub permissions: Permissions
}

pub fn create_permissions() -> Permissions {
  return Permissions { 
    admin: false,
    head_referee: Some(false), 
    referee: Some(false), 
    judge_advisor: Some(false), 
    judge: Some(false) 
  }
}

#[allow(dead_code)]
pub fn create_user() -> User {
  return User {
    username: String::from(""),
    password: String::from(""),
    permissions: create_permissions()
  }
}