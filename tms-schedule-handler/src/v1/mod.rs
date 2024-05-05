use std::io::{BufRead, BufReader};

use crate::{CsvToTmsSchedule, TmsSchedule};

const BLOCK_FORMAT: &str = "Block Format";
const BLOCK_TEAMS: &str = "1";
const BLOCK_MATCHES: &str = "2";
const BLOCK_JUDGING: &str = "3";
const BLOCK_PRACTICE_MATCHES: &str = "4";

mod schedule_teams_block;
use schedule_teams_block::*;

mod schedule_matches_block;
use schedule_matches_block::*;

mod schedule_practice_matches_block;
use schedule_practice_matches_block::*;

mod schedule_judging_block;
use schedule_judging_block::*;
use tms_infra::{GameMatch, GameMatchTable, JudgingSession, JudgingSessionPod, Team};

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
          return Some(line_number+1); // start with line after block format
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
  pub teams_block: ScheduleTeamsBlock,
  pub matches_block: ScheduleMatchesBlock,
  pub practice_matches_block: SchedulePracticeMatchesBlock,
  pub judging_block: ScheduleJudgeBlock,
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
      teams_block: ScheduleTeamsBlock::from_csv(csv)?,
      matches_block: ScheduleMatchesBlock::from_csv(csv)?,
      practice_matches_block: SchedulePracticeMatchesBlock::from_csv(csv)?,
      judging_block: ScheduleJudgeBlock::from_csv(csv)?,
    };

    // v1 to tms schedule
    let schedule = TmsSchedule {
      teams: v1.teams_block.teams.iter().map(|t| {
        Team {
          cloud_id: "".to_string(),
          ranking: 0,
          number: t.number.clone(),
          name: t.name.clone(),
          affiliation: t.affiliation.clone(),
        }
      }).collect(),

      game_matches: v1.matches_block.matches.iter().map(|m| {
        let mut game_match_tables: Vec<GameMatchTable> = vec![];

        for on_table in m.on_tables.clone() {
          let game_match_table = GameMatchTable {
            table: on_table.on_table_name,
            team_number: on_table.team_number,
            score_submitted: false,
          };
          game_match_tables.push(game_match_table);
        }

        GameMatch {
          match_number: m.match_number.clone(),
          start_time: m.start_time.clone(),
          end_time: m.end_time.clone(),
          game_match_tables: game_match_tables,
        }
      }).collect(),

      practice_game_matches: v1.practice_matches_block.matches.iter().map(|m| {
        let mut game_match_tables: Vec<GameMatchTable> = vec![];

        for on_table in m.on_tables.clone() {
          let game_match_table = GameMatchTable {
            table: on_table.on_table_name,
            team_number: on_table.team_number,
            score_submitted: false,
          };
          game_match_tables.push(game_match_table);
        }

        GameMatch {
          match_number: m.match_number.clone(),
          start_time: m.start_time.clone(),
          end_time: m.end_time.clone(),
          game_match_tables,
        }
      }).collect(),

      judging_sessions: v1.judging_block.sessions.iter().map(|s| {
        let mut session_pods: Vec<JudgingSessionPod> = vec![];

        for in_room in s.in_rooms.clone() {
          let session_pod = JudgingSessionPod {
            pod: in_room.room_name,
            team_number: in_room.team_number,
            core_values_submitted: false,
            innovation_submitted: false,
            robot_design_submitted: false,
          };
          session_pods.push(session_pod);
        }

        JudgingSession {
          session_number: s.session_number.clone(),
          start_time: s.start_time.clone(),
          end_time: s.end_time.clone(),
          judging_session_pods: session_pods,
        }
      }).collect(),
    };

    Ok(schedule)
  }
}