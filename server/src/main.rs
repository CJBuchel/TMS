use serde::{Deserialize, Serialize};
use sled_extensions::{bincode::Tree, DbExt};
use warp::reply::Json;

extern crate sled;

// https://mbuffett.com/posts/rocket-sled-tutorial/

#[derive(Deserialize, Serialize, Clone)]
struct User {
  username: String,
  favorite_food: String,
}

struct Database {
  users: Tree<User>
}

fn put_person(db: Database, user: User) {
  db.users.insert(user.username.as_bytes(), user.clone());
}

#[tokio::main]
async fn main() {
  let db = sled_extensions::Config::default()
    .path("tms.kvdb")
    .open()
    .expect("Failed to open the Database");

  let mut tms_db:Database = Database { users: db.open_bincode_tree("users").expect("Failed to open user tree") };

  // Ok(())
}