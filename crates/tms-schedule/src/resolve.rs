//! Places a parsed file on the event's calendar: day labels become dates, local times become UTC instants, and
//! every team's matches are numbered into rounds.

use std::collections::HashMap;

use chrono::{DateTime, NaiveDate, TimeZone, Utc};
use chrono_tz::Tz;
use tms_core::model::MatchKind;

use crate::tiab::{TiabFile, TiabRow, TiabTeam, TiabTime};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ResolvedSlot {
  pub column: String,
  pub team_number: String,
  /// For matches: which of the team's matches of this kind this is, from 1.
  pub round: Option<i32>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ResolvedMatch {
  pub kind: MatchKind,
  pub number: i32,
  pub start: DateTime<Utc>,
  pub end: DateTime<Utc>,
  pub slots: Vec<ResolvedSlot>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ResolvedSession {
  pub number: i32,
  pub start: DateTime<Utc>,
  pub end: DateTime<Utc>,
  pub slots: Vec<ResolvedSlot>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ResolvedSchedule {
  pub teams: Vec<TiabTeam>,
  /// Ranking tables in file order, then any table that only appears in practice.
  pub tables: Vec<String>,
  pub rooms: Vec<String>,
  pub matches: Vec<ResolvedMatch>,
  pub sessions: Vec<ResolvedSession>,
  pub days: Vec<NaiveDate>,
  pub warnings: Vec<String>,
}

/// Day labels are taken in order of first appearance: the first label is the event's first day, the next the
/// second, and so on. Rows without a label are on the first day.
pub fn resolve(
  file: TiabFile,
  first_day: NaiveDate,
  last_day: NaiveDate,
  timezone: Tz,
) -> Result<ResolvedSchedule, Vec<String>> {
  let mut errors = Vec::new();

  let all_rows = file
    .practice
    .iter()
    .chain(file.ranking.iter())
    .flat_map(|b| &b.matches)
    .chain(file.judging.iter().flat_map(|b| &b.sessions));
  let mut labels: Vec<Option<String>> = Vec::new();
  for row in all_rows {
    for t in [&row.start, &row.end] {
      if !labels.contains(&t.day) {
        labels.push(t.day.clone());
      }
    }
  }
  // An unlabeled time belongs to the first day, which may also have a label.
  labels.retain(Option::is_some);
  let event_days = (last_day - first_day).num_days() + 1;
  let day_count = i64::try_from(labels.len().max(1)).unwrap_or(i64::MAX);
  if day_count > event_days {
    errors.push(format!(
      "the schedule covers {day_count} days but the event is {event_days} day(s) long; change the event's end date first"
    ));
  }
  let days: Vec<NaiveDate> = (0..day_count)
    .map(|i| first_day + chrono::Days::new(u64::try_from(i).unwrap_or(0)))
    .collect();

  let instant = |t: &TiabTime, line: u64, errors: &mut Vec<String>| -> DateTime<Utc> {
    let index = t
      .day
      .as_ref()
      .and_then(|d| labels.iter().position(|l| l.as_ref() == Some(d)))
      .unwrap_or(0);
    let date = days.get(index).copied().unwrap_or(first_day);
    let Some(local) = timezone.from_local_datetime(&date.and_time(t.time)).earliest() else {
      errors.push(format!(
        "line {line}: {} {} does not exist in {timezone} (clock change)",
        date, t.time
      ));
      return DateTime::<Utc>::MIN_UTC;
    };
    local.with_timezone(&Utc)
  };

  let mut tables: Vec<String> = file.ranking.as_ref().map(|b| b.tables.clone()).unwrap_or_default();
  for name in file.practice.iter().flat_map(|b| &b.tables) {
    if !tables.contains(name) {
      tables.push(name.clone());
    }
  }

  let mut matches = Vec::new();
  for (kind, block) in [
    (MatchKind::Practice, &file.practice),
    (MatchKind::Ranking, &file.ranking),
  ] {
    let Some(block) = block else { continue };
    let mut keyed: Vec<(DateTime<Utc>, &TiabRow)> = block
      .matches
      .iter()
      .map(|r| (instant(&r.start, r.line, &mut errors), r))
      .collect();
    keyed.sort_by_key(|(start, r)| (*start, r.number));
    let mut appearances: HashMap<&str, i32> = HashMap::new();
    for (start, row) in keyed {
      let slots = row
        .teams
        .iter()
        .zip(&block.tables)
        .filter_map(|(team, table)| {
          let team = team.as_ref()?;
          let round = appearances.entry(team.as_str()).or_insert(0);
          *round += 1;
          Some(ResolvedSlot {
            column: table.clone(),
            team_number: team.clone(),
            round: Some(*round),
          })
        })
        .collect();
      matches.push(ResolvedMatch {
        kind,
        number: row.number,
        start,
        end: instant(&row.end, row.line, &mut errors),
        slots,
      });
    }
  }

  let mut sessions = Vec::new();
  if let Some(judging) = &file.judging {
    for row in &judging.sessions {
      let slots = row
        .teams
        .iter()
        .zip(&judging.rooms)
        .filter_map(|(team, room)| {
          Some(ResolvedSlot {
            column: room.clone(),
            team_number: team.clone()?,
            round: None,
          })
        })
        .collect();
      sessions.push(ResolvedSession {
        number: row.number,
        start: instant(&row.start, row.line, &mut errors),
        end: instant(&row.end, row.line, &mut errors),
        slots,
      });
    }
  }

  if !errors.is_empty() {
    return Err(errors);
  }
  Ok(ResolvedSchedule {
    teams: file.teams,
    tables,
    rooms: file.judging.map(|j| j.rooms).unwrap_or_default(),
    matches,
    sessions,
    days,
    warnings: file.warnings,
  })
}
