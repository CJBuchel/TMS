mod team;
pub use team::*;

mod tournament_config;
pub use tournament_config::*;

pub trait DataSchemeExtensions {
  fn get_schema() -> String;
}