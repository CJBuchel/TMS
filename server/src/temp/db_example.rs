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

#[derive(Clone)]
struct Database {
  users: Tree<User>
}

fn get_person(db: Database, username: String) -> User {
  return db.users.get(username.as_bytes()).unwrap().unwrap();
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

  let tms_db:Database = Database { users: db.open_bincode_tree("users").expect("Failed to open user tree") };

  put_person(tms_db.to_owned(), User { username: "Connor".to_string(), favorite_food: "Chicken".to_string() });

  let person = get_person(tms_db.to_owned(), "Connor".to_string());
  println!("My fav food {}", person.favorite_food);
  // Ok(())
}