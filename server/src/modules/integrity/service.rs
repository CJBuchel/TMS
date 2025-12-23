use std::{
  collections::{HashMap, HashSet},
  sync::RwLock,
  time::Duration,
};

use anyhow::Result;
use database::Database;
use once_cell::sync::Lazy;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, EVENT_BUS},
    integrity::IntegrityMessageBuilder,
    scheduler::ScheduledService,
  },
  generated::{
    common::{IntegrityCode, IntegrityMessage},
    db::{GameMatch, JudgingSession, PodName, TableName, Team},
  },
  modules::{
    game_match::GAME_MATCH_TABLE_NAME, judging_session::JUDGING_SESSION_TABLE_NAME, pod_name::POD_TABLE_NAME,
    table_name::TABLE_TABLE_NAME, team::TEAM_TABLE_NAME,
  },
};

/// Cached integrity check results
static INTEGRITY_CACHE: Lazy<RwLock<Vec<IntegrityMessage>>> = Lazy::new(|| RwLock::new(Vec::new()));

/// IntegrityChecker - runs validation checks on tournament data
pub struct IntegrityChecker {
  messages: Vec<IntegrityMessage>,

  // Minimal state for checks that need tracking
  team_numbers_seen: HashSet<String>,
  team_names_seen: HashSet<String>,
  match_numbers_seen: HashSet<String>,
  session_numbers_seen: HashSet<String>,

  // Aggregation state
  max_match_count: usize,
}

impl IntegrityChecker {
  // ===== Helper Methods (declared first) =====

  fn count_team_matches(db: &Database, team_id: &str) -> Result<usize> {
    let mut count = 0;
    for result in db.get_table(GAME_MATCH_TABLE_NAME).scan::<GameMatch>() {
      let (_, game_match) = result?;
      if game_match.assignments.iter().any(|a| a.team_id == team_id) {
        count += 1;
      }
    }
    Ok(count)
  }

  fn count_team_sessions(db: &Database, team_id: &str) -> Result<usize> {
    let mut count = 0;
    for result in db.get_table(JUDGING_SESSION_TABLE_NAME).scan::<JudgingSession>() {
      let (_, session) = result?;
      if session.assignments.iter().any(|a| a.team_id == team_id) {
        count += 1;
      }
    }
    Ok(count)
  }

  fn team_exists(db: &Database, team_id: &str) -> Result<bool> {
    Ok(db.get_table(TEAM_TABLE_NAME).get::<Team>(team_id)?.is_some())
  }

  fn table_exists(db: &Database, table_id: &str) -> Result<bool> {
    Ok(db.get_table(TABLE_TABLE_NAME).get::<TableName>(table_id)?.is_some())
  }

  fn pod_exists(db: &Database, pod_id: &str) -> Result<bool> {
    Ok(db.get_table(POD_TABLE_NAME).get::<PodName>(pod_id)?.is_some())
  }

  fn get_team_number(db: &Database, team_id: &str) -> Result<String> {
    match db.get_table(TEAM_TABLE_NAME).get::<Team>(team_id)? {
      Some(team) => Ok(team.team_number),
      None => Ok(format!("<unknown:{}>", team_id)),
    }
  }

  fn get_table_name(db: &Database, table_id: &str) -> Result<String> {
    match db.get_table(TABLE_TABLE_NAME).get::<TableName>(table_id)? {
      Some(table) => Ok(table.table_name),
      None => Ok(format!("<unknown:{}>", table_id)),
    }
  }

  fn get_pod_name(db: &Database, pod_id: &str) -> Result<String> {
    match db.get_table(POD_TABLE_NAME).get::<PodName>(pod_id)? {
      Some(pod) => Ok(pod.pod_name),
      None => Ok(format!("<unknown:{}>", pod_id)),
    }
  }

  fn datetime_to_seconds(dt: &crate::generated::common::TmsDateTime) -> i64 {
    let mut seconds: i64 = 0;

    // Add date component (rough approximation: days from year 2000)
    if let Some(date) = &dt.date {
      let days_from_2000 = (date.year - 2000) * 365 + date.month * 30 + date.day;
      seconds += i64::from(days_from_2000) * 24 * 60 * 60;
    }

    // Add time component
    if let Some(time) = &dt.time {
      seconds += i64::from(time.hour) * 60 * 60;
      seconds += i64::from(time.minute) * 60;
      seconds += i64::from(time.second);
    }

    seconds
  }

  fn time_before(t1: &crate::generated::common::TmsDateTime, t2: &crate::generated::common::TmsDateTime) -> bool {
    // Compare dates first
    match (&t1.date, &t2.date) {
      (Some(d1), Some(d2)) => {
        if d1.year != d2.year {
          return d1.year < d2.year;
        }
        if d1.month != d2.month {
          return d1.month < d2.month;
        }
        if d1.day != d2.day {
          return d1.day < d2.day;
        }
      }
      _ => return false, // Can't compare if date missing
    }

    // Dates are equal, compare times
    match (&t1.time, &t2.time) {
      (Some(time1), Some(time2)) => {
        if time1.hour != time2.hour {
          return time1.hour < time2.hour;
        }
        if time1.minute != time2.minute {
          return time1.minute < time2.minute;
        }
        time1.second < time2.second
      }
      _ => false, // Times equal or missing
    }
  }

  fn time_diff_seconds(t1: &crate::generated::common::TmsDateTime, t2: &crate::generated::common::TmsDateTime) -> i64 {
    // Convert both times to total seconds (rough approximation)
    let t1_seconds = Self::datetime_to_seconds(t1);
    let t2_seconds = Self::datetime_to_seconds(t2);
    (t2_seconds - t1_seconds).abs()
  }

  fn times_overlap(
    match_start: &crate::generated::common::TmsDateTime,
    match_end: &crate::generated::common::TmsDateTime,
    session_start: &crate::generated::common::TmsDateTime,
    session_end: &crate::generated::common::TmsDateTime,
  ) -> bool {
    // Check if intervals overlap: [match_start, match_end] and [session_start, session_end]
    // They overlap if: match_start < session_end AND session_start < match_end
    Self::time_before(match_start, session_end) && Self::time_before(session_start, match_end)
  }

  fn times_within_10_minutes(
    match_start: &crate::generated::common::TmsDateTime,
    match_end: &crate::generated::common::TmsDateTime,
    session_start: &crate::generated::common::TmsDateTime,
    session_end: &crate::generated::common::TmsDateTime,
  ) -> bool {
    // Check if match ends within 10 minutes before session starts
    // OR match starts within 10 minutes after session ends
    let ten_minutes_seconds = 10 * 60;

    // Match ends, then session starts
    if Self::time_before(match_end, session_start) {
      let diff = Self::time_diff_seconds(match_end, session_start);
      if diff <= ten_minutes_seconds {
        return true;
      }
    }

    // Session ends, then match starts
    if Self::time_before(session_end, match_start) {
      let diff = Self::time_diff_seconds(session_end, match_start);
      if diff <= ten_minutes_seconds {
        return true;
      }
    }

    false
  }

  fn add<F>(&mut self, code: IntegrityCode, build: F)
  where
    F: FnOnce(IntegrityMessageBuilder) -> IntegrityMessageBuilder,
  {
    let builder = IntegrityMessageBuilder::new(code);
    self.messages.push(build(builder).build());
  }

  // ===== Check Implementation Methods =====

  /// E013, W009: Check for time overlaps between match and judging sessions
  fn check_match_time_overlaps(&mut self, db: &Database, game_match: &GameMatch) -> Result<()> {
    let sessions_table = db.get_table(JUDGING_SESSION_TABLE_NAME);

    // Get all team IDs in this match
    let team_ids: HashSet<_> = game_match.assignments.iter().map(|a| a.team_id.clone()).collect();

    // Check each session
    for result in sessions_table.scan::<JudgingSession>() {
      let (_, session) = result?;

      // Check if any team in the match is also in this session
      for assignment in &session.assignments {
        if team_ids.contains(&assignment.team_id) {
          let team_number = Self::get_team_number(db, &assignment.team_id)?;

          // Check time overlap
          if let (Some(match_start), Some(match_end), Some(session_start), Some(session_end)) =
            (&game_match.start_time, &game_match.end_time, &session.start_time, &session.end_time)
          {
            // E013: Direct overlap
            if Self::times_overlap(match_start, match_end, session_start, session_end) {
              self.add(IntegrityCode::E013, |b| {
                b.team(&team_number).match_num(&game_match.match_number).session(&session.session_number)
              });
            }
            // W009: Within 10 minutes
            else if Self::times_within_10_minutes(match_start, match_end, session_start, session_end) {
              self.add(IntegrityCode::W009, |b| {
                b.team(&team_number).match_num(&game_match.match_number).session(&session.session_number)
              });
            }
          }
        }
      }
    }

    Ok(())
  }

  /// Check that all pod names are valid
  #[allow(clippy::unused_self)]
  fn check_pods(&mut self, _db: &Database) {
    // Pod-specific checks if needed
  }

  /// Check that all table names are valid
  #[allow(clippy::unused_self)]
  fn check_tables(&mut self, _db: &Database) {
    // Table-specific checks if needed
  }

  /// Check judging sessions for E008, E009, E012, W010, W011-W018
  fn check_sessions(&mut self, db: &Database) -> Result<()> {
    let sessions_table = db.get_table(JUDGING_SESSION_TABLE_NAME);

    for result in sessions_table.scan::<JudgingSession>() {
      let (_, session) = result?;

      // E012: Duplicate session number
      if !self.session_numbers_seen.insert(session.session_number.clone()) {
        self.add(IntegrityCode::E012, |b| b.session(&session.session_number));
      }

      // W010: No pods or teams found in session
      if session.assignments.is_empty() {
        self.add(IntegrityCode::W010, |b| b.session(&session.session_number));
      }

      for assignment in &session.assignments {
        // E008: Pod doesn't exist
        if !Self::pod_exists(db, &assignment.pod_id)? {
          let pod_name = Self::get_pod_name(db, &assignment.pod_id)?;
          let team_number = Self::get_team_number(db, &assignment.team_id)?;
          self.add(IntegrityCode::E008, |b| b.team(&team_number).session(&session.session_number).pod(&pod_name));
        }

        // E009: Team doesn't exist
        if !Self::team_exists(db, &assignment.team_id)? {
          let team_number = Self::get_team_number(db, &assignment.team_id)?;
          self.add(IntegrityCode::E009, |b| b.team(&team_number).session(&session.session_number));
        }

        let team_number = Self::get_team_number(db, &assignment.team_id)?;

        // W011: Session complete but no core values score
        if session.complete && !assignment.core_values_submitted {
          self.add(IntegrityCode::W011, |b| b.team(&team_number).session(&session.session_number));
        }

        // W012: Session complete but no innovation score
        if session.complete && !assignment.innovation_submitted {
          self.add(IntegrityCode::W012, |b| b.team(&team_number).session(&session.session_number));
        }

        // W013: Session complete but no robot design score
        if session.complete && !assignment.robot_design_submitted {
          self.add(IntegrityCode::W013, |b| b.team(&team_number).session(&session.session_number));
        }

        // W014: Session not complete but core values submitted
        if !session.complete && assignment.core_values_submitted {
          self.add(IntegrityCode::W014, |b| b.team(&team_number).session(&session.session_number));
        }

        // W015: Session not complete but innovation submitted
        if !session.complete && assignment.innovation_submitted {
          self.add(IntegrityCode::W015, |b| b.team(&team_number).session(&session.session_number));
        }

        // W016: Session not complete but robot design submitted
        if !session.complete && assignment.robot_design_submitted {
          self.add(IntegrityCode::W016, |b| b.team(&team_number).session(&session.session_number));
        }

        // W017: Blank pod in session
        if assignment.pod_id.is_empty() {
          self.add(IntegrityCode::W017, |b| b.team(&team_number).session(&session.session_number));
        }

        // W018: No team in pod
        if assignment.team_id.is_empty() {
          self.add(IntegrityCode::W018, |b| b.session(&session.session_number));
        }
      }
    }

    Ok(())
  }

  /// Check matches for E004, E005, E006, W004, W005, W006, W007, W008
  fn check_matches(&mut self, db: &Database) -> Result<()> {
    let matches_table = db.get_table(GAME_MATCH_TABLE_NAME);

    for result in matches_table.scan::<GameMatch>() {
      let (_, game_match) = result?;

      // E006: Duplicate match number
      if !self.match_numbers_seen.insert(game_match.match_number.clone()) {
        self.add(IntegrityCode::E006, |b| b.match_num(&game_match.match_number));
      }

      // W004: No tables or teams found in match
      if game_match.assignments.is_empty() {
        self.add(IntegrityCode::W004, |b| b.match_num(&game_match.match_number));
      }

      for assignment in &game_match.assignments {
        // E004: Table doesn't exist
        if !Self::table_exists(db, &assignment.table_id)? {
          let table_name = Self::get_table_name(db, &assignment.table_id)?;
          let team_number = Self::get_team_number(db, &assignment.team_id)?;
          self
            .add(IntegrityCode::E004, |b| b.team(&team_number).match_num(&game_match.match_number).table(&table_name));
        }

        // E005: Team doesn't exist
        if !Self::team_exists(db, &assignment.team_id)? {
          let team_number = Self::get_team_number(db, &assignment.team_id)?;
          self.add(IntegrityCode::E005, |b| b.team(&team_number).match_num(&game_match.match_number));
        }

        // W005: Match complete but score not submitted
        if game_match.completed && !assignment.score_submitted {
          let team_number = Self::get_team_number(db, &assignment.team_id)?;
          self.add(IntegrityCode::W005, |b| b.team(&team_number).match_num(&game_match.match_number));
        }

        // W006: Match not complete but score submitted
        if !game_match.completed && assignment.score_submitted {
          let team_number = Self::get_team_number(db, &assignment.team_id)?;
          self.add(IntegrityCode::W006, |b| b.team(&team_number).match_num(&game_match.match_number));
        }

        // W007: Blank table in match
        if assignment.table_id.is_empty() {
          let team_number = Self::get_team_number(db, &assignment.team_id)?;
          self.add(IntegrityCode::W007, |b| b.team(&team_number).match_num(&game_match.match_number));
        }

        // W008: No team on table
        if assignment.team_id.is_empty() {
          self.add(IntegrityCode::W008, |b| b.match_num(&game_match.match_number));
        }
      }

      // E013, W009: Time overlap checks
      self.check_match_time_overlaps(db, &game_match)?;
    }

    Ok(())
  }

  /// Check teams for E001, E002, E003, E007, E010, E011, W001, W002, W003
  fn check_teams(&mut self, db: &Database) -> Result<()> {
    let teams_table = db.get_table(TEAM_TABLE_NAME);

    for result in teams_table.scan::<Team>() {
      let (team_id, team) = result?;

      // E001: Missing team number
      if team.team_number.is_empty() {
        self.add(IntegrityCode::E001, |b| b.team(&team.team_number));
      }

      // E002: Duplicate team number
      if !self.team_numbers_seen.insert(team.team_number.clone()) {
        self.add(IntegrityCode::E002, |b| b.team(&team.team_number));
      }

      // W001: Missing team name
      if team.name.is_empty() {
        self.add(IntegrityCode::W001, |b| b.team(&team.team_number));
      }

      // W002: Duplicate team name
      if !team.name.is_empty() && !self.team_names_seen.insert(team.name.clone()) {
        self.add(IntegrityCode::W002, |b| b.team(&team.team_number));
      }

      // E007: Team has fewer matches than max
      let team_match_count = Self::count_team_matches(db, &team_id)?;
      if team_match_count > 0 && team_match_count < self.max_match_count {
        self.add(IntegrityCode::E007, |b| b.team(&team.team_number));
      }

      // E010, E011: Judging session count checks
      let session_count = Self::count_team_sessions(db, &team_id)?;
      if session_count > 1 {
        self.add(IntegrityCode::E010, |b| b.team(&team.team_number));
      } else if session_count == 0 {
        self.add(IntegrityCode::E011, |b| b.team(&team.team_number));
      }

      // E003, W003: Score checks (if you have scores table)
      // TODO: Implement once scores table structure is defined
    }

    Ok(())
  }

  /// Pre-compute max match count for E007 check
  fn compute_max_match_count(&mut self, db: &Database) -> Result<()> {
    let mut team_match_counts: HashMap<String, usize> = HashMap::new();

    for result in db.get_table(GAME_MATCH_TABLE_NAME).scan::<GameMatch>() {
      let (_, game_match) = result?;
      for assignment in &game_match.assignments {
        *team_match_counts.entry(assignment.team_id.clone()).or_insert(0) += 1;
      }
    }

    self.max_match_count = team_match_counts.values().max().copied().unwrap_or(0);
    Ok(())
  }

  // ===== Public API =====

  /// Run all integrity checks and publish results to event bus
  pub fn check_and_publish() -> Result<Vec<IntegrityMessage>> {
    let messages = Self::check_all()?;

    // Update cache
    if let Ok(mut cache) = INTEGRITY_CACHE.write() {
      cache.clone_from(&messages);
    }

    // Publish to event bus
    if let Some(event_bus) = EVENT_BUS.get() {
      // Publish a "Table" event to signal complete refresh of integrity messages
      event_bus.publish(ChangeEvent::<IntegrityMessage>::Table)?;
    }

    Ok(messages)
  }

  /// Get cached integrity check results (fast, doesn't run checks)
  pub fn get_cached() -> Vec<IntegrityMessage> {
    INTEGRITY_CACHE.read().ok().map(|cache| cache.clone()).unwrap_or_default()
  }

  /// Run all integrity checks on the database (doesn't publish to event bus)
  pub fn check_all() -> Result<Vec<IntegrityMessage>> {
    let db = get_db()?;
    let mut checker = Self {
      messages: Vec::new(),
      team_numbers_seen: HashSet::new(),
      team_names_seen: HashSet::new(),
      match_numbers_seen: HashSet::new(),
      session_numbers_seen: HashSet::new(),
      max_match_count: 0,
    };

    // Pre-compute aggregations
    checker.compute_max_match_count(db)?;

    // Run checks organized by entity type
    checker.check_teams(db)?;
    checker.check_matches(db)?;
    checker.check_sessions(db)?;
    checker.check_tables(db);
    checker.check_pods(db);

    Ok(checker.messages)
  }
}

/// Scheduled service that runs integrity checks periodically
pub struct IntegrityCheckService {
  interval: Duration,
}

impl IntegrityCheckService {
  pub fn new(interval: Duration) -> Self {
    Self { interval }
  }

  /// Create with default 30-second interval
  pub fn with_default_interval() -> Self {
    Self::new(Duration::from_secs(30))
  }
}

impl ScheduledService for IntegrityCheckService {
  fn interval(&self) -> Duration {
    self.interval
  }

  fn name(&self) -> &'static str {
    "IntegrityCheck"
  }

  fn warning_threshold(&self) -> Option<Duration> {
    // Warn if integrity check takes longer than 1 second
    Some(Duration::from_secs(1))
  }

  fn execute(&mut self) -> Result<()> {
    let messages = IntegrityChecker::check_and_publish()?;

    let error_count = messages.iter().filter(|m| m.severity == 1).count();
    let warning_count = messages.iter().filter(|m| m.severity == 2).count();

    if error_count > 0 || warning_count > 0 {
      log::info!("[IntegrityCheck] Found {} errors, {} warnings", error_count, warning_count);
    } else {
      log::debug!("[IntegrityCheck] No issues found");
    }

    Ok(())
  }
}
