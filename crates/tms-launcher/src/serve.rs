//! Running the server: database, web server, interval backups, and a clean stop.

use std::sync::Arc;
use std::time::Duration;
use tms_server::bootstrap::{AdminAccount, DEFAULT_PASSWORD};

use anyhow::Context;
use tms_db::backup::{self, Kind};
use tms_server::{AppState, ServerOptions, TlsOptions};
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::sync::{mpsc, watch};

use crate::join;
use crate::logging;
use crate::settings::{ServeArgs, Settings};
use crate::status::{Command, Reporter, Status};

/// Runs the server until Ctrl+C (or SIGTERM, or `stop` on stdin when supervised), then stops the web server,
/// then the database. A supervised server reports each step as a JSON line on stdout.
pub async fn run(args: ServeArgs, supervised: bool) -> anyhow::Result<()> {
  let reporter = Reporter { supervised };
  let result = run_inner(args, reporter).await;
  match &result {
    Ok(()) => reporter.send(&Status::Stopped),
    Err(e) => reporter.send(&Status::Fatal {
      message: format!("{e:#}"),
    }),
  }
  result
}

async fn run_inner(args: ServeArgs, reporter: Reporter) -> anyhow::Result<()> {
  let settings = args.resolve()?;
  std::fs::create_dir_all(&settings.data_dir)
    .with_context(|| format!("creating the data folder {}", settings.data_dir.display()))?;
  let _log_guard = logging::init(
    &settings.log_level,
    Some(&settings.data_dir.join("logs")),
    !reporter.supervised,
  )?;
  tracing::info!(data_dir = %settings.data_dir.display(), version = env!("CARGO_PKG_VERSION"), "starting TMS");
  #[cfg(windows)]
  keep_awake();

  let (stop_tx, stop_rx) = watch::channel(false);
  let (backup_tx, backup_rx) = mpsc::channel(4);
  if reporter.supervised {
    tokio::spawn(read_commands(stop_tx.clone(), backup_tx));
  }
  tokio::spawn(stop_on_signal(stop_tx));

  reporter.send(&Status::StartingDatabase);
  let database = tms_db::Database::open(settings.db_source()).await?;
  let result = serve_with(&settings, &database, reporter, stop_rx, backup_rx).await;
  reporter.send(&Status::Stopping);
  database.close().await?;
  tracing::info!("stopped");
  result
}

/// Keeps Windows from sleeping while the server runs: a laptop that sleeps mid-event takes every tablet with it.
/// The screen may still turn off. It ends with the process, and closing the lid still follows the power settings.
#[cfg(windows)]
fn keep_awake() {
  use windows_sys::Win32::System::Power::{ES_CONTINUOUS, ES_SYSTEM_REQUIRED, SetThreadExecutionState};
  // SAFETY: SetThreadExecutionState takes flags only and has no other preconditions.
  #[allow(unsafe_code)]
  unsafe {
    SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED);
  }
}

async fn serve_with(
  settings: &Settings,
  database: &tms_db::Database,
  reporter: Reporter,
  stop: watch::Receiver<bool>,
  backup_requests: mpsc::Receiver<()>,
) -> anyhow::Result<()> {
  reporter.send(&Status::Migrating);
  database.migrate().await?;
  match tms_server::bootstrap::ensure_admin(database.pool(), settings.admin_password.clone()).await? {
    AdminAccount::CreatedWithDefault => {
      tracing::warn!("created the user `admin` with the password `{DEFAULT_PASSWORD}`");
      if reporter.supervised {
        reporter.send(&Status::AdminPassword {
          password: DEFAULT_PASSWORD.to_owned(),
        });
      } else {
        println!(
          "\n  First start: log in as `admin` with the password `{DEFAULT_PASSWORD}`. Set your own with --admin-password.\n"
        );
      }
    }
    AdminAccount::PasswordSet => tracing::info!("set the password of the user `admin`"),
    AdminAccount::Unchanged => {}
  }

  let state = AppState::new(database.pool().clone()).await?;
  tracing::info!(web_dir = %settings.web_dir.display(), "serving the web client");
  let options = ServerOptions {
    bind: settings.bind,
    port: settings.port,
    tls: settings.tls.as_ref().map(|t| TlsOptions {
      cert: t.cert.clone(),
      key: t.key.clone(),
      port: t.port,
    }),
    web_dir: settings.web_dir.clone(),
  };

  let urls = Arc::new(join::urls(settings));
  let show_qr = settings.show_qr;
  let on_listening = move || {
    if reporter.supervised {
      reporter.send(&Status::Listening { urls: urls.to_vec() });
    } else {
      announce(&urls, show_qr);
    }
  };
  let shutdown = {
    let mut stop = stop.clone();
    async move {
      let _ = stop.wait_for(|stopped| *stopped).await;
      tracing::info!("stopping");
    }
  };
  let server = tms_server::run(state, options, shutdown, on_listening);
  let backups = backup_loop(settings.clone(), database, reporter, stop, backup_requests);
  tokio::pin!(server, backups);
  // The server's result decides: it may fail to start (a port in use) while backups wait for a stop that never
  // comes. On a normal stop the backups end first and the server finishes its graceful shutdown.
  tokio::select! {
    result = &mut server => result,
    () = &mut backups => server.await,
  }
}

/// Automatic backups on the interval (pruned to the retention count), and manual ones when the launcher asks.
async fn backup_loop(
  settings: Settings,
  database: &tms_db::Database,
  reporter: Reporter,
  mut stop: watch::Receiver<bool>,
  mut requests: mpsc::Receiver<()>,
) {
  let every = Duration::from_secs(u64::from(settings.backup_interval_minutes) * 60);
  // With backups off the interval never fires; a year stands in for "never" without overflowing the clock.
  let period = if every.is_zero() {
    Duration::from_hours(365 * 24)
  } else {
    every
  };
  let mut interval = tokio::time::interval(period);
  interval.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Delay);
  interval.tick().await;
  loop {
    let kind = tokio::select! {
      _ = interval.tick(), if !every.is_zero() => Kind::Auto,
      Some(()) = requests.recv() => Kind::Manual,
      _ = stop.wait_for(|stopped| *stopped) => return,
    };
    match make_backup(&settings, database, kind).await {
      Ok(file) => {
        tracing::info!(file = %file.display(), "backup created");
        reporter.send(&Status::BackupCreated {
          file: file.display().to_string(),
        });
      }
      Err(e) => {
        tracing::error!(error = %format!("{e:#}"), "backup failed");
        reporter.send(&Status::BackupFailed {
          message: format!("{e:#}"),
        });
      }
    }
  }
}

pub async fn make_backup(
  settings: &Settings,
  database: &tms_db::Database,
  kind: Kind,
) -> anyhow::Result<std::path::PathBuf> {
  let tools = backup::tools(database, &settings.data_dir.join("postgres")).await?;
  let folder = settings.backups_dir();
  let file = backup::create(database, &tools, &folder, kind, env!("CARGO_PKG_VERSION")).await?;
  if kind == Kind::Auto {
    backup::prune(&folder, settings.backup_retain)?;
  }
  Ok(file)
}

/// Supervised: commands from the launcher, one per line. End of input means the launcher is gone.
async fn read_commands(stop: watch::Sender<bool>, backup: mpsc::Sender<()>) {
  let mut lines = BufReader::new(tokio::io::stdin()).lines();
  while let Ok(Some(line)) = lines.next_line().await {
    match Command::parse(&line) {
      Some(Command::Stop) => break,
      Some(Command::Backup) => {
        let _ = backup.try_send(());
      }
      None => tracing::warn!(%line, "unknown command from the launcher"),
    }
  }
  let _ = stop.send(true);
}

fn announce(urls: &[String], show_qr: bool) {
  tracing::info!(urls = ?urls, "TMS is running");
  let mut text = String::from("\n  TMS is running. Open one of these on any device on the network:\n\n");
  for url in urls {
    text.push_str("    ");
    text.push_str(url);
    text.push('\n');
  }
  if show_qr && let Some(qr) = urls.first().and_then(|url| join::terminal_qr(url)) {
    text.push('\n');
    text.push_str(&qr);
    text.push('\n');
  }
  text.push_str("\n  Press Ctrl+C to stop.\n");
  println!("{text}");
}

async fn stop_on_signal(stop: watch::Sender<bool>) {
  let ctrl_c = async {
    let _ = tokio::signal::ctrl_c().await;
  };
  #[cfg(unix)]
  let terminate = async {
    match tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate()) {
      Ok(mut signal) => {
        signal.recv().await;
      }
      Err(_) => std::future::pending::<()>().await,
    }
  };
  #[cfg(not(unix))]
  let terminate = std::future::pending::<()>();
  tokio::select! {
    () = ctrl_c => {},
    () = terminate => {},
  }
  let _ = stop.send(true);
}
