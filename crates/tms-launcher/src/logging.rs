use std::path::Path;

use tracing_appender::non_blocking::WorkerGuard;
use tracing_appender::rolling::{RollingFileAppender, Rotation};
use tracing_subscriber::EnvFilter;
use tracing_subscriber::fmt;
use tracing_subscriber::prelude::*;

const KEEP_LOG_FILES: usize = 14;

/// Logs to a daily file in `<data>/logs`, and to the terminal unless `terminal` is false (a supervised server's
/// stdout carries status lines only). Keep the returned guard alive until exit, or the last lines are lost.
pub fn init(level: &str, logs_dir: Option<&Path>, terminal: bool) -> anyhow::Result<Option<WorkerGuard>> {
  let filter = EnvFilter::try_new(format!("{level},tower_http=warn,sqlx=warn,postgresql_embedded=warn"))
    .map_err(|e| anyhow::anyhow!("invalid log level `{level}`: {e}"))?;
  let terminal = terminal.then(|| fmt::layer().with_target(false));
  let (file, guard) = match logs_dir {
    Some(dir) => {
      // The appender looks for old files to prune when it starts and complains if the folder is missing.
      std::fs::create_dir_all(dir)?;
      let appender = RollingFileAppender::builder()
        .rotation(Rotation::DAILY)
        .filename_prefix("tms")
        .filename_suffix("log")
        .max_log_files(KEEP_LOG_FILES)
        .build(dir)?;
      let (writer, guard) = tracing_appender::non_blocking(appender);
      (Some(fmt::layer().with_ansi(false).with_writer(writer)), Some(guard))
    }
    None => (None, None),
  };
  tracing_subscriber::registry()
    .with(filter)
    .with(terminal)
    .with(file)
    .init();
  Ok(guard)
}
