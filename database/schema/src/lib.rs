mod team;
pub use team::*;

mod tournament_config;
pub use tournament_config::*;

pub trait SchemaUtil {
  fn get_schema() -> String;
}