//! The bundled PostgreSQL. Layout under the data folder:
//!
//! ```text
//! <dir>/install/<version>/   unpacked binaries (first start only)
//! <dir>/data/                the cluster (initdb on first start)
//! <dir>/password             superuser password, generated once, readable only by this user
//! ```

use std::path::Path;
use std::time::Duration;

use anyhow::Context;
use postgresql_embedded::{PostgreSQL, Settings, Status};
use rand::Rng;
use rand::distr::Alphanumeric;

const DATABASE: &str = "tms";

pub struct Embedded {
  server: PostgreSQL,
  /// Held for as long as this process uses the folder; the OS releases it if the process dies.
  _lock: std::fs::File,
}

impl Embedded {
  pub async fn start(dir: &Path, port: Option<u16>) -> anyhow::Result<Self> {
    tokio::fs::create_dir_all(dir)
      .await
      .with_context(|| format!("creating {}", dir.display()))?;
    let lock = lock_folder(dir)?;
    let password_file = dir.join("password");

    let settings = Settings {
      installation_dir: dir.join("install"),
      data_dir: dir.join("data"),
      password: read_or_create_password(&password_file).await?,
      password_file,
      port: port.unwrap_or(0),
      temporary: false,
      timeout: Some(Duration::from_secs(30)),
      // Only this machine may connect, whatever address the web server binds to.
      configuration: [("listen_addresses".to_owned(), "127.0.0.1".to_owned())].into(),
      ..Settings::default()
    };

    let mut server = PostgreSQL::new(settings);
    let first_start = server.status() == Status::NotInstalled;
    if first_start {
      tracing::info!(dir = %dir.display(), "unpacking the embedded PostgreSQL (first start only)");
    }
    server.setup().await.context("installing the embedded PostgreSQL")?;

    // We hold the folder lock, so no live `tms` owns this cluster. A postmaster.pid left behind therefore means
    // either a server orphaned by a hard kill of `tms` (still running), or a stale file whose server is gone.
    // Stopping handles the first; the second fails harmlessly and PostgreSQL replaces the stale file itself.
    if server.status() == Status::Started {
      match server.stop().await {
        Ok(()) => tracing::warn!("stopped a PostgreSQL server left running by an earlier run"),
        Err(e) => tracing::debug!(error = %e, "no previous server to stop; continuing"),
      }
    }

    server.start().await.context("starting the embedded PostgreSQL")?;
    if !server.database_exists(DATABASE).await? {
      server.create_database(DATABASE).await?;
    }
    tracing::info!(port = server.settings().port, "embedded PostgreSQL is running");
    Ok(Self { server, _lock: lock })
  }

  pub fn url(&self) -> String {
    self.server.settings().url(DATABASE)
  }

  pub fn tools_dir(&self) -> std::path::PathBuf {
    self.server.settings().binary_dir()
  }

  pub async fn stop(self) -> anyhow::Result<()> {
    self.server.stop().await.context("stopping the embedded PostgreSQL")
  }
}

/// Unpacks the bundled PostgreSQL under `dir` for its tools only, for backups of an external database. The
/// installer also initialises a small cluster, which is never started.
pub async fn install_tools(dir: &Path) -> anyhow::Result<std::path::PathBuf> {
  tokio::fs::create_dir_all(dir).await?;
  let settings = Settings {
    installation_dir: dir.join("install"),
    data_dir: dir.join("tools-only"),
    password_file: dir.join("tools-only-password"),
    temporary: false,
    ..Settings::default()
  };
  let mut server = PostgreSQL::new(settings);
  server.setup().await.context("unpacking the bundled PostgreSQL tools")?;
  Ok(server.settings().binary_dir())
}

/// One `tms` process per data folder. Without this, a second process would see the first one's running
/// server as an orphan and stop it.
fn lock_folder(dir: &Path) -> anyhow::Result<std::fs::File> {
  let path = dir.join("tms.lock");
  let file = std::fs::File::create(&path).with_context(|| format!("creating {}", path.display()))?;
  match file.try_lock() {
    Ok(()) => Ok(file),
    Err(std::fs::TryLockError::WouldBlock) => anyhow::bail!(
      "another tms is already using the data folder {}; stop it first, or use a different --data-dir",
      dir.display()
    ),
    Err(std::fs::TryLockError::Error(e)) => Err(e).context("locking the data folder"),
  }
}

/// The password must survive restarts: initdb sets it once, and every later start must use the same one.
async fn read_or_create_password(path: &Path) -> anyhow::Result<String> {
  if let Ok(existing) = tokio::fs::read_to_string(path).await {
    let trimmed = existing.trim();
    if !trimmed.is_empty() {
      return Ok(trimmed.to_owned());
    }
  }
  let password: String = rand::rng()
    .sample_iter(&Alphanumeric)
    .take(32)
    .map(char::from)
    .collect();
  tokio::fs::write(path, &password)
    .await
    .with_context(|| format!("writing {}", path.display()))?;
  #[cfg(unix)]
  {
    use std::os::unix::fs::PermissionsExt;
    tokio::fs::set_permissions(path, std::fs::Permissions::from_mode(0o600)).await?;
  }
  Ok(password)
}
