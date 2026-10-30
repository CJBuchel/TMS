//! The live list of schedule issues. Committing a schedule checks everything; an edit re-checks only the teams it
//! touched plus the event-wide checks, and pushes just the issues that changed.

use std::collections::{BTreeSet, HashMap};
use std::sync::Mutex;

use sqlx::{PgConnection, PgPool};
use tms_core::Topic;
use tms_core::validation::{Rules, ScheduleIssue, ScheduleView, all_issues, scoped_issues};
use tms_core::ws::TopicItem;
use uuid::Uuid;

use crate::bus::Bus;
use crate::repo::{blocks, events, schedule, teams, venue};

/// The event's schedule as the checks see it, and the event's rules.
pub async fn load_view(conn: &mut PgConnection, event_id: Uuid) -> sqlx::Result<(ScheduleView, Rules)> {
  let settings = events::get(&mut *conn, event_id)
    .await?
    .map(|e| e.settings)
    .unwrap_or_default();
  let view = ScheduleView::new(
    &teams::list(&mut *conn, event_id).await?,
    &venue::tables(&mut *conn, event_id).await?,
    &schedule::matches(&mut *conn, event_id).await?,
    &schedule::sessions(&mut *conn, event_id).await?,
    &blocks::list(&mut *conn, event_id).await?,
  );
  Ok((view, Rules::from_settings(&settings)))
}

pub struct IssueHub {
  bus: Bus,
  events: Mutex<HashMap<Uuid, Vec<ScheduleIssue>>>,
}

impl IssueHub {
  pub fn new(bus: Bus) -> Self {
    Self {
      bus,
      events: Mutex::default(),
    }
  }

  fn cached(&self, event_id: Uuid) -> Option<Vec<ScheduleIssue>> {
    self.events.lock().ok()?.get(&event_id).cloned()
  }

  fn store(&self, event_id: Uuid, issues: Vec<ScheduleIssue>) {
    if let Ok(mut events) = self.events.lock() {
      events.insert(event_id, issues);
    }
  }

  /// The event's issues; the first call for an event checks its whole schedule.
  pub async fn list(&self, pool: &PgPool, event_id: Uuid) -> sqlx::Result<Vec<ScheduleIssue>> {
    if let Some(issues) = self.cached(event_id) {
      return Ok(issues);
    }
    let (view, rules) = load_view(&mut *pool.acquire().await?, event_id).await?;
    let issues = all_issues(&view, &rules);
    self.store(event_id, issues.clone());
    Ok(issues)
  }

  /// Checks the whole schedule, after it was replaced or the rules changed.
  pub async fn refresh_all(&self, pool: &PgPool, event_id: Uuid, active: bool) -> sqlx::Result<()> {
    let (view, rules) = load_view(&mut *pool.acquire().await?, event_id).await?;
    self.store(event_id, all_issues(&view, &rules));
    tracing::debug!(%event_id, "schedule issues: checked the whole schedule");
    if active {
      self.bus.resnapshot(Topic::Issues);
    }
    Ok(())
  }

  /// Re-checks the given teams and the event-wide checks, and pushes what changed.
  pub async fn refresh_teams(
    &self,
    pool: &PgPool,
    event_id: Uuid,
    teams: &BTreeSet<Uuid>,
    active: bool,
  ) -> sqlx::Result<()> {
    let Some(old) = self.cached(event_id) else {
      return self.refresh_all(pool, event_id, active).await;
    };
    let (view, rules) = load_view(&mut *pool.acquire().await?, event_id).await?;
    let fresh = scoped_issues(&view, &rules, teams);
    let in_scope = |i: &ScheduleIssue| i.team_id.is_none_or(|t| teams.contains(&t));
    let (stale, kept): (Vec<ScheduleIssue>, Vec<ScheduleIssue>) = old.into_iter().partition(|i| in_scope(i));
    tracing::debug!(%event_id, teams = teams.len(), "schedule issues: re-checked the teams an edit touched");
    if active {
      for gone in stale.iter().filter(|s| !fresh.iter().any(|f| f.id == s.id)) {
        self.bus.delete(Topic::Issues, gone.id);
      }
      for issue in fresh.iter().filter(|f| !stale.contains(f)) {
        self.bus.upsert(Topic::Issues, TopicItem::Issue(issue.clone()));
      }
    }
    let mut all = kept;
    all.extend(fresh);
    self.store(event_id, all);
    Ok(())
  }
}
