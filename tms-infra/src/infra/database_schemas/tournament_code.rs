use std::fmt::Display;

pub trait TournamentCode: Display {
  fn get_stringified_code(&self) -> String {
    self.to_string()
  }
  fn get_message(&self) -> String;
}