//! Runs the real bundled PostgreSQL in a scratch folder.

use std::path::PathBuf;

use tms_db::{Database, Source};

fn scratch(name: &str) -> PathBuf {
  let dir = std::env::temp_dir().join(format!("tms-db-test-{name}-{}", std::process::id()));
  let _ = std::fs::remove_dir_all(&dir);
  dir
}

async fn table_count(db: &Database) -> i64 {
  sqlx::query_scalar("select count(*) from information_schema.tables where table_schema = 'public'")
    .fetch_one(db.pool())
    .await
    .unwrap()
}

#[tokio::test]
async fn first_start_then_restart_keeps_data() {
  let dir = scratch("restart");

  let db = Database::open(Source::Embedded {
    dir: dir.clone(),
    port: None,
  })
  .await
  .unwrap();
  assert!(db.is_embedded());
  db.migrate().await.unwrap();
  assert!(table_count(&db).await > 0, "migrations created tables");
  sqlx::query("insert into server_secrets (name, value) values ('probe', '\\x01')")
    .execute(db.pool())
    .await
    .unwrap();
  db.close().await.unwrap();

  let db = Database::open(Source::Embedded {
    dir: dir.clone(),
    port: None,
  })
  .await
  .unwrap();
  db.migrate().await.unwrap();
  let kept: i64 = sqlx::query_scalar("select count(*) from server_secrets where name = 'probe'")
    .fetch_one(db.pool())
    .await
    .unwrap();
  assert_eq!(kept, 1, "data survives a restart");
  db.close().await.unwrap();

  let _ = std::fs::remove_dir_all(&dir);
}

#[tokio::test]
async fn recovers_from_a_server_left_running() {
  let dir = scratch("orphan");

  // A hard kill of `tms`: a separate process starts the database and exits without any cleanup, leaving
  // PostgreSQL running. The OS releases its folder lock, exactly as after a crash.
  let status = std::process::Command::new(std::env::current_exe().unwrap())
    .args(["--ignored", "--exact", "orphan_helper", "--nocapture"])
    .env("TMS_DB_ORPHAN_DIR", &dir)
    .status()
    .unwrap();
  assert!(status.success());
  assert!(
    dir.join("data/postmaster.pid").exists(),
    "the helper left a server running"
  );

  let db = Database::open(Source::Embedded {
    dir: dir.clone(),
    port: None,
  })
  .await
  .unwrap();
  let one: i32 = sqlx::query_scalar("select 1").fetch_one(db.pool()).await.unwrap();
  assert_eq!(one, 1);
  db.close().await.unwrap();
  assert!(
    !dir.join("data/postmaster.pid").exists(),
    "nothing left running after close"
  );

  let _ = std::fs::remove_dir_all(&dir);
}

/// Helper for `recovers_from_a_server_left_running`; only runs when that test launches it.
#[tokio::test]
#[ignore = "launched as a subprocess by recovers_from_a_server_left_running"]
async fn orphan_helper() {
  let dir = PathBuf::from(std::env::var("TMS_DB_ORPHAN_DIR").expect("set by the parent test"));
  let _db = Database::open(Source::Embedded { dir, port: None }).await.unwrap();
  std::process::exit(0);
}

#[tokio::test]
async fn a_second_process_cannot_share_the_folder() {
  let dir = scratch("lock");
  let first = Database::open(Source::Embedded {
    dir: dir.clone(),
    port: None,
  })
  .await
  .unwrap();
  let second = Database::open(Source::Embedded {
    dir: dir.clone(),
    port: None,
  })
  .await;
  let message = second.err().expect("second open is refused").to_string();
  assert!(
    message.contains("another tms is already using the data folder"),
    "{message}"
  );
  first.close().await.unwrap();
  let _ = std::fs::remove_dir_all(&dir);
}

#[tokio::test]
async fn external_url_is_used_as_given() {
  // Any PostgreSQL will do as the "external" server; a second embedded one avoids needing Docker.
  let dir = scratch("external");
  let server = Database::open(Source::Embedded {
    dir: dir.clone(),
    port: None,
  })
  .await
  .unwrap();
  let url = server.url().to_owned();

  let db = Database::open(Source::External { url: url.clone() }).await.unwrap();
  assert!(!db.is_embedded());
  assert_eq!(db.url(), url);
  db.migrate().await.unwrap();
  assert!(table_count(&db).await > 0);
  db.close().await.unwrap();

  server.close().await.unwrap();
  let _ = std::fs::remove_dir_all(&dir);
}
