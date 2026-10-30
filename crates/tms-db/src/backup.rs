//! Backups: one `.tmsbackup` file each, a zip holding a `pg_dump` custom-format dump and `manifest.json`.
//! The bundled PostgreSQL provides `pg_dump` and `pg_restore`, for the embedded database and an external one alike.

use std::fs::File;
use std::io::{Read, Write};
use std::path::{Path, PathBuf};

use anyhow::{Context, bail};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use tokio::process::Command;

use crate::{Database, MIGRATOR};

pub const EXTENSION: &str = "tmsbackup";
const MANIFEST: &str = "manifest.json";
const DUMP: &str = "database.dump";

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Kind {
  /// Made on the server's interval; only these are pruned.
  Auto,
  Manual,
  /// Made just before a restore replaced the data, so the restore can be undone.
  BeforeRestore,
}

impl Kind {
  fn prefix(self) -> &'static str {
    match self {
      Kind::Auto => "auto",
      Kind::Manual => "manual",
      Kind::BeforeRestore => "before-restore",
    }
  }

  pub fn label(self) -> &'static str {
    match self {
      Kind::Auto => "Automatic",
      Kind::Manual => "Manual",
      Kind::BeforeRestore => "Before a restore",
    }
  }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Manifest {
  pub app_version: String,
  /// The newest migration applied when the backup was made. A newer app can restore it; an older one can't.
  pub migration_version: i64,
  pub created_at: DateTime<Utc>,
  pub kind: Kind,
  pub event_codes: Vec<String>,
}

#[derive(Debug, Clone)]
pub struct BackupInfo {
  pub path: PathBuf,
  pub file_name: String,
  pub size: u64,
  pub manifest: Manifest,
}

/// The newest migration this build knows.
pub fn latest_migration() -> i64 {
  MIGRATOR.iter().map(|m| m.version).max().unwrap_or(0)
}

/// Where `pg_dump` and `pg_restore` live. The embedded database already has them; for an external one, the
/// bundled PostgreSQL is unpacked under `postgres_dir` the first time (no server is started).
pub async fn tools(db: &Database, postgres_dir: &Path) -> anyhow::Result<PathBuf> {
  if let Some(dir) = db.tools_dir() {
    return Ok(dir);
  }
  #[cfg(feature = "embedded")]
  {
    crate::embedded::install_tools(postgres_dir).await
  }
  #[cfg(not(feature = "embedded"))]
  {
    let _ = postgres_dir;
    bail!("this build has no bundled PostgreSQL tools for backups")
  }
}

fn tool(tools: &Path, name: &str) -> PathBuf {
  let file = if cfg!(windows) {
    format!("{name}.exe")
  } else {
    name.to_owned()
  };
  tools.join(file)
}

/// Dumps the database into a new backup file in `folder` and returns its path.
pub async fn create(
  db: &Database,
  tools: &Path,
  folder: &Path,
  kind: Kind,
  app_version: &str,
) -> anyhow::Result<PathBuf> {
  tokio::fs::create_dir_all(folder)
    .await
    .with_context(|| format!("creating {}", folder.display()))?;
  let created_at = Utc::now();
  let migration_version: i64 =
    sqlx::query_scalar("select coalesce(max(version), 0) from _sqlx_migrations where success")
      .fetch_one(db.pool())
      .await
      .context("reading the migration version")?;
  let event_codes: Vec<String> = sqlx::query_scalar("select code from events order by starts_on, code")
    .fetch_all(db.pool())
    .await
    .unwrap_or_default();
  let manifest = Manifest {
    app_version: app_version.to_owned(),
    migration_version,
    created_at,
    kind,
    event_codes,
  };

  let stem = format!("{}-{}", kind.prefix(), created_at.format("%Y-%m-%d_%H%M%S"));
  let dump = folder.join(format!(".{stem}.dump"));
  let status = Command::new(tool(tools, "pg_dump"))
    .arg("--format=custom")
    .arg("--no-owner")
    .arg("--no-privileges")
    .arg(format!("--file={}", dump.display()))
    .arg(format!("--dbname={}", db.url()))
    .status()
    .await
    .context("running pg_dump")?;
  if !status.success() {
    let _ = tokio::fs::remove_file(&dump).await;
    bail!("pg_dump failed ({status})");
  }

  let path = folder.join(format!("{stem}.{EXTENSION}"));
  let (dump_for_zip, path_for_zip, manifest_json) = (dump.clone(), path.clone(), serde_json::to_vec_pretty(&manifest)?);
  tokio::task::spawn_blocking(move || write_zip(&path_for_zip, &manifest_json, &dump_for_zip)).await??;
  tokio::fs::remove_file(&dump).await?;
  Ok(path)
}

fn write_zip(path: &Path, manifest: &[u8], dump: &Path) -> anyhow::Result<()> {
  let partial = path.with_extension("partial");
  let mut zip = zip::ZipWriter::new(File::create(&partial)?);
  // The custom dump format is already compressed.
  let stored = zip::write::SimpleFileOptions::default().compression_method(zip::CompressionMethod::Stored);
  zip.start_file(MANIFEST, stored)?;
  zip.write_all(manifest)?;
  zip.start_file(DUMP, stored.large_file(true))?;
  std::io::copy(&mut File::open(dump)?, &mut zip)?;
  zip.finish()?;
  std::fs::rename(&partial, path)?;
  Ok(())
}

pub fn read_manifest(path: &Path) -> anyhow::Result<Manifest> {
  let mut zip = zip::ZipArchive::new(File::open(path).with_context(|| format!("opening {}", path.display()))?)
    .context("not a TMS backup")?;
  let mut text = String::new();
  zip
    .by_name(MANIFEST)
    .context("not a TMS backup: no manifest")?
    .read_to_string(&mut text)?;
  serde_json::from_str(&text).context("the backup's manifest is unreadable")
}

/// Every backup in `folder`, newest first. Unreadable files are skipped.
pub fn list(folder: &Path) -> Vec<BackupInfo> {
  let Ok(entries) = std::fs::read_dir(folder) else {
    return Vec::new();
  };
  let mut backups: Vec<BackupInfo> = entries
    .flatten()
    .filter(|e| e.path().extension().is_some_and(|x| x == EXTENSION))
    .filter_map(|e| {
      let path = e.path();
      let manifest = read_manifest(&path).ok()?;
      Some(BackupInfo {
        file_name: e.file_name().to_string_lossy().into_owned(),
        size: e.metadata().map_or(0, |m| m.len()),
        path,
        manifest,
      })
    })
    .collect();
  backups.sort_by_key(|b| std::cmp::Reverse(b.manifest.created_at));
  backups
}

/// Deletes the oldest automatic backups beyond `keep`. Manual ones are never pruned.
pub fn prune(folder: &Path, keep: usize) -> anyhow::Result<usize> {
  let old: Vec<BackupInfo> = list(folder)
    .into_iter()
    .filter(|b| b.manifest.kind == Kind::Auto)
    .skip(keep)
    .collect();
  for backup in &old {
    std::fs::remove_file(&backup.path).with_context(|| format!("removing {}", backup.path.display()))?;
  }
  Ok(old.len())
}

/// Copies a backup file from elsewhere into `folder`, after checking it is one.
pub fn import(file: &Path, folder: &Path) -> anyhow::Result<PathBuf> {
  read_manifest(file)?;
  std::fs::create_dir_all(folder)?;
  let name = file.file_name().context("no file name")?;
  let target = folder.join(name);
  if target.exists() {
    bail!(
      "a backup named {} is already in the backups folder",
      name.to_string_lossy()
    );
  }
  std::fs::copy(file, &target)?;
  Ok(target)
}

/// Replaces everything in the database with a backup, then runs this build's migrations on it. The caller
/// makes sure no server is using the database.
pub async fn restore(db: &Database, tools: &Path, file: &Path) -> anyhow::Result<Manifest> {
  let manifest = read_manifest(file)?;
  if manifest.migration_version > latest_migration() {
    bail!(
      "this backup was made by a newer TMS ({}); update TMS before restoring it",
      manifest.app_version
    );
  }
  let dump = std::env::temp_dir().join(format!("tms-restore-{}.dump", std::process::id()));
  let (zip_path, dump_path) = (file.to_path_buf(), dump.clone());
  tokio::task::spawn_blocking(move || -> anyhow::Result<()> {
    let mut zip = zip::ZipArchive::new(File::open(zip_path)?)?;
    let mut entry = zip.by_name(DUMP).context("the backup has no database dump")?;
    std::io::copy(&mut entry, &mut File::create(dump_path)?)?;
    Ok(())
  })
  .await??;

  // Start from an empty schema, so tables added since the backup can't get in the way.
  sqlx::raw_sql("drop schema public cascade; create schema public;")
    .execute(db.pool())
    .await
    .context("clearing the database")?;
  let output = Command::new(tool(tools, "pg_restore"))
    .arg("--no-owner")
    .arg("--no-privileges")
    .arg("--exit-on-error")
    .arg(format!("--dbname={}", db.url()))
    .arg(&dump)
    .output()
    .await
    .context("running pg_restore")?;
  let _ = tokio::fs::remove_file(&dump).await;
  if !output.status.success() {
    bail!("pg_restore failed: {}", String::from_utf8_lossy(&output.stderr).trim());
  }
  db.migrate().await?;
  Ok(manifest)
}
