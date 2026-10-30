// `sqlx::migrate!` embeds the migrations at compile time. Without this, adding a migration file does not rebuild
// the crate, and the program runs without the new migration.
fn main() {
  println!("cargo:rerun-if-changed=../../migrations");
}
