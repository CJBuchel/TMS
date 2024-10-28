use tms_infra::infra::database_schemas::{GameMatch, JudgingSession, Team};
use v1::V1;

pub mod v1;

pub trait CsvToTmsSchedule {
  fn valid_version(csv: &str) -> bool;
  fn csv_to_tms_schedule(csv: &str) -> Result<TmsSchedule, String>;
}

pub struct TmsSchedule {
  pub teams: Vec<Team>,
  pub game_matches: Vec<GameMatch>,
  pub judging_sessions: Vec<JudgingSession>,
  pub game_tables: Vec<String>,
  pub judging_pods: Vec<String>,
}

impl TmsSchedule {
  pub fn from(csv: &str) -> Result<TmsSchedule, String> {
    if V1::valid_version(csv) {
      log::info!("Valid V1 version");
      return Ok(V1::csv_to_tms_schedule(csv)?);
    }

    Err("Invalid version or unknown CSV type".to_string())
  }
}