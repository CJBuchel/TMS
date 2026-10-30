//! Writes a schedule back out as a Tournament-in-a-Box CSV ("Version Number,1"), so other FIRST Australia tools can
//! read a schedule made or edited in TMS. Reading the file back gives the same schedule.

use chrono::{DateTime, NaiveDate, Utc};
use chrono_tz::Tz;
use tms_core::model::MatchKind;

use crate::resolve::{ResolvedMatch, ResolvedSchedule, ResolvedSlot};

/// `9:05:00 AM`, with a `Day n` label when the event runs over more than one day.
fn time(at: DateTime<Utc>, timezone: Tz, first_day: NaiveDate, multi_day: bool) -> String {
  let local = at.with_timezone(&timezone);
  let clock = local.format("%-I:%M:%S %p").to_string();
  if multi_day {
    format!("Day {} {clock}", (local.date_naive() - first_day).num_days() + 1)
  } else {
    clock
  }
}

fn cells(slots: &[ResolvedSlot], columns: &[String]) -> Vec<String> {
  columns
    .iter()
    .map(|c| {
      slots
        .iter()
        .find(|s| &s.column == c)
        .map(|s| s.team_number.clone())
        .unwrap_or_default()
    })
    .collect()
}

pub fn write(schedule: &ResolvedSchedule, timezone: Tz, first_day: NaiveDate) -> String {
  let mut out = csv::WriterBuilder::new().flexible(true).from_writer(Vec::new());
  let multi_day = schedule
    .matches
    .iter()
    .map(|m| m.start)
    .chain(schedule.sessions.iter().map(|s| s.start))
    .any(|t| t.with_timezone(&timezone).date_naive() != first_day);
  let at = |t: DateTime<Utc>| time(t, timezone, first_day, multi_day);
  let mut row = |cells: Vec<String>| {
    let _ = out.write_record(&cells);
  };
  let text = |items: &[&str]| items.iter().map(|s| (*s).to_owned()).collect::<Vec<String>>();

  row(text(&["Version Number", "1"]));
  row(text(&["Block Format", "1"]));
  row(vec!["Number of Teams".into(), schedule.teams.len().to_string()]);
  for t in &schedule.teams {
    row(vec![t.number.clone(), t.name.clone(), t.affiliation.clone()]);
  }

  let matches =
    |kind: MatchKind| -> Vec<&ResolvedMatch> { schedule.matches.iter().filter(|m| m.kind == kind).collect() };
  for (kind, format, count_label) in [
    (MatchKind::Ranking, "2", "Number of Ranking Matches"),
    (MatchKind::Practice, "4", "Number of Practice Matches"),
  ] {
    let list = matches(kind);
    if list.is_empty() {
      continue;
    }
    let per_match = list.iter().map(|m| m.slots.len()).max().unwrap_or(0);
    row(text(&["Block Format", format]));
    row(vec![count_label.into(), list.len().to_string()]);
    row(vec!["Number of Tables".into(), schedule.tables.len().to_string()]);
    row(vec!["Number of Teams per Table".into(), "1".into()]);
    row(vec!["Number of Simultaneous Tables".into(), per_match.to_string()]);
    let mut names = vec!["Table Names".to_owned()];
    names.extend(schedule.tables.iter().cloned());
    row(names);
    for m in list {
      let mut cells_out = vec![m.number.to_string(), at(m.start), at(m.end)];
      cells_out.extend(cells(&m.slots, &schedule.tables));
      row(cells_out);
    }
  }

  if !schedule.sessions.is_empty() {
    row(text(&["Block Format", "3"]));
    row(text(&["Number of Judged Events", "1"]));
    row(vec![
      "Number of Event Time Slots".into(),
      schedule.sessions.len().to_string(),
    ]);
    row(vec!["Number of Judging Teams".into(), schedule.rooms.len().to_string()]);
    let mut names = vec!["Room Names".to_owned()];
    names.extend(schedule.rooms.iter().cloned());
    row(names);
    for s in &schedule.sessions {
      let mut cells_out = vec![s.number.to_string(), at(s.start), at(s.end)];
      cells_out.extend(cells(&s.slots, &schedule.rooms));
      row(cells_out);
    }
  }
  String::from_utf8(out.into_inner().unwrap_or_default()).unwrap_or_default()
}
