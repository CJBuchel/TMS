//! Work the launcher does on the database itself while the server is stopped: restore, backup, password reset,
//! purge, and testing an external connection. Jobs run on a small runtime and report back over a channel.

use std::path::PathBuf;
use std::sync::Arc;
use std::sync::mpsc::{self, Receiver, Sender};

use tms_db::backup::{self, Kind};
use tms_db::{Database, Source};
use uuid::Uuid;

#[derive(Debug, Clone)]
pub enum Job {
  Restore(PathBuf),
  Backup,
  /// A username, and the password to give them (none for a one-time password).
  ResetPassword(String, Option<String>),
  LoadEvents,
  Purge {
    event_id: Uuid,
    code: String,
  },
  TestConnection(String),
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct EventRow {
  pub id: Uuid,
  pub code: String,
  pub name: String,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Report {
  Step(String),
  Done(String),
  Failed(String),
  Events(Vec<EventRow>),
  Password { username: String, password: String },
}

pub struct Jobs {
  runtime: tokio::runtime::Runtime,
  sender: Sender<Report>,
  reports: Receiver<Report>,
  running: bool,
  wake: Arc<dyn Fn() + Send + Sync>,
}

/// Where the database is and where backups and tools live.
#[derive(Debug, Clone)]
pub struct Place {
  pub source: Source,
  pub postgres_dir: PathBuf,
  pub backups_dir: PathBuf,
}

impl Jobs {
  pub fn new(wake: Arc<dyn Fn() + Send + Sync>) -> anyhow::Result<Self> {
    let runtime = tokio::runtime::Builder::new_multi_thread()
      .worker_threads(2)
      .enable_all()
      .build()?;
    let (sender, reports) = mpsc::channel();
    Ok(Self {
      runtime,
      sender,
      reports,
      running: false,
      wake,
    })
  }

  pub fn running(&self) -> bool {
    self.running
  }

  pub fn start(&mut self, place: Place, job: Job) {
    self.running = true;
    let (sender, wake) = (self.sender.clone(), Arc::clone(&self.wake));
    self.runtime.spawn(async move {
      let step = |text: &str| {
        let _ = sender.send(Report::Step(text.to_owned()));
        wake();
      };
      let result = run(&place, job, &step).await;
      let _ = sender.send(match result {
        Ok(report) => report,
        Err(e) => Report::Failed(format!("{e:#}")),
      });
      wake();
    });
  }

  /// Reports since the last call. A `Done`, `Failed`, `Events` or `Password` report ends the job.
  pub fn poll(&mut self) -> Vec<Report> {
    let reports: Vec<Report> = self.reports.try_iter().collect();
    if reports.iter().any(|r| !matches!(r, Report::Step(_))) {
      self.running = false;
    }
    reports
  }
}

async fn run(place: &Place, job: Job, step: &impl Fn(&str)) -> anyhow::Result<Report> {
  if let Job::TestConnection(url) = &job {
    step("Connecting");
    let db = Database::open(Source::External { url: url.clone() }).await?;
    db.close().await?;
    return Ok(Report::Done("Connected.".into()));
  }
  step("Opening the database");
  let db = Database::open(place.source.clone()).await?;
  let result = with_database(place, &db, job, step).await;
  db.close().await?;
  result
}

async fn with_database(place: &Place, db: &Database, job: Job, step: &impl Fn(&str)) -> anyhow::Result<Report> {
  match job {
    Job::Restore(file) => {
      db.migrate().await?;
      let tools = backup::tools(db, &place.postgres_dir).await?;
      step("Backing up the current data first");
      backup::create(
        db,
        &tools,
        &place.backups_dir,
        Kind::BeforeRestore,
        env!("CARGO_PKG_VERSION"),
      )
      .await?;
      step("Restoring");
      let manifest = backup::restore(db, &tools, &file).await?;
      Ok(Report::Done(format!(
        "Restored the backup from {}.",
        manifest.created_at.format("%Y-%m-%d %H:%M UTC")
      )))
    }
    Job::Backup => {
      db.migrate().await?;
      let tools = backup::tools(db, &place.postgres_dir).await?;
      step("Backing up");
      let file = backup::create(db, &tools, &place.backups_dir, Kind::Manual, env!("CARGO_PKG_VERSION")).await?;
      Ok(Report::Done(format!("Created {}.", file.display())))
    }
    Job::ResetPassword(username, chosen) => {
      db.migrate().await?;
      match tms_server::maintenance::reset_password(db.pool(), &username, chosen).await? {
        Some(password) => Ok(Report::Password {
          username: username.trim().to_owned(),
          password,
        }),
        None => Ok(Report::Done(format!("{} has the new password.", username.trim()))),
      }
    }
    Job::LoadEvents => {
      db.migrate().await?;
      let events = tms_server::maintenance::event_list(db.pool()).await?;
      Ok(Report::Events(
        events
          .into_iter()
          .map(|e| EventRow {
            id: e.id,
            code: e.code,
            name: e.name,
          })
          .collect(),
      ))
    }
    Job::Purge { event_id, code } => {
      db.migrate().await?;
      step("Deleting the event");
      tms_server::maintenance::purge_event(db.pool(), event_id, &code).await?;
      Ok(Report::Done(format!("Deleted event {}.", code.trim().to_uppercase())))
    }
    Job::TestConnection(_) => unreachable!("handled before opening a database"),
  }
}
