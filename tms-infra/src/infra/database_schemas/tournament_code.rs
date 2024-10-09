use std::fmt::Display;


pub trait TournamentCode: Display {
  #[flutter_rust_bridge::frb(sync)]
  fn get_stringified_code(&self) -> String {
    self.to_string()
  }
  #[flutter_rust_bridge::frb(sync)]
  fn get_message(&self) -> String;
}