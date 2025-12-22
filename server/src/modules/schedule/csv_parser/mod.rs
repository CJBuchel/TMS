use std::io::{BufRead, BufReader};

use crate::modules::schedule::{
  csv_parser::{
    block::Block, judging_block::ScheduledJudging, matches_block::ScheduledMatches,
    practice_matches_block::ScheduledPracticeMatches, teams_block::ScheduledTeams,
  },
  {CsvToSchedule, Schedule},
};

pub mod block;
pub mod judging_block;
pub mod matches_block;
pub mod practice_matches_block;
pub mod teams_block;

pub struct CsvParser;

impl CsvToSchedule for CsvParser {
  fn valid_csv_version(csv: &str) -> bool {
    let reader = BufReader::new(csv.as_bytes());

    for line in reader.lines() {
      let Ok(line) = line else { return false };

      // split
      let fields = line.split(',').collect::<Vec<&str>>();
      if fields.first() == Some(&"Version Number") && fields.get(1) == Some(&"1") {
        return true;
      }
    }

    false
  }

  fn csv_to_schedule(csv: &str) -> anyhow::Result<Schedule> {
    let teams_schedule = ScheduledTeams::from_csv(csv).ok();

    let matches_schedule = ScheduledMatches::from_csv(csv).ok();

    let practice_matches_schedule = ScheduledPracticeMatches::from_csv(csv).ok();

    let judging_schedule = ScheduledJudging::from_csv(csv).ok();

    let table_names = if let Some(matches) = matches_schedule.clone() { matches.table_names } else { Vec::new() };

    let pod_names = if let Some(judging) = judging_schedule.clone() { judging.pod_names } else { Vec::new() };

    let schedule = Schedule {
      scheduled_teams: teams_schedule,
      scheduled_matches: matches_schedule,
      scheduled_practice_matches: practice_matches_schedule,
      scheduled_judging: judging_schedule,
      table_names,
      pod_names,
    };
    Ok(schedule)
  }
}
