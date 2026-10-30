//! The newest log file's last lines, for the Logs tab and crash reports.

use std::io::{Read, Seek, SeekFrom};
use std::path::{Path, PathBuf};

const KEEP_LINES: usize = 500;
/// Enough bytes for 500 ordinary lines.
const READ_BYTES: u64 = 256 * 1024;

pub fn newest_file(logs_dir: &Path) -> Option<PathBuf> {
  std::fs::read_dir(logs_dir)
    .ok()?
    .flatten()
    .filter(|e| e.file_name().to_string_lossy().starts_with("tms"))
    .max_by_key(|e| e.metadata().and_then(|m| m.modified()).ok())
    .map(|e| e.path())
}

/// The last lines of the newest log file, oldest first.
pub fn tail(logs_dir: &Path) -> Vec<String> {
  let Some(path) = newest_file(logs_dir) else {
    return Vec::new();
  };
  let Ok(mut file) = std::fs::File::open(path) else {
    return Vec::new();
  };
  let len = file.metadata().map_or(0, |m| m.len());
  let start = len.saturating_sub(READ_BYTES);
  if file.seek(SeekFrom::Start(start)).is_err() {
    return Vec::new();
  }
  let mut bytes = Vec::new();
  let _ = file.read_to_end(&mut bytes);
  let text = String::from_utf8_lossy(&bytes);
  let mut lines: Vec<String> = text.lines().map(str::to_owned).collect();
  if start > 0 && !lines.is_empty() {
    // The first line was cut part way through.
    lines.remove(0);
  }
  let excess = lines.len().saturating_sub(KEEP_LINES);
  lines.drain(..excess);
  lines
}

/// Whether a line is at least as severe as `level` ("all", "info", "warn", "error").
pub fn passes(line: &str, level: &str) -> bool {
  let severity = ["ERROR", "WARN", "INFO", "DEBUG", "TRACE"]
    .iter()
    .position(|name| line.contains(&format!(" {name} ")))
    .unwrap_or(4);
  let wanted = match level {
    "error" => 0,
    "warn" => 1,
    "info" => 2,
    _ => 4,
  };
  severity <= wanted
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn reads_the_newest_file_and_filters_by_level() {
    let dir = std::env::temp_dir().join(format!("tms-logs-{}", std::process::id()));
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(&dir).unwrap();
    std::fs::write(dir.join("tms.2026-10-28.log"), "old\n").unwrap();
    std::thread::sleep(std::time::Duration::from_millis(20));
    std::fs::write(
      dir.join("tms.2026-10-29.log"),
      "2026-10-29T10:00:00Z  INFO starting TMS\n2026-10-29T10:00:01Z ERROR port in use\n",
    )
    .unwrap();
    let lines = tail(&dir);
    assert_eq!(lines.len(), 2);
    assert!(passes(&lines[1], "error") && !passes(&lines[0], "warn") && passes(&lines[0], "all"));
    let _ = std::fs::remove_dir_all(&dir);
  }
}
