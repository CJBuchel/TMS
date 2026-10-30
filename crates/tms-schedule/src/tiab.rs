//! Tournament-in-a-Box schedule CSV, "Version Number,1". The file is a run of blocks:
//!
//! ```text
//! Version Number,1
//! Block Format,1                     teams: number,name,affiliation
//! Block Format,2                     ranking matches: number,start,end,team per table...
//! Block Format,3                     judging: number,start,end,team per room...
//! Block Format,4                     practice matches, laid out like block 2
//! ```
//!
//! Header rows inside a block ("Table Names,Red,Blue", "Number of Teams,40") are keyed by their first cell; data
//! rows start with a number. Times look like `Day 1 09:00:00 AM` or `13:25:00 PM`: some exports write 24-hour
//! hours with an AM/PM suffix, so the suffix only applies to hours 1-12. Trailing empty cells are optional.

use std::collections::{BTreeMap, HashSet};
use std::fmt;

use chrono::NaiveTime;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TiabTeam {
  pub number: String,
  pub name: String,
  pub affiliation: String,
}

/// A clock time with the scheduler's optional day label ("Day 2").
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TiabTime {
  pub day: Option<String>,
  pub time: NaiveTime,
}

/// One match or judging session: a team number (or nothing) per table or room column.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TiabRow {
  pub number: i32,
  pub start: TiabTime,
  pub end: TiabTime,
  pub teams: Vec<Option<String>>,
  pub line: u64,
}

#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct MatchBlock {
  pub tables: Vec<String>,
  pub matches: Vec<TiabRow>,
}

#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct JudgingBlock {
  pub rooms: Vec<String>,
  pub sessions: Vec<TiabRow>,
}

#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct TiabFile {
  pub teams: Vec<TiabTeam>,
  pub ranking: Option<MatchBlock>,
  pub practice: Option<MatchBlock>,
  pub judging: Option<JudgingBlock>,
  /// Problems that do not stop an import, such as a team with no judging session.
  pub warnings: Vec<String>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ParseError {
  pub line: u64,
  pub message: String,
}

impl fmt::Display for ParseError {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    if self.line == 0 {
      write!(f, "{}", self.message)
    } else {
      write!(f, "line {}: {}", self.line, self.message)
    }
  }
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum Block {
  None,
  Teams,
  Ranking,
  Judging,
  Practice,
}

/// Reads the whole file and reports every problem found, not just the first.
pub fn parse(text: &str) -> Result<TiabFile, Vec<ParseError>> {
  let mut reader = csv::ReaderBuilder::new()
    .has_headers(false)
    .flexible(true)
    .trim(csv::Trim::All)
    .from_reader(text.as_bytes());

  let mut file = TiabFile::default();
  let mut errors = Vec::new();
  let mut block = Block::None;
  let mut seen_version = false;
  let mut declared: BTreeMap<&'static str, (u64, usize)> = BTreeMap::new();

  for record in reader.records() {
    let record = match record {
      Ok(r) => r,
      Err(e) => {
        errors.push(ParseError {
          line: e.position().map_or(0, csv::Position::line),
          message: e.to_string(),
        });
        continue;
      }
    };
    let line = record.position().map_or(0, csv::Position::line);
    let cells: Vec<&str> = record.iter().collect();
    let Some(&first) = cells.first() else { continue };
    if cells.iter().all(|c| c.is_empty()) {
      continue;
    }
    let err = |message: String| ParseError { line, message };

    match first {
      "Version Number" => {
        if cells.get(1).copied() != Some("1") {
          errors.push(err(format!(
            "unsupported version `{}`; only version 1 is understood",
            cells.get(1).unwrap_or(&"")
          )));
        }
        seen_version = true;
        continue;
      }
      "Block Format" => {
        block = match cells.get(1).copied() {
          Some("1") => Block::Teams,
          Some("2") => {
            file.ranking.get_or_insert_with(MatchBlock::default);
            Block::Ranking
          }
          Some("3") => {
            file.judging.get_or_insert_with(JudgingBlock::default);
            Block::Judging
          }
          Some("4") => {
            file.practice.get_or_insert_with(MatchBlock::default);
            Block::Practice
          }
          other => {
            errors.push(err(format!("unknown block format `{}`", other.unwrap_or(""))));
            Block::None
          }
        };
        continue;
      }
      _ => {}
    }
    if !seen_version {
      errors.push(err("the file must start with `Version Number,1`".to_owned()));
      seen_version = true;
    }

    let names = || {
      cells[1..]
        .iter()
        .filter(|c| !c.is_empty())
        .map(|c| (*c).to_owned())
        .collect::<Vec<_>>()
    };
    let count = |key: &'static str, declared: &mut BTreeMap<&'static str, (u64, usize)>| {
      if let Some(n) = cells.get(1).and_then(|c| c.parse().ok()) {
        declared.insert(key, (line, n));
      }
    };
    match (block, first) {
      (Block::Teams, "Number of Teams") => count("teams", &mut declared),
      (Block::Ranking, "Number of Ranking Matches") => count("ranking", &mut declared),
      (Block::Practice, "Number of Practice Matches") => count("practice", &mut declared),
      (Block::Judging, "Number of Event Time Slots") => count("sessions", &mut declared),
      (Block::Ranking, "Table Names") => file.ranking.get_or_insert_with(MatchBlock::default).tables = names(),
      (Block::Practice, "Table Names") => file.practice.get_or_insert_with(MatchBlock::default).tables = names(),
      (Block::Judging, "Room Names") => file.judging.get_or_insert_with(JudgingBlock::default).rooms = names(),
      // Informational headers TMS does not need.
      (
        _,
        "Number of Tables"
        | "Number of Teams per Table"
        | "Number of Simultaneous Tables"
        | "Number of Judged Events"
        | "Number of Judging Teams"
        | "Event Name",
      ) => {}
      (Block::Teams, _) => match parse_team(&cells) {
        Ok(team) => file.teams.push(team),
        Err(message) => errors.push(err(message)),
      },
      (Block::Ranking | Block::Practice | Block::Judging, _) => {
        let columns = match block {
          Block::Ranking => file.ranking.as_ref().map_or(0, |b| b.tables.len()),
          Block::Practice => file.practice.as_ref().map_or(0, |b| b.tables.len()),
          _ => file.judging.as_ref().map_or(0, |b| b.rooms.len()),
        };
        match parse_row(&cells, line, columns) {
          Ok(row) => match block {
            Block::Ranking => file.ranking.get_or_insert_with(MatchBlock::default).matches.push(row),
            Block::Practice => file.practice.get_or_insert_with(MatchBlock::default).matches.push(row),
            _ => file
              .judging
              .get_or_insert_with(JudgingBlock::default)
              .sessions
              .push(row),
          },
          Err(message) => errors.push(err(message)),
        }
      }
      (Block::None, _) => errors.push(err(format!("`{first}` appears before any `Block Format` line"))),
    }
  }

  if !seen_version {
    errors.push(ParseError {
      line: 0,
      message: "the file is empty or is not a Tournament-in-a-Box schedule".to_owned(),
    });
  }
  check(&mut file, &declared, &mut errors);
  if errors.is_empty() { Ok(file) } else { Err(errors) }
}

fn parse_team(cells: &[&str]) -> Result<TiabTeam, String> {
  let number = cells[0];
  if number.is_empty() || number.len() > 12 {
    return Err(format!("`{number}` is not a team number"));
  }
  let name = cells.get(1).copied().unwrap_or_default();
  if name.is_empty() {
    return Err(format!("team {number} has no name"));
  }
  Ok(TiabTeam {
    number: number.to_owned(),
    name: name.to_owned(),
    affiliation: cells.get(2).copied().unwrap_or_default().to_owned(),
  })
}

fn parse_row(cells: &[&str], line: u64, columns: usize) -> Result<TiabRow, String> {
  let number: i32 = cells[0]
    .parse()
    .map_err(|_| format!("`{}` is not a match or session number", cells[0]))?;
  let start = parse_time(cells.get(1).copied().unwrap_or_default())?;
  let end = parse_time(cells.get(2).copied().unwrap_or_default())?;
  if (start.day == end.day) && end.time <= start.time {
    return Err(format!("{number} ends before it starts"));
  }
  let mut teams: Vec<Option<String>> = cells
    .iter()
    .skip(3)
    .map(|c| (!c.is_empty()).then(|| (*c).to_owned()))
    .collect();
  while teams.last() == Some(&None) {
    teams.pop();
  }
  if teams.len() > columns {
    return Err(format!(
      "{number} lists {} team columns but only {columns} tables or rooms are named",
      teams.len()
    ));
  }
  teams.resize(columns, None);
  Ok(TiabRow {
    number,
    start,
    end,
    teams,
    line,
  })
}

/// `[label ]H:MM[:SS][ AM|PM]`.
pub fn parse_time(cell: &str) -> Result<TiabTime, String> {
  let words: Vec<&str> = cell.split_whitespace().collect();
  let at = words
    .iter()
    .position(|w| w.contains(':'))
    .ok_or_else(|| format!("`{cell}` is not a time"))?;
  let mut parts = words[at].split(':').map(str::parse::<u32>);
  let (Some(Ok(mut hour)), Some(Ok(minute))) = (parts.next(), parts.next()) else {
    return Err(format!("`{cell}` is not a time"));
  };
  let second = match parts.next() {
    Some(Ok(s)) => s,
    None => 0,
    Some(Err(_)) => return Err(format!("`{cell}` is not a time")),
  };
  match words.get(at + 1).map(|w| w.to_ascii_uppercase()).as_deref() {
    Some("PM") if (1..12).contains(&hour) => hour += 12,
    Some("AM") if hour == 12 => hour = 0,
    Some("AM" | "PM") | None => {}
    Some(other) => return Err(format!("unexpected `{other}` after the time in `{cell}`")),
  }
  let time = NaiveTime::from_hms_opt(hour, minute, second).ok_or_else(|| format!("`{cell}` is not a valid time"))?;
  let day = (at > 0).then(|| words[..at].join(" "));
  Ok(TiabTime { day, time })
}

/// Cross-block checks: every team in a match or session is a known team, numbers are unique, counts agree.
fn check(file: &mut TiabFile, declared: &BTreeMap<&'static str, (u64, usize)>, errors: &mut Vec<ParseError>) {
  let mut known = HashSet::new();
  for team in &file.teams {
    if !known.insert(team.number.as_str()) {
      errors.push(ParseError {
        line: 0,
        message: format!("team {} is listed twice", team.number),
      });
    }
  }

  let mut check_rows = |what: &str, rows: &[TiabRow]| {
    let mut numbers = HashSet::new();
    for row in rows {
      if !numbers.insert(row.number) {
        errors.push(ParseError {
          line: row.line,
          message: format!("{what} {} appears twice", row.number),
        });
      }
      let mut in_row = HashSet::new();
      for team in row.teams.iter().flatten() {
        if !known.contains(team.as_str()) {
          errors.push(ParseError {
            line: row.line,
            message: format!("{what} {} uses team {team}, which is not in the team list", row.number),
          });
        }
        if !in_row.insert(team) {
          errors.push(ParseError {
            line: row.line,
            message: format!("{what} {} lists team {team} twice", row.number),
          });
        }
      }
    }
  };
  if let Some(b) = &file.ranking {
    check_rows("ranking match", &b.matches);
  }
  if let Some(b) = &file.practice {
    check_rows("practice match", &b.matches);
  }
  if let Some(b) = &file.judging {
    check_rows("judging session", &b.sessions);
  }

  let mut warn_count = |key: &str, what: &str, actual: usize| {
    if let Some((line, n)) = declared.get(key)
      && *n != actual
    {
      file
        .warnings
        .push(format!("line {line}: the file says {n} {what} but lists {actual}"));
    }
  };
  warn_count("teams", "teams", file.teams.len());
  warn_count(
    "ranking",
    "ranking matches",
    file.ranking.as_ref().map_or(0, |b| b.matches.len()),
  );
  warn_count(
    "practice",
    "practice matches",
    file.practice.as_ref().map_or(0, |b| b.matches.len()),
  );
  warn_count(
    "sessions",
    "judging time slots",
    file.judging.as_ref().map_or(0, |b| b.sessions.len()),
  );

  if let Some(judging) = &file.judging {
    let judged: HashSet<&str> = judging
      .sessions
      .iter()
      .flat_map(|s| s.teams.iter().flatten())
      .map(String::as_str)
      .collect();
    let missing: Vec<&str> = file
      .teams
      .iter()
      .map(|t| t.number.as_str())
      .filter(|n| !judged.contains(n))
      .collect();
    if !missing.is_empty() {
      file
        .warnings
        .push(format!("teams with no judging session: {}", missing.join(", ")));
    }
  }
  if let Some(ranking) = &file.ranking {
    let mut counts: BTreeMap<&str, usize> = file.teams.iter().map(|t| (t.number.as_str(), 0)).collect();
    for team in ranking.matches.iter().flat_map(|m| m.teams.iter().flatten()) {
      *counts.entry(team.as_str()).or_default() += 1;
    }
    let most = counts.values().copied().max().unwrap_or(0);
    let short: Vec<String> = counts
      .iter()
      .filter(|(_, c)| **c < most)
      .map(|(t, c)| format!("{t} ({c})"))
      .collect();
    if !short.is_empty() {
      file.warnings.push(format!(
        "teams with fewer ranking matches than the others ({most}): {}",
        short.join(", ")
      ));
    }
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn times() {
    let t = |s: &str| parse_time(s).unwrap();
    assert_eq!(t("10:00:00 AM").time, NaiveTime::from_hms_opt(10, 0, 0).unwrap());
    assert_eq!(t("1:05 PM").time, NaiveTime::from_hms_opt(13, 5, 0).unwrap());
    assert_eq!(
      t("13:25:00 PM").time,
      NaiveTime::from_hms_opt(13, 25, 0).unwrap(),
      "24-hour hour with a PM suffix"
    );
    assert_eq!(t("12:15:00 PM").time, NaiveTime::from_hms_opt(12, 15, 0).unwrap());
    assert_eq!(t("12:15:00 AM").time, NaiveTime::from_hms_opt(0, 15, 0).unwrap());
    assert_eq!(t("Day 2 08:30:00 AM").day.as_deref(), Some("Day 2"));
    assert_eq!(t("09:00").day, None);
    assert!(parse_time("soon").is_err());
    assert!(parse_time("25:00:00").is_err());
    assert!(parse_time("10:00 XM").is_err());
  }

  #[test]
  fn minimal_file() {
    let text = "Version Number,1\nBlock Format,1\nNumber of Teams,2\n1,Alpha,School A,\n2,\"Beta, Inc\",School B,\n\
                Block Format,2\nTable Names,T1,T2,\n1,9:00 AM,9:04 AM,1,2,\n2,9:10 AM,9:14 AM,2,1\n";
    let file = parse(text).unwrap();
    assert_eq!(file.teams[1].name, "Beta, Inc", "quoted names keep their commas");
    let ranking = file.ranking.unwrap();
    assert_eq!(ranking.tables, vec!["T1", "T2"]);
    assert_eq!(ranking.matches[1].teams, vec![Some("2".into()), Some("1".into())]);
    assert!(file.warnings.is_empty(), "{:?}", file.warnings);
  }

  #[test]
  fn reports_every_problem() {
    let text = "Version Number,1\nBlock Format,1\n1,Alpha,A\n1,Again,A\nBlock Format,2\nTable Names,T1\n\
                1,9:00 AM,9:04 AM,7\n1,9:10 AM,9:05 AM,1\nx,9:10 AM,9:14 AM,1\n2,9:20 AM,9:24 AM,1,1\n";
    let errors = parse(text).unwrap_err();
    let messages: Vec<String> = errors.iter().map(ToString::to_string).collect();
    let has = |needle: &str| messages.iter().any(|m| m.contains(needle));
    assert!(has("team 1 is listed twice"), "{messages:?}");
    assert!(has("uses team 7"), "{messages:?}");
    assert!(has("ends before it starts"), "{messages:?}");
    assert!(has("`x` is not a match or session number"), "{messages:?}");
    assert!(has("2 lists 2 team columns but only 1"), "{messages:?}");
  }

  #[test]
  fn not_a_schedule() {
    assert!(parse("").is_err());
    assert!(parse("name,number\nfoo,1\n").is_err());
  }
}
