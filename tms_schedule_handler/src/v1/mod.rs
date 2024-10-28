use std::io::{BufRead, BufReader};

use crate::{CsvToTmsSchedule, TmsSchedule};

const BLOCK_FORMAT: &str = "Block Format";
const BLOCK_TEAMS: &str = "1";
const BLOCK_MATCHES: &str = "2";
const BLOCK_JUDGING: &str = "3";
const BLOCK_PRACTICE_MATCHES: &str = "4";

mod schedule_teams_block;
use chrono::Timelike;
use schedule_teams_block::*;

mod schedule_matches_block;
use schedule_matches_block::*;

mod schedule_practice_matches_block;
use schedule_practice_matches_block::*;

mod schedule_judging_block;
use schedule_judging_block::*;
use tms_infra::{
  infra::database_schemas::{GameMatch, GameMatchTable, JudgingSession, JudgingSessionPod, Team, TmsDateTime, TmsTime},
  TmsCategory,
};

pub trait V1Block {
  type Output;

  fn find_block_line_number(csv: &str, block: &str) -> Option<usize> {
    let reader = BufReader::new(csv.as_bytes());
    let mut line_number = 0;

    for line in reader.lines() {
      let line = match line {
        Ok(line) => line,
        Err(_) => return None,
      };

      line_number += 1;

      // split
      let fields = line.split(",").collect::<Vec<&str>>();
      if fields[0] == BLOCK_FORMAT {
        if fields[1] == block {
          return Some(line_number + 1); // start with line after block format
        }
      }
    }

    None
  }

  // gets lines between block format and next block format
  fn get_block_lines(csv: &str, block: &str) -> Result<Vec<String>, String> {
    let reader = BufReader::new(csv.as_bytes());

    // find block
    let block_line = match Self::find_block_line_number(csv, block) {
      Some(line) => line,
      None => return Err(format!("Block {} not found", block)),
    };

    // skip to block, and get lines until next block
    let lines = reader.lines().skip(block_line);
    let mut block_lines: Vec<String> = vec![];

    for line in lines {
      let line = match line {
        Ok(line) => line,
        Err(e) => return Err(format!("Error reading line: {}", e)),
      };

      // split
      let fields = line.split(",").collect::<Vec<&str>>();
      if fields[0] == BLOCK_FORMAT {
        break;
      }

      block_lines.push(line);
    }

    Ok(block_lines)
  }

  fn from_csv(csv: &str) -> Result<Self::Output, String>;
}

pub struct V1 {
  pub teams_block: Option<ScheduleTeamsBlock>,
  pub matches_block: Option<ScheduleMatchesBlock>,
  pub practice_matches_block: Option<SchedulePracticeMatchesBlock>,
  pub judging_block: Option<ScheduleJudgeBlock>,
}

impl V1 {
  pub fn extract_time(input: &str) -> Result<TmsDateTime, String> {
    let re = match regex::Regex::new(r"(\d{2}:\d{2}:\d{2})\s?(AM|PM)?") {
      Ok(re) => re,
      Err(_) => return Err("Error creating regex".to_string()),
    };

    let captures = match re.captures(input) {
      Some(caps) => caps,
      None => return Err(format!("Error capturing time from: {}", input)),
    };

    let time_str = captures.get(1).unwrap().as_str();

    let start_time_native = match chrono::NaiveTime::parse_from_str(time_str, "%H:%M:%S") {
      Ok(time) => time,
      Err(_) => return Err(format!("Error parsing time: {}", time_str)),
    };

    // TMS Date Time
    let start_time = TmsDateTime {
      date: None,
      time: Some(TmsTime {
        hour: start_time_native.hour(),
        minute: start_time_native.minute(),
        second: start_time_native.second(),
      }),
    };

    Ok(start_time)
  }

  pub fn extract_category(input: &str) -> Option<String> {
    let re = match regex::Regex::new(r"^(.*)\s\d{2}:\d{2}:\d{2}\s?(AM|PM)?") {
      Ok(re) => re,
      Err(_) => return None,
    };

    let captures = re.captures(input)?;

    Some(captures.get(1).unwrap().as_str().to_string())
  }
}

impl CsvToTmsSchedule for V1 {
  fn valid_version(csv: &str) -> bool {
    let reader = BufReader::new(csv.as_bytes());

    for line in reader.lines() {
      let line = match line {
        Ok(line) => line,
        Err(_) => return false,
      };

      // split
      let fields = line.split(",").collect::<Vec<&str>>();
      if fields[0] == "Version Number" {
        if fields[1] == "1" {
          return true;
        }
      }
    }

    false
  }

  fn csv_to_tms_schedule(csv: &str) -> Result<TmsSchedule, String> {
    let v1 = V1 {
      teams_block: match ScheduleTeamsBlock::from_csv(csv) {
        Ok(block) => Some(block),
        Err(_) => None,
      },
      matches_block: match ScheduleMatchesBlock::from_csv(csv) {
        Ok(block) => Some(block),
        Err(_) => None,
      },
      judging_block: match ScheduleJudgeBlock::from_csv(csv) {
        Ok(block) => Some(block),
        Err(_) => None,
      },
      practice_matches_block: match SchedulePracticeMatchesBlock::from_csv(csv) {
        Ok(block) => Some(block),
        Err(_) => None,
      },
    };

    // v1 to tms schedule
    let mut schedule = TmsSchedule {
      teams: vec![],
      game_matches: vec![],
      game_tables: vec![],
      judging_sessions: vec![],
      judging_pods: vec![],
    };

    // teams
    if let Some(teams_block) = v1.teams_block {
      for team in teams_block.teams {
        schedule.teams.push(Team {
          team_number: team.team_number,
          name: team.name,
          affiliation: team.affiliation,
          ranking: 0,
        });
      }
    }

    // practice matches
    if let Some(practice_matches_block) = v1.practice_matches_block {
      for m in practice_matches_block.matches {
        let mut game_match_tables: Vec<GameMatchTable> = vec![];

        if m.on_tables.is_empty() {
          log::error!("No tables assigned to match: {}", m.match_number);
          return Err(format!("No tables assigned to match: {}", m.match_number));
        }

        for on_table in m.on_tables.clone() {
          let game_match_table = GameMatchTable {
            table: on_table.on_table_name,
            team_number: on_table.team_number,
            score_submitted: false,
          };
          game_match_tables.push(game_match_table);
        }

        // start/end time
        let start_time = Self::extract_time(&m.start_time)?;
        let end_time = Self::extract_time(&m.end_time)?;

        let sub_categories = match Self::extract_category(&m.start_time) {
          Some(sub_category) => vec![sub_category],
          None => vec![],
        };

        schedule.game_matches.push(GameMatch {
          match_number: m.match_number.clone(),
          start_time,
          end_time,
          game_match_tables,
          completed: false,
          category: TmsCategory {
            category: String::from("Practice Matches"),
            sub_categories,
          },
        });
      }
    }

    // matches & tables
    if let Some(matches_block) = v1.matches_block {
      // tables
      for table in matches_block.table_names {
        schedule.game_tables.push(table);
      }

      // matches
      for m in matches_block.matches {
        let mut game_match_tables: Vec<GameMatchTable> = vec![];

        if m.on_tables.is_empty() {
          log::error!("No tables assigned to match: {}", m.match_number);
          return Err(format!("No tables assigned to match: {}", m.match_number));
        }

        for on_table in m.on_tables.clone() {
          let game_match_table = GameMatchTable {
            table: on_table.on_table_name,
            team_number: on_table.team_number,
            score_submitted: false,
          };
          game_match_tables.push(game_match_table);
        }

        // start/end time
        let start_time = Self::extract_time(&m.start_time)?;
        let end_time = Self::extract_time(&m.end_time)?;

        let sub_categories = match Self::extract_category(&m.start_time) {
          Some(sub_category) => vec![sub_category],
          None => vec![],
        };

        schedule.game_matches.push(GameMatch {
          match_number: m.match_number.clone(),
          start_time,
          end_time,
          game_match_tables,
          completed: false,
          category: TmsCategory {
            category: String::from("Ranking Matches"),
            sub_categories,
          },
        });
      }
    }

    // judging & pods
    if let Some(judging_block) = v1.judging_block {
      // pods
      for pod in judging_block.judging_room_names {
        schedule.judging_pods.push(pod);
      }

      // sessions
      for j in judging_block.sessions {
        let mut judging_session_pods: Vec<JudgingSessionPod> = vec![];

        for pod in j.in_rooms.clone() {
          let judging_session_pod = JudgingSessionPod {
            team_number: pod.team_number.clone(),
            pod_name: pod.room_name.clone(),
            innovation_submitted: false,
            core_values_submitted: false,
            robot_design_submitted: false,
          };
          judging_session_pods.push(judging_session_pod);
        }

        // start/end time
        let start_time = Self::extract_time(&j.start_time)?;
        let end_time = Self::extract_time(&j.end_time)?;

        let category_name = String::from("Judging Sessions");
        let sub_categories = match Self::extract_category(&j.start_time) {
          Some(sub_category) => vec![sub_category],
          None => vec![],
        };

        schedule.judging_sessions.push(JudgingSession {
          session_number: j.session_number.clone(),
          start_time,
          end_time,
          judging_session_pods,
          completed: false,
          category: TmsCategory { category: category_name, sub_categories },
        });
      }
    }

    Ok(schedule)
  }
}
