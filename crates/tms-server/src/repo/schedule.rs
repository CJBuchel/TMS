//! Matches and judging sessions, each read together with its slots.

use std::collections::HashMap;

use chrono::{DateTime, Utc};
use sqlx::{PgConnection, PgExecutor};
use tms_core::judging::RubricStatus;
use tms_core::model::{
  GameMatch, JudgingSession, JudgingSlot, MatchKind, MatchSlot, MatchState, QueueState, ScoresheetStatus,
};
use uuid::Uuid;

pub async fn matches(conn: &mut PgConnection, event_id: Uuid) -> sqlx::Result<Vec<GameMatch>> {
  load_matches(conn, event_id, None).await
}

/// Some of an event's matches, for pushing changes.
pub async fn matches_by_id(conn: &mut PgConnection, event_id: Uuid, ids: &[Uuid]) -> sqlx::Result<Vec<GameMatch>> {
  load_matches(conn, event_id, Some(ids)).await
}

async fn load_matches(conn: &mut PgConnection, event_id: Uuid, only: Option<&[Uuid]>) -> sqlx::Result<Vec<GameMatch>> {
  let rows = sqlx::query!(
    r#"select id, kind as "kind: MatchKind", number, scheduled_start, scheduled_end,
              state as "state: MatchState", started_at, finished_at
       from game_matches
       where event_id = $1 and ($2::uuid[] is null or id = any($2))
       order by scheduled_start, kind, number"#,
    event_id,
    only as Option<&[Uuid]>,
  )
  .fetch_all(&mut *conn)
  .await?;
  // A slot shows its published sheet, or failing that one waiting for review.
  let slots = sqlx::query!(
    r#"select s.id, s.match_id, s.table_id, s.team_id, s.round,
              (select c.status from scoresheets c
               where c.slot_id = s.id and c.status in ('published', 'submitted', 'superseded')
               order by c.status = 'published' desc, c.status = 'submitted' desc limit 1) as "sheet: ScoresheetStatus",
              s.queue_state as "queue: QueueState", s.queue_previous as "queue_previous: QueueState",
              s.queue_changed_at
       from match_slots s
       join game_matches m on m.id = s.match_id
       join game_tables t on t.id = s.table_id
       where m.event_id = $1 and ($2::uuid[] is null or m.id = any($2))
       order by t.sort_order"#,
    event_id,
    only as Option<&[Uuid]>,
  )
  .fetch_all(&mut *conn)
  .await?;
  let mut by_match: HashMap<Uuid, Vec<MatchSlot>> = HashMap::new();
  for s in slots {
    by_match.entry(s.match_id).or_default().push(MatchSlot {
      id: s.id,
      table_id: s.table_id,
      team_id: s.team_id,
      round: s.round,
      sheet: s.sheet,
      queue: s.queue,
      queue_previous: s.queue_previous,
      queue_changed_at: s.queue_changed_at,
    });
  }
  Ok(
    rows
      .into_iter()
      .map(|m| GameMatch {
        id: m.id,
        event_id,
        kind: m.kind,
        number: m.number,
        scheduled_start: m.scheduled_start,
        scheduled_end: m.scheduled_end,
        state: m.state,
        started_at: m.started_at,
        finished_at: m.finished_at,
        slots: by_match.remove(&m.id).unwrap_or_default(),
      })
      .collect(),
  )
}

pub async fn sessions(conn: &mut PgConnection, event_id: Uuid) -> sqlx::Result<Vec<JudgingSession>> {
  load_sessions(conn, event_id, None).await
}

/// Some of an event's judging sessions, for pushing changes.
pub async fn sessions_by_id(
  conn: &mut PgConnection,
  event_id: Uuid,
  ids: &[Uuid],
) -> sqlx::Result<Vec<JudgingSession>> {
  load_sessions(conn, event_id, Some(ids)).await
}

async fn load_sessions(
  conn: &mut PgConnection,
  event_id: Uuid,
  only: Option<&[Uuid]>,
) -> sqlx::Result<Vec<JudgingSession>> {
  let rows = sqlx::query!(
    "select id, number, scheduled_start, scheduled_end from judging_sessions
     where event_id = $1 and ($2::uuid[] is null or id = any($2)) order by scheduled_start, number",
    event_id,
    only as Option<&[Uuid]>,
  )
  .fetch_all(&mut *conn)
  .await?;
  // A slot shows its team's accepted rubric, or failing that one waiting for review.
  let slots = sqlx::query!(
    r#"select s.id, s.session_id, s.pod_id, s.team_id,
              s.queue_state as "queue: QueueState", s.queue_previous as "queue_previous: QueueState",
              (select r.status from rubrics r
               where r.team_id = s.team_id and r.status in ('accepted', 'submitted')
               order by r.status = 'accepted' desc limit 1) as "rubric: RubricStatus"
       from judging_slots s
       join judging_sessions j on j.id = s.session_id
       join pods p on p.id = s.pod_id
       where j.event_id = $1 and ($2::uuid[] is null or j.id = any($2)) order by p.sort_order"#,
    event_id,
    only as Option<&[Uuid]>,
  )
  .fetch_all(&mut *conn)
  .await?;
  let mut by_session: HashMap<Uuid, Vec<JudgingSlot>> = HashMap::new();
  for s in slots {
    by_session.entry(s.session_id).or_default().push(JudgingSlot {
      id: s.id,
      pod_id: s.pod_id,
      team_id: s.team_id,
      queue: s.queue,
      queue_previous: s.queue_previous,
      rubric: s.rubric,
    });
  }
  Ok(
    rows
      .into_iter()
      .map(|r| JudgingSession {
        id: r.id,
        event_id,
        number: r.number,
        scheduled_start: r.scheduled_start,
        scheduled_end: r.scheduled_end,
        slots: by_session.remove(&r.id).unwrap_or_default(),
      })
      .collect(),
  )
}

pub struct Counts {
  pub matches: i64,
  pub sessions: i64,
}

pub async fn counts(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Counts> {
  let row = sqlx::query!(
    r#"select (select count(*) from game_matches where event_id = $1) as "matches!",
              (select count(*) from judging_sessions where event_id = $1) as "sessions!""#,
    event_id
  )
  .fetch_one(db)
  .await?;
  Ok(Counts {
    matches: row.matches,
    sessions: row.sessions,
  })
}

/// Removes every match and judging session (and their slots) of an event.
pub async fn clear(tx: &mut PgConnection, event_id: Uuid) -> sqlx::Result<()> {
  sqlx::query!("delete from game_matches where event_id = $1", event_id)
    .execute(&mut *tx)
    .await?;
  sqlx::query!("delete from judging_sessions where event_id = $1", event_id)
    .execute(&mut *tx)
    .await?;
  Ok(())
}

pub async fn insert_match(
  tx: &mut PgConnection,
  event_id: Uuid,
  kind: MatchKind,
  number: i32,
  start: DateTime<Utc>,
  end: DateTime<Utc>,
) -> sqlx::Result<Uuid> {
  sqlx::query_scalar!(
    "insert into game_matches (id, event_id, kind, number, scheduled_start, scheduled_end) values ($1, $2, $3, $4, $5, $6) returning id",
    Uuid::now_v7(),
    event_id,
    kind as MatchKind,
    number,
    start,
    end,
  )
  .fetch_one(&mut *tx)
  .await
}

pub async fn insert_match_slot(
  tx: &mut PgConnection,
  match_id: Uuid,
  table_id: Uuid,
  team_id: Option<Uuid>,
  round: Option<i32>,
) -> sqlx::Result<()> {
  sqlx::query!(
    "insert into match_slots (id, match_id, table_id, team_id, round) values ($1, $2, $3, $4, $5)",
    Uuid::now_v7(),
    match_id,
    table_id,
    team_id,
    round,
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

pub async fn insert_session(
  tx: &mut PgConnection,
  event_id: Uuid,
  number: i32,
  start: DateTime<Utc>,
  end: DateTime<Utc>,
) -> sqlx::Result<Uuid> {
  sqlx::query_scalar!(
    "insert into judging_sessions (id, event_id, number, scheduled_start, scheduled_end) values ($1, $2, $3, $4, $5) returning id",
    Uuid::now_v7(),
    event_id,
    number,
    start,
    end,
  )
  .fetch_one(&mut *tx)
  .await
}

pub async fn insert_judging_slot(
  tx: &mut PgConnection,
  session_id: Uuid,
  pod_id: Uuid,
  team_id: Option<Uuid>,
) -> sqlx::Result<()> {
  sqlx::query!(
    "insert into judging_slots (id, session_id, pod_id, team_id) values ($1, $2, $3, $4)",
    Uuid::now_v7(),
    session_id,
    pod_id,
    team_id,
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

/// Changes who plays in a match slot; the queue starts again for whoever is there now.
pub async fn set_match_slot_team(tx: &mut PgConnection, slot_id: Uuid, team_id: Option<Uuid>) -> sqlx::Result<()> {
  sqlx::query!(
    "update match_slots
     set team_id = $2, queue_state = 'not_called', queue_previous = null, queue_changed_at = null,
         queue_changed_by = null
     where id = $1",
    slot_id,
    team_id
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

pub async fn set_judging_slot_team(tx: &mut PgConnection, slot_id: Uuid, team_id: Option<Uuid>) -> sqlx::Result<()> {
  sqlx::query!(
    "update judging_slots
     set team_id = $2, queue_state = 'not_called', queue_previous = null, queue_changed_at = null,
         queue_changed_by = null
     where id = $1",
    slot_id,
    team_id
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

/// Numbers each team's matches of each kind 1, 2, 3… in time order, after slots or times changed.
pub async fn renumber_rounds(tx: &mut PgConnection, event_id: Uuid) -> sqlx::Result<()> {
  sqlx::query!(
    "update match_slots s set round = r.n
     from (select s2.id,
                  (row_number() over (partition by s2.team_id, m.kind order by m.scheduled_start, m.number))::int as n
           from match_slots s2 join game_matches m on m.id = s2.match_id
           where m.event_id = $1 and s2.team_id is not null and m.state <> 'cancelled') r
     where s.id = r.id and s.round is distinct from r.n",
    event_id
  )
  .execute(&mut *tx)
  .await?;
  sqlx::query!(
    "update match_slots s set round = null
     from game_matches m
     where m.id = s.match_id and m.event_id = $1 and s.team_id is null and s.round is not null",
    event_id
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

pub async fn move_match(
  tx: &mut PgConnection,
  match_id: Uuid,
  start: DateTime<Utc>,
  end: DateTime<Utc>,
) -> sqlx::Result<()> {
  sqlx::query!(
    "update game_matches set scheduled_start = $2, scheduled_end = $3 where id = $1",
    match_id,
    start,
    end
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

pub async fn move_session(
  tx: &mut PgConnection,
  session_id: Uuid,
  start: DateTime<Utc>,
  end: DateTime<Utc>,
) -> sqlx::Result<()> {
  sqlx::query!(
    "update judging_sessions set scheduled_start = $2, scheduled_end = $3 where id = $1",
    session_id,
    start,
    end
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

pub async fn slot_event(db: impl PgExecutor<'_>, slot_id: Uuid) -> sqlx::Result<Option<Uuid>> {
  sqlx::query_scalar!(
    "select m.event_id from match_slots s join game_matches m on m.id = s.match_id where s.id = $1",
    slot_id
  )
  .fetch_optional(db)
  .await
}

/// The event a session belongs to, locking the session.
pub async fn lock_session(tx: &mut PgConnection, session_id: Uuid) -> sqlx::Result<Option<Uuid>> {
  sqlx::query_scalar!(
    "select event_id from judging_sessions where id = $1 for update",
    session_id
  )
  .fetch_optional(&mut *tx)
  .await
}
