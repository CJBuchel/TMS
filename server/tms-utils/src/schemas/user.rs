use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct Access {
  pub access_name: String, // screen name: Referee, Head Referee, Judge Advisor, Admin Panel etc...
  pub authorized: bool,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct User {
  pub username: String,
  pub password: String,
  pub admin: bool,

  // Access to screens
  pub access: Vec<Access>,
}