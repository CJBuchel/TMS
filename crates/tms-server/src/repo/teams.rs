use sqlx::PgExecutor;
use tms_core::dto::TeamInput;
use tms_core::model::Team;
use uuid::Uuid;

pub async fn list(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Vec<Team>> {
  sqlx::query_as!(
    Team,
    // Numeric team numbers sort as numbers; anything else after them, alphabetically.
    r#"select id, event_id, number, name, affiliation, pit, notes from teams where event_id = $1
       order by case when number ~ '^[0-9]+$' then lpad(number, 12, '0') else 'z' || number end"#,
    event_id
  )
  .fetch_all(db)
  .await
}

pub async fn get(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<Team>> {
  sqlx::query_as!(
    Team,
    "select id, event_id, number, name, affiliation, pit, notes from teams where id = $1",
    id
  )
  .fetch_optional(db)
  .await
}

pub async fn insert(db: impl PgExecutor<'_>, event_id: Uuid, t: &TeamInput) -> sqlx::Result<Team> {
  sqlx::query_as!(
    Team,
    r#"insert into teams (id, event_id, number, name, affiliation, pit, notes) values ($1, $2, $3, $4, $5, $6, $7)
       returning id, event_id, number, name, affiliation, pit, notes"#,
    Uuid::now_v7(),
    event_id,
    t.number,
    t.name,
    t.affiliation,
    t.pit,
    t.notes,
  )
  .fetch_one(db)
  .await
}

pub async fn update(db: impl PgExecutor<'_>, id: Uuid, t: &TeamInput) -> sqlx::Result<Option<Team>> {
  sqlx::query_as!(
    Team,
    r#"update teams set number = $2, name = $3, affiliation = $4, pit = $5, notes = $6 where id = $1
       returning id, event_id, number, name, affiliation, pit, notes"#,
    id,
    t.number,
    t.name,
    t.affiliation,
    t.pit,
    t.notes,
  )
  .fetch_optional(db)
  .await
}

/// Creates the team, or updates name and affiliation of the team with that number. Keeps pit and notes.
pub async fn upsert_by_number(
  db: impl PgExecutor<'_>,
  event_id: Uuid,
  number: &str,
  name: &str,
  affiliation: &str,
) -> sqlx::Result<Team> {
  sqlx::query_as!(
    Team,
    r#"insert into teams (id, event_id, number, name, affiliation) values ($1, $2, $3, $4, $5)
       on conflict (event_id, number) do update set name = excluded.name, affiliation = excluded.affiliation
       returning id, event_id, number, name, affiliation, pit, notes"#,
    Uuid::now_v7(),
    event_id,
    number,
    name,
    affiliation,
  )
  .fetch_one(db)
  .await
}

/// Returns the event id when a team was deleted.
pub async fn delete(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<Uuid>> {
  sqlx::query_scalar!("delete from teams where id = $1 returning event_id", id)
    .fetch_optional(db)
    .await
}
