use std::io::{BufRead, BufReader};

use chrono::Timelike;

use crate::generated::common::{TmsDateTime, TmsTime};

pub const BLOCK_FORMAT: &str = "Block Format";
pub const BLOCK_TEAMS: &str = "1";
pub const BLOCK_MATCHES: &str = "2";
pub const BLOCK_JUDGING: &str = "3";
pub const BLOCK_PRACTICE_MATCHES: &str = "4";

pub trait Block {
  type Output;

  fn extract_time(input: &str) -> Result<TmsDateTime, String> {
    let Ok(re) = regex::Regex::new(r"(\d{2}:\d{2}:\d{2})\s?(AM|PM)?") else {
      return Err("Error creating regex".to_string());
    };

    let Some(captures) = re.captures(input) else {
      return Err(format!("Error capturing time from: {}", input));
    };

    let time_str = captures.get(1).unwrap().as_str();

    let Ok(start_time_native) = chrono::NaiveTime::parse_from_str(time_str, "%H:%M:%S") else {
      return Err(format!("Error parsing time: {}", time_str));
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

  fn find_block_line_number(csv: &str, block: &str) -> Option<usize> {
    let reader = BufReader::new(csv.as_bytes());
    let mut line_number = 0;

    for line in reader.lines() {
      let Ok(line) = line else { return None };

      line_number += 1;

      // split
      let fields = line.split(',').collect::<Vec<&str>>();
      if fields.first() == Some(&BLOCK_FORMAT) && fields.get(1) == Some(&block) {
        return Some(line_number + 1); // start with line after block format
      }
    }

    None
  }

  // gets lines between block format and next block format
  fn get_block_lines(csv: &str, block: &str) -> Result<Vec<String>, String> {
    let reader = BufReader::new(csv.as_bytes());

    // find block
    let Some(block_line) = Self::find_block_line_number(csv, block) else {
      return Err(format!("Block {} not found", block));
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
      let fields = line.split(',').collect::<Vec<&str>>();
      if fields.first() == Some(&BLOCK_FORMAT) {
        break;
      }

      block_lines.push(line);
    }

    Ok(block_lines)
  }

  fn from_csv(csv: &str) -> Result<Self::Output, String>;
}
