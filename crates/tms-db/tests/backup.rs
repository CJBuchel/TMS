//! Backups against the real bundled PostgreSQL: create, list, restore, refuse a newer backup, prune.

use std::io::Write;
use std::path::PathBuf;

use tms_db::backup::{self, Kind};
use tms_db::{Database, Source};

fn scratch(name: &str) -> PathBuf {
  let dir = std::env::temp_dir().join(format!("tms-db-backup-{name}-{}", std::process::id()));
  let _ = std::fs::remove_dir_all(&dir);
  dir
}

async fn add_event(db: &Database, code: &str) {
  sqlx::query(
    "insert into events (id, code, name, season_id, timezone, starts_on, ends_on)
     values (gen_random_uuid(), $1, $1, 'bioglow_founders', 'UTC', '2026-11-14', '2026-11-14')",
  )
  .bind(code)
  .execute(db.pool())
  .await
  .unwrap();
}

async fn codes(db: &Database) -> Vec<String> {
  sqlx::query_scalar("select code from events order by code")
    .fetch_all(db.pool())
    .await
    .unwrap()
}

#[tokio::test]
async fn backup_then_restore_brings_the_data_back() {
  let dir = scratch("roundtrip");
  let folder = dir.join("backups");
  let db = Database::open(Source::Embedded {
    dir: dir.join("postgres"),
    port: None,
  })
  .await
  .unwrap();
  db.migrate().await.unwrap();
  add_event(&db, "KEEP-1").await;

  let tools = backup::tools(&db, &dir.join("postgres")).await.unwrap();
  let file = backup::create(&db, &tools, &folder, Kind::Manual, "1.2.3")
    .await
    .unwrap();
  assert!(file.file_name().unwrap().to_string_lossy().starts_with("manual-"));
  let listed = backup::list(&folder);
  assert_eq!(listed.len(), 1);
  assert_eq!(listed[0].manifest.event_codes, ["KEEP-1"]);
  assert_eq!(listed[0].manifest.app_version, "1.2.3");
  assert_eq!(listed[0].manifest.migration_version, backup::latest_migration());

  add_event(&db, "LATER-2").await;
  assert_eq!(codes(&db).await, ["KEEP-1", "LATER-2"]);
  let manifest = backup::restore(&db, &tools, &file).await.unwrap();
  assert_eq!(manifest.kind, Kind::Manual);
  assert_eq!(
    codes(&db).await,
    ["KEEP-1"],
    "the database is exactly as it was backed up"
  );
  db.migrate().await.unwrap();

  // A backup from a newer TMS is refused, and nothing changes.
  let newer = dir.join("newer.tmsbackup");
  let mut zip = zip::ZipWriter::new(std::fs::File::create(&newer).unwrap());
  zip
    .start_file("manifest.json", zip::write::SimpleFileOptions::default())
    .unwrap();
  let manifest = serde_json::json!({
    "app_version": "99.0.0", "migration_version": i64::MAX, "created_at": "2030-01-01T00:00:00Z",
    "kind": "manual", "event_codes": [],
  });
  zip.write_all(manifest.to_string().as_bytes()).unwrap();
  zip.finish().unwrap();
  let err = backup::restore(&db, &tools, &newer).await.unwrap_err().to_string();
  assert!(err.contains("newer TMS"), "{err}");
  assert_eq!(codes(&db).await, ["KEEP-1"]);

  // Importing copies a backup into the folder; a file that isn't one is refused.
  let outside = dir.join("copy.tmsbackup");
  std::fs::copy(&file, &outside).unwrap();
  std::fs::remove_file(&file).unwrap();
  backup::import(&outside, &folder).unwrap();
  assert_eq!(backup::list(&folder).len(), 1);
  std::fs::write(dir.join("junk.tmsbackup"), "not a zip").unwrap();
  assert!(backup::import(&dir.join("junk.tmsbackup"), &folder).is_err());

  db.close().await.unwrap();
  let _ = std::fs::remove_dir_all(&dir);
}

#[tokio::test]
async fn pruning_keeps_the_newest_automatic_backups_and_every_manual_one() {
  let dir = scratch("prune");
  let folder = dir.join("backups");
  let db = Database::open(Source::Embedded {
    dir: dir.join("postgres"),
    port: None,
  })
  .await
  .unwrap();
  db.migrate().await.unwrap();
  let tools = backup::tools(&db, &dir.join("postgres")).await.unwrap();
  backup::create(&db, &tools, &folder, Kind::Manual, "1").await.unwrap();
  for _ in 0..3 {
    // Backup names carry the second they were made in.
    tokio::time::sleep(std::time::Duration::from_millis(1100)).await;
    backup::create(&db, &tools, &folder, Kind::Auto, "1").await.unwrap();
  }
  assert_eq!(backup::prune(&folder, 2).unwrap(), 1);
  let kinds: Vec<Kind> = backup::list(&folder).into_iter().map(|b| b.manifest.kind).collect();
  assert_eq!(kinds, [Kind::Auto, Kind::Auto, Kind::Manual]);
  db.close().await.unwrap();
  let _ = std::fs::remove_dir_all(&dir);
}
