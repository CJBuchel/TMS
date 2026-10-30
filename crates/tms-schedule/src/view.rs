//! A proposed schedule (imported or generated) as the schedule checks see it, so a preview lists the same issues the
//! schedule would have once committed.

use tms_core::model::{GameMatch, JudgingSession, JudgingSlot, MatchSlot, MatchState, QueueState, ScheduleBlock};
use tms_core::validation::ScheduleView;
use uuid::Uuid;

use crate::resolve::ResolvedSchedule;

/// Ids for names TMS already knows; anything new gets a stand-in id.
pub struct Known<'a> {
  /// Every team in the event, by id and number.
  pub teams: &'a [(Uuid, String)],
  /// Tables in their paired order.
  pub tables: &'a [(Uuid, String)],
  pub pods: &'a [(Uuid, String)],
  pub blocks: &'a [ScheduleBlock],
}

pub fn view(resolved: &ResolvedSchedule, known: &Known<'_>) -> ScheduleView {
  let mut counter: u128 = 0;
  let mut fresh = || {
    counter += 1;
    Uuid::from_u128(counter)
  };
  let mut teams: Vec<(Uuid, String)> = known.teams.to_vec();
  for t in &resolved.teams {
    if !teams.iter().any(|(_, n)| *n == t.number) {
      teams.push((fresh(), t.number.clone()));
    }
  }
  let mut tables: Vec<(Uuid, String)> = known.tables.to_vec();
  for name in &resolved.tables {
    if !tables.iter().any(|(_, n)| n == name) {
      tables.push((fresh(), name.clone()));
    }
  }
  let mut pods: Vec<(Uuid, String)> = known.pods.to_vec();
  for name in &resolved.rooms {
    if !pods.iter().any(|(_, n)| n == name) {
      pods.push((fresh(), name.clone()));
    }
  }
  let id_of = |list: &[(Uuid, String)], name: &str| list.iter().find(|(_, n)| n == name).map(|(id, _)| *id);
  let matches = resolved
    .matches
    .iter()
    .map(|m| GameMatch {
      id: fresh(),
      event_id: Uuid::nil(),
      kind: m.kind,
      number: m.number,
      scheduled_start: m.start,
      scheduled_end: m.end,
      state: MatchState::Scheduled,
      started_at: None,
      finished_at: None,
      slots: m
        .slots
        .iter()
        .map(|s| MatchSlot {
          id: Uuid::nil(),
          table_id: id_of(&tables, &s.column).unwrap_or_default(),
          team_id: id_of(&teams, &s.team_number),
          round: s.round,
          sheet: None,
          queue: QueueState::NotCalled,
          queue_previous: None,
          queue_changed_at: None,
        })
        .collect(),
    })
    .collect();
  let sessions = resolved
    .sessions
    .iter()
    .map(|s| JudgingSession {
      id: fresh(),
      event_id: Uuid::nil(),
      number: s.number,
      scheduled_start: s.start,
      scheduled_end: s.end,
      slots: s
        .slots
        .iter()
        .map(|slot| JudgingSlot {
          id: Uuid::nil(),
          pod_id: id_of(&pods, &slot.column).unwrap_or_default(),
          team_id: id_of(&teams, &slot.team_number),
          queue: QueueState::NotCalled,
          queue_previous: None,
          rubric: None,
        })
        .collect(),
    })
    .collect();
  ScheduleView {
    teams,
    tables: tables.into_iter().map(|(id, _)| id).collect(),
    matches,
    sessions,
    blocks: known.blocks.to_vec(),
  }
}
