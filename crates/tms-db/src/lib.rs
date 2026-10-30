//! Where the database comes from, and nothing else: an embedded PostgreSQL that `tms` owns, or an external
//! server given by URL. Both end as a connection pool with migrations applied.

pub mod backup;
#[cfg(feature = "embedded")]
mod embedded;

use std::path::PathBuf;
use std::time::Duration;

use anyhow::Context;
use sqlx::PgPool;
use sqlx::migrate::Migrator;
use sqlx::postgres::PgPoolOptions;

/// Every migration, compiled into the binary.
pub static MIGRATOR: Migrator = sqlx::migrate!("../../migrations");

#[derive(Debug, Clone)]
pub enum Source {
  /// PostgreSQL bundled in the binary, unpacked into `dir` and run as a child process on 127.0.0.1.
  Embedded { dir: PathBuf, port: Option<u16> },
  /// Any PostgreSQL server.
  External { url: String },
}

pub struct Database {
  pool: PgPool,
  url: String,
  #[cfg(feature = "embedded")]
  embedded: Option<embedded::Embedded>,
}

impl Database {
  /// Starts or connects to the database and returns a ready pool. Does not run migrations.
  pub async fn open(source: Source) -> anyhow::Result<Self> {
    match source {
      Source::External { url } => {
        let pool = connect(&url).await?;
        Ok(Self {
          pool,
          url,
          #[cfg(feature = "embedded")]
          embedded: None,
        })
      }
      #[cfg(feature = "embedded")]
      Source::Embedded { dir, port } => {
        let embedded = embedded::Embedded::start(&dir, port).await?;
        let url = embedded.url();
        let pool = connect(&url).await?;
        Ok(Self {
          pool,
          url,
          embedded: Some(embedded),
        })
      }
      #[cfg(not(feature = "embedded"))]
      Source::Embedded { .. } => {
        anyhow::bail!("this build has no embedded PostgreSQL; pass --database-url")
      }
    }
  }

  pub async fn migrate(&self) -> anyhow::Result<()> {
    MIGRATOR.run(&self.pool).await.context("running database migrations")
  }

  pub fn pool(&self) -> &PgPool {
    &self.pool
  }

  /// Connection URL, including the password.
  pub fn url(&self) -> &str {
    &self.url
  }

  /// The bundled PostgreSQL's programs (`pg_dump`, `pg_restore`), when this database is the embedded one.
  pub fn tools_dir(&self) -> Option<PathBuf> {
    #[cfg(feature = "embedded")]
    return self.embedded.as_ref().map(embedded::Embedded::tools_dir);
    #[cfg(not(feature = "embedded"))]
    None
  }

  pub fn is_embedded(&self) -> bool {
    #[cfg(feature = "embedded")]
    return self.embedded.is_some();
    #[cfg(not(feature = "embedded"))]
    false
  }

  /// Closes the pool, then stops the embedded server if there is one.
  pub async fn close(self) -> anyhow::Result<()> {
    self.pool.close().await;
    #[cfg(feature = "embedded")]
    if let Some(embedded) = self.embedded {
      embedded.stop().await?;
    }
    Ok(())
  }
}

async fn connect(url: &str) -> anyhow::Result<PgPool> {
  PgPoolOptions::new()
    .max_connections(20)
    .acquire_timeout(Duration::from_secs(10))
    .connect(url)
    .await
    .context("connecting to PostgreSQL")
}
