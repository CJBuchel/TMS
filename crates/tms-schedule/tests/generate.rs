//! The generator against the tournament manual's space guidance, checked with the same schedule checks TMS runs on
//! a committed schedule.

use std::time::Instant;

use chrono::{TimeDelta, TimeZone, Utc};
use tms_core::validation::{IssueSeverity, Rules, ScheduleIssue, all_issues};
use tms_schedule::view::{Known, view};
use tms_schedule::{GenerateInput, TiabTeam, generate};
use uuid::Uuid;

/// Pods and tables for a team count, from the manual: a pod per six teams; two tables up to 16 teams, then four, then
/// six past 30.
fn input(teams: usize, seed: u64) -> GenerateInput {
  let pods = teams.div_ceil(6);
  let tables = match teams {
    0..=16 => 2,
    17..=30 => 4,
    _ => 6,
  };
  let start = Utc.with_ymd_and_hms(2026, 11, 14, 22, 30, 0).unwrap();
  GenerateInput {
    teams: (1..=teams)
      .map(|n| TiabTeam {
        number: n.to_string(),
        name: format!("Team {n}"),
        affiliation: String::new(),
      })
      .collect(),
    tables: (1..=tables).map(|t| format!("Table {t}")).collect(),
    pods: (1..=pods).map(|p| format!("Pod {p}")).collect(),
    match_start: start,
    match_cycle: TimeDelta::minutes(10),
    match_length: TimeDelta::seconds(150),
    practice_rounds: 1,
    ranking_rounds: 3,
    judging_start: start,
    session_length: TimeDelta::minutes(30),
    session_cycle: TimeDelta::minutes(45),
    judging_gap: TimeDelta::minutes(15),
    // Lunch, three hours in.
    breaks: vec![(
      start + TimeDelta::hours(3),
      start + TimeDelta::hours(3) + TimeDelta::minutes(45),
    )],
    seed,
  }
}

fn issues(input: &GenerateInput) -> (Vec<ScheduleIssue>, std::time::Duration) {
  let started = Instant::now();
  let generated = generate(input).unwrap();
  let elapsed = started.elapsed();
  let ids = |names: &[String]| -> Vec<(Uuid, String)> { names.iter().map(|n| (Uuid::now_v7(), n.clone())).collect() };
  let teams: Vec<(Uuid, String)> = input.teams.iter().map(|t| (Uuid::now_v7(), t.number.clone())).collect();
  let known = Known {
    teams: &teams,
    tables: &ids(&input.tables),
    pods: &ids(&input.pods),
    blocks: &[],
  };
  let v = view(&generated.schedule, &known);
  let rules = Rules {
    judging_gap: input.judging_gap,
    ranking_rounds: input.ranking_rounds,
    match_rest: TimeDelta::minutes(10),
  };
  (all_issues(&v, &rules), elapsed)
}

#[test]
fn every_size_from_6_to_40_teams_has_no_hard_issues() {
  for teams in [6, 7, 9, 12, 13, 16, 18, 20, 24, 25, 30, 31, 36, 40] {
    let (issues, elapsed) = issues(&input(teams, 1));
    let errors: Vec<&ScheduleIssue> = issues.iter().filter(|i| i.severity == IssueSeverity::Error).collect();
    assert!(errors.is_empty(), "{teams} teams: {errors:#?}");
    let warnings = issues.len();
    assert!(
      elapsed.as_secs_f64() < if cfg!(debug_assertions) { 3.0 } else { 1.0 },
      "{teams} teams took {elapsed:?}"
    );
    println!("{teams} teams: {warnings} warning(s) in {elapsed:?}");
  }
}

#[test]
fn the_same_seed_gives_the_same_schedule() {
  let a = generate(&input(18, 7)).unwrap();
  let b = generate(&input(18, 7)).unwrap();
  assert_eq!(a, b);
  assert_ne!(
    a,
    generate(&input(18, 8)).unwrap(),
    "another seed gives another schedule"
  );
}

#[test]
fn rounds_and_numbers_are_laid_out_like_an_import() {
  let g = generate(&input(13, 3)).unwrap();
  let practice = g
    .schedule
    .matches
    .iter()
    .filter(|m| m.kind == tms_core::model::MatchKind::Practice)
    .count();
  let ranking = g
    .schedule
    .matches
    .iter()
    .filter(|m| m.kind == tms_core::model::MatchKind::Ranking)
    .count();
  assert_eq!((practice, ranking), (7, 21), "13 teams on 2 tables: 7 matches a round");
  let first_ranking = g
    .schedule
    .matches
    .iter()
    .find(|m| m.kind == tms_core::model::MatchKind::Ranking)
    .unwrap();
  assert_eq!(first_ranking.number, 1);
  assert_eq!(g.schedule.sessions.len(), 13usize.div_ceil(3), "three pods");
  let lunch = (
    Utc.with_ymd_and_hms(2026, 11, 15, 1, 30, 0).unwrap(),
    Utc.with_ymd_and_hms(2026, 11, 15, 2, 15, 0).unwrap(),
  );
  assert!(
    g.schedule
      .matches
      .iter()
      .all(|m| m.end <= lunch.0 || m.start >= lunch.1),
    "nothing runs through lunch"
  );
}
