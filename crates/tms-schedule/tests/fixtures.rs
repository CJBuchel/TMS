//! Real Tournament-in-a-Box exports (from the Legacy TMS test files).

use chrono::{NaiveDate, Timelike};
use chrono_tz::Tz;
use tms_core::model::MatchKind;
use tms_schedule::{parse, resolve};

const SINGLE: &str = include_str!("fixtures/single_day.csv");
const MULTI: &str = include_str!("fixtures/multi_day.csv");
const BROKEN: &str = include_str!("fixtures/broken_single_day.csv");

fn date(y: i32, m: u32, d: u32) -> NaiveDate {
  NaiveDate::from_ymd_opt(y, m, d).unwrap()
}

#[test]
fn single_day_file() {
  let file = parse(SINGLE).unwrap();
  assert_eq!(file.teams.len(), 40);
  assert_eq!(
    file.ranking.as_ref().unwrap().tables,
    vec!["Red", "Blue", "Pink", "Yellow", "Green", "Black"]
  );
  assert_eq!(file.ranking.as_ref().unwrap().matches.len(), 60);
  assert_eq!(file.judging.as_ref().unwrap().rooms.len(), 10);
  assert_eq!(file.judging.as_ref().unwrap().sessions.len(), 4);
  assert!(file.warnings.is_empty(), "{:?}", file.warnings);

  let perth: Tz = "Australia/Perth".parse().unwrap();
  let s = resolve(file, date(2026, 11, 14), date(2026, 11, 14), perth).unwrap();
  assert_eq!(s.days, vec![date(2026, 11, 14)]);
  assert_eq!(
    s.sessions.iter().map(|x| x.slots.len()).sum::<usize>(),
    40,
    "every team judged once"
  );

  // Perth is UTC+8: the first ranking match at 10:00 local is 02:00 UTC.
  let first = s
    .matches
    .iter()
    .filter(|m| m.kind == MatchKind::Ranking)
    .min_by_key(|m| m.start)
    .unwrap();
  assert_eq!(first.start.hour(), 2);

  // 60 matches with 2 teams each over 40 teams: every team plays 3 ranking rounds, numbered 1 to 3.
  let mut per_team = std::collections::HashMap::<&str, Vec<i32>>::new();
  for m in &s.matches {
    for slot in &m.slots {
      per_team.entry(&slot.team_number).or_default().push(slot.round.unwrap());
    }
  }
  assert_eq!(per_team.len(), 40);
  for rounds in per_team.values() {
    assert_eq!(rounds, &vec![1, 2, 3]);
  }
}

#[test]
fn multi_day_file_spreads_over_the_event_days() {
  let file = parse(MULTI).unwrap();
  assert_eq!(file.practice.as_ref().unwrap().matches.len(), 60);
  let utc: Tz = "UTC".parse().unwrap();

  let too_short = resolve(file.clone(), date(2026, 11, 14), date(2026, 11, 14), utc).unwrap_err();
  assert!(too_short[0].contains("covers 2 days"), "{too_short:?}");

  let s = resolve(file, date(2026, 11, 14), date(2026, 11, 15), utc).unwrap();
  assert_eq!(s.days, vec![date(2026, 11, 14), date(2026, 11, 15)]);
  let ranking: Vec<_> = s.matches.iter().filter(|m| m.kind == MatchKind::Ranking).collect();
  let practice: Vec<_> = s.matches.iter().filter(|m| m.kind == MatchKind::Practice).collect();
  assert_eq!((ranking.len(), practice.len()), (60, 60));
  assert!(
    ranking.iter().any(|m| m.start.date_naive() == date(2026, 11, 15)),
    "day 2 matches land on the second day"
  );
  // This file gives every team three practice matches; rounds count separately per kind, in time order.
  let mut practice_rounds = std::collections::HashMap::<&str, Vec<i32>>::new();
  let mut in_order = practice.clone();
  in_order.sort_by_key(|m| m.start);
  for m in in_order {
    for slot in &m.slots {
      practice_rounds
        .entry(&slot.team_number)
        .or_default()
        .push(slot.round.unwrap());
    }
  }
  assert_eq!(practice_rounds.len(), 40);
  assert!(
    practice_rounds.values().all(|r| r == &vec![1, 2, 3]),
    "{practice_rounds:?}"
  );
}

#[test]
fn broken_file_imports_with_a_warning() {
  // Missing trailing commas are fine; the last judging session leaves three teams without one.
  let file = parse(BROKEN).unwrap();
  assert_eq!(file.teams.len(), 40);
  assert!(
    file
      .warnings
      .iter()
      .any(|w| w == "teams with no judging session: 9, 13, 19"),
    "{:?}",
    file.warnings
  );
}

/// A real 40-team export has no errors under the schedule checks. Its only findings are warnings: teams meeting the
/// same opponent twice, which this scheduler doesn't avoid.
#[test]
fn a_real_export_passes_the_schedule_checks() {
  use tms_core::validation::{IssueCode, IssueSeverity, Rules, all_issues};
  use tms_schedule::view::{Known, view};
  let perth: Tz = "Australia/Perth".parse().unwrap();
  let s = resolve(parse(SINGLE).unwrap(), date(2026, 11, 14), date(2026, 11, 14), perth).unwrap();
  let teams: Vec<(uuid::Uuid, String)> = s
    .teams
    .iter()
    .map(|t| (uuid::Uuid::now_v7(), t.number.clone()))
    .collect();
  let known = Known {
    teams: &teams,
    tables: &[],
    pods: &[],
    blocks: &[],
  };
  let rules = Rules {
    judging_gap: chrono::TimeDelta::minutes(10),
    ranking_rounds: 3,
    match_rest: chrono::TimeDelta::minutes(10),
  };
  let issues = all_issues(&view(&s, &known), &rules);
  let mut summary: Vec<(IssueCode, IssueSeverity)> = issues.iter().map(|i| (i.code, i.severity)).collect();
  summary.sort();
  summary.dedup();
  assert_eq!(summary, [(IssueCode::SameOpponent, IssueSeverity::Warning)]);
  assert_eq!(issues[0].message, "Team 17 meets team 23 in two ranking matches.");
}

#[test]
fn written_files_read_back_the_same() {
  for (text, last_day, tz) in [
    (SINGLE, date(2026, 11, 14), "Australia/Perth"),
    (MULTI, date(2026, 11, 15), "UTC"),
  ] {
    let tz: Tz = tz.parse().unwrap();
    let first = resolve(parse(text).unwrap(), date(2026, 11, 14), last_day, tz).unwrap();
    let written = tms_schedule::write::write(&first, tz, date(2026, 11, 14));
    let again = resolve(parse(&written).unwrap(), date(2026, 11, 14), last_day, tz).unwrap();
    assert_eq!(again.teams, first.teams);
    assert_eq!(again.matches, first.matches);
    assert_eq!(again.sessions, first.sessions);
    assert_eq!(again.days, first.days);
  }
}
