use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct Access {
  // check tms-utils/lib.rs, client_type is a category for the access, REFEREE, JA, ADMIN, H-REFEREE etc...
  pub category_type_access: String, // Note that BASIC should not be listed as it's the first level of accessibility (public screens, no login)

  pub authorized: bool, // Do they have access to this service
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct User {
  pub username: String,
  pub password: String,
  pub admin: bool, // if this user is an admin, ignore the below access types

  // Access to screens
  pub access: Vec<Access>,
}