pub mod api;
mod csv_parser;

use anyhow::Result;

use crate::modules::schedule::csv_parser::{
  CsvParser, judging_block::ScheduledJudging, matches_block::ScheduledMatches,
  practice_matches_block::ScheduledPracticeMatches, teams_block::ScheduledTeams,
};

pub struct Schedule {
  pub scheduled_teams: Option<ScheduledTeams>,
  pub scheduled_matches: Option<ScheduledMatches>,
  pub scheduled_practice_matches: Option<ScheduledPracticeMatches>,
  pub scheduled_judging: Option<ScheduledJudging>,
  pub table_names: Vec<String>,
  pub pod_names: Vec<String>,
}

pub trait CsvToSchedule {
  fn valid_csv_version(csv: &str) -> bool;
  fn csv_to_schedule(csv: &str) -> Result<Schedule>;
}

impl Schedule {
  pub fn from(csv: &str) -> Result<Schedule> {
    if CsvParser::valid_csv_version(csv) {
      log::info!("Valid csv version");
      return CsvParser::csv_to_schedule(csv);
    }

    Err(anyhow::anyhow!("Invalid version or unknown CSV type"))
  }
}
