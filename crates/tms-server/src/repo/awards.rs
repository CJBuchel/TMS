//! Awards, their winners, advancement, and the deliberation lock and ceremony position.

use std::collections::BTreeMap;

use chrono::{DateTime, Utc};
use sqlx::{PgConnection, PgExecutor};
use tms_core::deliberation::{Award, AwardKind, AwardWinner, Deliberation, Finalized, team_scores};
use tms_core::judging::Nomination;
use uuid::Uuid;

use super::judging;

struct AwardRow {
  id: Uuid,
  event_id: Uuid,
  kind: AwardKind,
  name: String,
  places: i32,
  sort_order: i32,
}

impl From<AwardRow> for Award {
  fn from(r: AwardRow) -> Self {
    Award {
      id: r.id,
      event_id: r.event_id,
      kind: r.kind,
      name: r.name,
      places: u8::try_from(r.places).unwrap_or(1),
      sort_order: r.sort_order,
    }
  }
}

pub async fn list(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Vec<Award>> {
  let rows = sqlx::query_as!(
    AwardRow,
    r#"select id, event_id, kind as "kind: AwardKind", name, places, sort_order
       from awards where event_id = $1 order by sort_order, name"#,
    event_id
  )
  .fetch_all(db)
  .await?;
  Ok(rows.into_iter().map(Award::from).collect())
}

pub async fn get(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<Award>> {
  let row = sqlx::query_as!(
    AwardRow,
    r#"select id, event_id, kind as "kind: AwardKind", name, places, sort_order from awards where id = $1"#,
    id
  )
  .fetch_optional(db)
  .await?;
  Ok(row.map(Award::from))
}

pub async fn insert(
  db: impl PgExecutor<'_>,
  event_id: Uuid,
  kind: AwardKind,
  name: &str,
  places: u8,
) -> sqlx::Result<Award> {
  let row = sqlx::query_as!(
    AwardRow,
    r#"insert into awards (id, event_id, kind, name, places, sort_order) values ($1, $2, $3, $4, $5, $6)
       returning id, event_id, kind as "kind: AwardKind", name, places, sort_order"#,
    Uuid::now_v7(),
    event_id,
    kind as AwardKind,
    name,
    i32::from(places),
    kind.ceremony_order(),
  )
  .fetch_one(db)
  .await?;
  Ok(row.into())
}

/// The awards every event presents, one place each.
pub async fn insert_required(tx: &mut PgConnection, event_id: Uuid) -> sqlx::Result<()> {
  for kind in AwardKind::ALL.into_iter().filter(|k| k.required()) {
    insert(&mut *tx, event_id, kind, kind.label(), 1).await?;
  }
  Ok(())
}

pub async fn update(db: impl PgExecutor<'_>, id: Uuid, name: &str, places: u8) -> sqlx::Result<Option<Award>> {
  let row = sqlx::query_as!(
    AwardRow,
    r#"update awards set name = $2, places = $3 where id = $1
       returning id, event_id, kind as "kind: AwardKind", name, places, sort_order"#,
    id,
    name,
    i32::from(places),
  )
  .fetch_optional(db)
  .await?;
  Ok(row.map(Award::from))
}

pub async fn delete(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<()> {
  sqlx::query!("delete from awards where id = $1", id).execute(db).await?;
  Ok(())
}

/// Sets the ceremony order to the position of each id in `ids`. Ids from another event are ignored.
pub async fn reorder(tx: &mut PgConnection, event_id: Uuid, ids: &[Uuid]) -> sqlx::Result<()> {
  for (position, id) in (0_i32..).zip(ids) {
    sqlx::query!(
      "update awards set sort_order = $3 where id = $1 and event_id = $2",
      id,
      event_id,
      position * 10
    )
    .execute(&mut *tx)
    .await?;
  }
  Ok(())
}

pub async fn winners(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Vec<AwardWinner>> {
  let rows = sqlx::query!(
    "select w.award_id, w.team_id, w.place, w.note, w.assigned_by
     from award_winners w join awards a on a.id = w.award_id
     where a.event_id = $1 order by a.sort_order, w.place",
    event_id
  )
  .fetch_all(db)
  .await?;
  Ok(
    rows
      .into_iter()
      .map(|r| AwardWinner {
        award_id: r.award_id,
        team_id: r.team_id,
        place: u8::try_from(r.place).unwrap_or(1),
        note: r.note,
        assigned_by: r.assigned_by,
      })
      .collect(),
  )
}

pub async fn highest_place(db: impl PgExecutor<'_>, award_id: Uuid) -> sqlx::Result<u8> {
  let place = sqlx::query_scalar!(
    r#"select coalesce(max(place), 0) as "place!" from award_winners where award_id = $1"#,
    award_id
  )
  .fetch_one(db)
  .await?;
  Ok(u8::try_from(place).unwrap_or(u8::MAX))
}

pub async fn assign(tx: &mut PgConnection, award_id: Uuid, winner: &AwardWinner) -> sqlx::Result<()> {
  sqlx::query!(
    "insert into award_winners (award_id, team_id, place, note, assigned_by) values ($1, $2, $3, $4, $5)",
    award_id,
    winner.team_id,
    i32::from(winner.place),
    winner.note,
    winner.assigned_by,
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

/// The team that held the place, if any.
pub async fn unassign(tx: &mut PgConnection, award_id: Uuid, place: u8) -> sqlx::Result<Option<Uuid>> {
  sqlx::query_scalar!(
    "delete from award_winners where award_id = $1 and place = $2 returning team_id",
    award_id,
    i32::from(place)
  )
  .fetch_optional(&mut *tx)
  .await
}

pub async fn advancing(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Vec<Uuid>> {
  sqlx::query_scalar!(
    "select team_id from advancements where event_id = $1 order by position",
    event_id
  )
  .fetch_all(db)
  .await
}

pub async fn set_advancing(tx: &mut PgConnection, event_id: Uuid, team_ids: &[Uuid]) -> sqlx::Result<()> {
  sqlx::query!("delete from advancements where event_id = $1", event_id)
    .execute(&mut *tx)
    .await?;
  for (position, team_id) in (1_i32..).zip(team_ids) {
    sqlx::query!(
      "insert into advancements (event_id, team_id, position) values ($1, $2, $3)",
      event_id,
      team_id,
      position
    )
    .execute(&mut *tx)
    .await?;
  }
  Ok(())
}

pub struct State {
  pub finalized: Option<Finalized>,
  pub ceremony_shown: u32,
}

pub async fn state(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<State> {
  let row = sqlx::query!(
    "select finalized_at, finalized_by, ceremony_shown from deliberation_state where event_id = $1",
    event_id
  )
  .fetch_optional(db)
  .await?;
  Ok(match row {
    Some(r) => State {
      finalized: finalized(r.finalized_at, r.finalized_by),
      ceremony_shown: u32::try_from(r.ceremony_shown).unwrap_or(0),
    },
    None => State {
      finalized: None,
      ceremony_shown: 0,
    },
  })
}

fn finalized(at: Option<DateTime<Utc>>, by: Option<String>) -> Option<Finalized> {
  Some(Finalized {
    at: at?,
    by: by.unwrap_or_default(),
  })
}

/// Locks the event's deliberation row, creating it first, so changes to awards wait for each other.
pub async fn lock(tx: &mut PgConnection, event_id: Uuid) -> sqlx::Result<State> {
  sqlx::query!(
    "insert into deliberation_state (event_id) values ($1) on conflict (event_id) do nothing",
    event_id
  )
  .execute(&mut *tx)
  .await?;
  let r = sqlx::query!(
    "select finalized_at, finalized_by, ceremony_shown from deliberation_state where event_id = $1 for update",
    event_id
  )
  .fetch_one(&mut *tx)
  .await?;
  Ok(State {
    finalized: finalized(r.finalized_at, r.finalized_by),
    ceremony_shown: u32::try_from(r.ceremony_shown).unwrap_or(0),
  })
}

/// Finalizes when `by` is given, reopens when it is `None`. Either way the ceremony starts from the beginning.
pub async fn set_finalized(tx: &mut PgConnection, event_id: Uuid, by: Option<&str>) -> sqlx::Result<()> {
  sqlx::query!(
    "update deliberation_state
     set finalized_at = case when $2::text is null then null else now() end, finalized_by = $2, ceremony_shown = 0
     where event_id = $1",
    event_id,
    by
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

pub async fn set_ceremony_shown(tx: &mut PgConnection, event_id: Uuid, shown: u32) -> sqlx::Result<()> {
  sqlx::query!(
    "update deliberation_state set ceremony_shown = $2 where event_id = $1",
    event_id,
    i32::try_from(shown).unwrap_or(i32::MAX)
  )
  .execute(&mut *tx)
  .await?;
  Ok(())
}

/// Optional-award candidates the judges selected on each team's accepted rubric.
pub async fn nominations(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<BTreeMap<Uuid, Vec<Nomination>>> {
  let rows = sqlx::query!(
    "select team_id, nominations from rubrics
     where event_id = $1 and status = 'accepted' and cardinality(nominations) > 0",
    event_id
  )
  .fetch_all(db)
  .await?;
  Ok(
    rows
      .into_iter()
      .map(|r| (r.team_id, judging::nominations_from(&r.nominations)))
      .collect(),
  )
}

/// Everything the judge advisor deliberates with.
pub async fn deliberation(db: &mut PgConnection, event_id: Uuid, advancement_slots: u32) -> sqlx::Result<Deliberation> {
  let inputs = judging::team_inputs(&mut *db, event_id).await?;
  Ok(Deliberation {
    event_id,
    teams: team_scores(&inputs),
    nominations: nominations(&mut *db, event_id).await?,
    awards: list(&mut *db, event_id).await?,
    winners: winners(&mut *db, event_id).await?,
    advancement_slots,
    advancing: advancing(&mut *db, event_id).await?,
    finalized: state(&mut *db, event_id).await?.finalized,
  })
}

pub async fn is_finalized(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<bool> {
  Ok(
    sqlx::query_scalar!(
      "select finalized_at from deliberation_state where event_id = $1",
      event_id
    )
    .fetch_optional(db)
    .await?
    .flatten()
    .is_some(),
  )
}
