//! Competition tables and judging pods. Both are ordered lists; new ones go to the end.

use sqlx::{PgConnection, PgExecutor};
use tms_core::model::{GameTable, Pod};
use uuid::Uuid;

pub async fn tables(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Vec<GameTable>> {
  sqlx::query_as!(
    GameTable,
    "select id, event_id, name, sort_order from game_tables where event_id = $1 order by sort_order, name",
    event_id
  )
  .fetch_all(db)
  .await
}

pub async fn insert_table(db: impl PgExecutor<'_>, event_id: Uuid, name: &str) -> sqlx::Result<GameTable> {
  sqlx::query_as!(
    GameTable,
    r#"insert into game_tables (id, event_id, name, sort_order)
       values ($1, $2, $3, (select coalesce(max(sort_order) + 1, 0) from game_tables where event_id = $2))
       returning id, event_id, name, sort_order"#,
    Uuid::now_v7(),
    event_id,
    name,
  )
  .fetch_one(db)
  .await
}

pub async fn rename_table(db: impl PgExecutor<'_>, id: Uuid, name: &str) -> sqlx::Result<Option<GameTable>> {
  sqlx::query_as!(
    GameTable,
    "update game_tables set name = $2 where id = $1 returning id, event_id, name, sort_order",
    id,
    name
  )
  .fetch_optional(db)
  .await
}

pub async fn delete_table(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<Uuid>> {
  sqlx::query_scalar!("delete from game_tables where id = $1 returning event_id", id)
    .fetch_optional(db)
    .await
}

/// Sets `sort_order` to the position of each id in `ids`. Ids from another event are ignored.
pub async fn reorder_tables(tx: &mut PgConnection, event_id: Uuid, ids: &[Uuid]) -> sqlx::Result<()> {
  for (position, id) in (0_i32..).zip(ids) {
    sqlx::query!(
      "update game_tables set sort_order = $3 where id = $1 and event_id = $2",
      id,
      event_id,
      position
    )
    .execute(&mut *tx)
    .await?;
  }
  Ok(())
}

pub async fn pods(db: impl PgExecutor<'_>, event_id: Uuid) -> sqlx::Result<Vec<Pod>> {
  sqlx::query_as!(
    Pod,
    "select id, event_id, name, room, sort_order from pods where event_id = $1 order by sort_order, name",
    event_id
  )
  .fetch_all(db)
  .await
}

pub async fn insert_pod(db: impl PgExecutor<'_>, event_id: Uuid, name: &str, room: Option<&str>) -> sqlx::Result<Pod> {
  sqlx::query_as!(
    Pod,
    r#"insert into pods (id, event_id, name, room, sort_order)
       values ($1, $2, $3, $4, (select coalesce(max(sort_order) + 1, 0) from pods where event_id = $2))
       returning id, event_id, name, room, sort_order"#,
    Uuid::now_v7(),
    event_id,
    name,
    room,
  )
  .fetch_one(db)
  .await
}

pub async fn update_pod(
  db: impl PgExecutor<'_>,
  id: Uuid,
  name: &str,
  room: Option<&str>,
) -> sqlx::Result<Option<Pod>> {
  sqlx::query_as!(
    Pod,
    "update pods set name = $2, room = $3 where id = $1 returning id, event_id, name, room, sort_order",
    id,
    name,
    room
  )
  .fetch_optional(db)
  .await
}

pub async fn delete_pod(db: impl PgExecutor<'_>, id: Uuid) -> sqlx::Result<Option<Uuid>> {
  sqlx::query_scalar!("delete from pods where id = $1 returning event_id", id)
    .fetch_optional(db)
    .await
}

pub async fn reorder_pods(tx: &mut PgConnection, event_id: Uuid, ids: &[Uuid]) -> sqlx::Result<()> {
  for (position, id) in (0_i32..).zip(ids) {
    sqlx::query!(
      "update pods set sort_order = $3 where id = $1 and event_id = $2",
      id,
      event_id,
      position
    )
    .execute(&mut *tx)
    .await?;
  }
  Ok(())
}
